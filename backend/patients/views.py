from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
from django.db.models import Case, When, IntegerField
import sys, os
from drf_spectacular.utils import extend_schema, OpenApiParameter
from drf_spectacular.types import OpenApiTypes
from rest_framework.permissions import AllowAny, IsAuthenticated

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from AI_ML.predictor_synthetic import predict_severity

from .models import Symptom, Visit, VisitSymptom, PatientProfile
from .serializers import (
    SymptomSerializer,
    VisitCreateSerializer,
    VisitDetailSerializer,
    QueueSerializer,
)


def assign_queue_position(severity: str) -> int:
    if severity == 'SEVERE':
        count = Visit.objects.filter(queue_category='SEVERE', status='WAITING').count()
        return count + 1
    elif severity == 'MODERATE':
        severe_count   = Visit.objects.filter(queue_category='SEVERE',   status='WAITING').count()
        moderate_count = Visit.objects.filter(queue_category='MODERATE', status='WAITING').count()
        return severe_count + moderate_count + 1
    else:
        total = Visit.objects.filter(status='WAITING').count()
        return total + 1


class SymptomListView(APIView):
    permission_classes = [AllowAny]  # public — patient not logged in yet

    def get(self, request):
        symptoms   = Symptom.objects.all()
        serializer = SymptomSerializer(symptoms, many=True)
        return Response(serializer.data)


class CreateVisitView(APIView):
    permission_classes = [AllowAny]  # public — patient submits before auth flow

    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'reg_no':         {'type': 'string',  'example': '126-063061-00001'},
                    'symptoms':       {'type': 'array', 'items': {'type': 'integer'}, 'example': [1, 2, 3]},
                    'other_symptoms': {'type': 'string',  'example': 'my left eye itches'},
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

        reg_no         = serializer.validated_data['reg_no']
        patient        = PatientProfile.objects.get(reg_no=reg_no)
        symptom_ids    = serializer.validated_data['symptoms']
        other_symptoms = serializer.validated_data.get('other_symptoms', '')

        symptom_objects = Symptom.objects.filter(id__in=symptom_ids)
        symptom_names   = list(symptom_objects.values_list('name', flat=True))

        age    = patient.get_age()
        gender = patient.gender or 'M'

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

        position = assign_queue_position(severity)

        visit = Visit.objects.create(
            patient        = patient,
            status         = 'WAITING',
            queue_category = severity,
            queue_position = position,
            other_symptoms = doctor_note,
        )

        for symptom in symptom_objects:
            VisitSymptom.objects.create(visit=visit, symptom=symptom)

        return Response({
            'visit_id':       visit.id,
            'severity':       severity,
            'queue_position': position,
            'message':        f"You are number {position} in the queue"
        }, status=status.HTTP_201_CREATED)


class QueueView(APIView):
    permission_classes = [IsAuthenticated]  # doctor must be logged in

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


class VisitDetailView(APIView):
    permission_classes = [IsAuthenticated]  # doctor must be logged in

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