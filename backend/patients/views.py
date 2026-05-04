from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
from django.db.models import Case, When, IntegerField
import sys, os
from drf_spectacular.utils import extend_schema, OpenApiParameter
from drf_spectacular.types import OpenApiTypes

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
#from AI_ML.predictor import predict_severity
from AI_ML.predictor import predict_severity

from .models import Symptom, Visit, VisitSymptom, PatientProfile
from .serializers import (
    SymptomSerializer,
    VisitCreateSerializer,
    VisitDetailSerializer,
    QueueSerializer,
)


def assign_queue_position(severity: str) -> int:
    """
    SEVERE   → front of queue
    MODERATE → after all severe
    MINOR    → last
    """
    if severity == 'SEVERE':
        count = Visit.objects.filter(
            queue_category='SEVERE',
            status='WAITING'
        ).count()
        return count + 1

    elif severity == 'MODERATE':
        severe_count   = Visit.objects.filter(queue_category='SEVERE',   status='WAITING').count()
        moderate_count = Visit.objects.filter(queue_category='MODERATE', status='WAITING').count()
        return severe_count + moderate_count + 1

    else:  # MINOR
        total = Visit.objects.filter(status='WAITING').count()
        return total + 1


# ─────────────────────────────────────────
# 1. GET /api/patients/symptoms/
# ─────────────────────────────────────────
class SymptomListView(APIView):
    """Returns all symptoms for Flutter to display as a selection list"""

    def get(self, request):
        symptoms   = Symptom.objects.all()
        serializer = SymptomSerializer(symptoms, many=True)
        return Response(serializer.data)


# ─────────────────────────────────────────
# 2. POST /api/patients/visits/
# ─────────────────────────────────────────
class CreateVisitView(APIView):
    """
    Patient submits symptoms → ML predicts severity → queue position assigned
    """
    @extend_schema(
    request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'reg_no':         {'type': 'string', 'example': '126-063061-00001'},
                    'symptoms':       {'type': 'array', 'items': {'type': 'integer'}, 'example': [1, 2, 3]},
                    'other_symptoms': {'type': 'string', 'example': 'my left eye itches'},
                },
                'required': ['reg_no', 'symptoms']
            }
        },
        responses={201: {
            'type': 'object',
            'properties': {
                'visit_id':       {'type': 'integer'},
                'severity':       {'type': 'string'},
                'queue_position': {'type': 'integer'},
                'message':        {'type': 'string'},
            }
        }}
    )


    def post(self, request):
        serializer = VisitCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        # fetch patient by reg_no
        reg_no         = serializer.validated_data['reg_no']
        patient        = PatientProfile.objects.get(reg_no=reg_no)
        symptom_ids    = serializer.validated_data['symptoms']
        other_symptoms = serializer.validated_data.get('other_symptoms', '')

        # Step 1 — get symptom names from DB
        symptom_objects = Symptom.objects.filter(id__in=symptom_ids)
        symptom_names   = list(symptom_objects.values_list('name', flat=True))

        # Step 2 — get patient age and gender for ML
        age    = patient.get_age()
        gender = patient.gender or 'M'

        # Step 3 — call ML model
        try:
            result      = predict_severity(
                selected_symptoms = symptom_names,
                free_text         = other_symptoms,
                age               = age,
                gender            = gender,
                arrival_datetime  = timezone.now()
            )
            severity    = result['severity']
            doctor_note = result['doctor_note']
        except Exception as e:
            return Response(
                {'error': f'ML prediction failed: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        # Step 4 — assign queue position
        position = assign_queue_position(severity)

        # Step 5 — create Visit
        visit = Visit.objects.create(
            patient        = patient,
            status         = 'WAITING',
            queue_category = severity,
            queue_position = position,
            other_symptoms = doctor_note,
        )

        # Step 6 — save VisitSymptom rows
        for symptom in symptom_objects:
            VisitSymptom.objects.create(visit=visit, symptom=symptom)

        # Step 7 — return response to Flutter
        return Response({
            'visit_id':       visit.id,
            'severity':       severity,
            'queue_position': position,
            'message':        f"You are number {position} in the queue"
        }, status=status.HTTP_201_CREATED)


# ─────────────────────────────────────────
# 3. GET /api/patients/queue/
# ─────────────────────────────────────────
class QueueView(APIView):
    """
    Doctor sees all waiting patients ordered by severity then arrival time.
    SEVERE first, then MODERATE, then MINOR.
    Within each category → first come first serve.
    """

    def get(self, request):
        visits = Visit.objects.filter(status='WAITING').annotate(
            severity_order=Case(
                When(queue_category='SEVERE',   then=1),
                When(queue_category='MODERATE', then=2),
                When(queue_category='MINOR',    then=3),
                default=4,
                output_field=IntegerField(),
            )
        ).order_by('severity_order', 'created_at')

        serializer = QueueSerializer(visits, many=True)
        return Response({
            'total_waiting': visits.count(),
            'queue':         serializer.data
        })


# ─────────────────────────────────────────
# 4. GET /api/patients/visits/{id}/
# ─────────────────────────────────────────
class VisitDetailView(APIView):
    """Returns full details of a specific visit including symptoms"""

    def get(self, request, visit_id):
        try:
            visit = Visit.objects.get(id=visit_id)
        except Visit.DoesNotExist:
            return Response(
                {'error': 'Visit not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = VisitDetailSerializer(visit)
        return Response(serializer.data)