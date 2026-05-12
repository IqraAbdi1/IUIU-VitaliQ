from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_spectacular.utils import extend_schema
from django.utils import timezone
from rest_framework.permissions import IsAuthenticated
from django.db.models import F

from .models import Consultation, LabRequest, LabResult, Prescription, Announcement, LabTest
from .serializers import (
    ConsultationCreateSerializer,
    ConsultationDetailSerializer,
    LabRequestCreateSerializer,
    PrescriptionCreateSerializer,
)
from patients.models import Visit
from clinic_staff.models import ClinicStaff
from users.models import Notification
from django.db import models


from patients.models import Visit
from pharmacy.models import MedicineStock
from clinic_staff.models import ClinicStaff


# ─────────────────────────────────────────────
# 1. POST /api/consultation/
# Creates OR updates consultation (two-step flow)
# Step 1 — doctor fills vitals + provisional notes
# Step 2 — doctor updates with final diagnosis after lab
# ─────────────────────────────────────────────
class CreateConsultationView(APIView):
    """
    First call  → creates consultation with provisional notes
    Second call → updates same consultation with final diagnosis
    """

    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'visit_id':          {'type': 'integer', 'example': 1},
                    'doctor_staff_id':   {'type': 'string',  'example': '126-010101-00001'},
                    'clinical_notes':    {'type': 'string',  'example': 'Patient has fever for 3 days'},
                    'diagnosis':         {'type': 'string',  'example': 'PENDING LAB RESULTS'},
                    'severity_override': {'type': 'string',  'example': 'SEVERE'},
                    'bp_systolic':       {'type': 'integer', 'example': 120},
                    'bp_diastolic':      {'type': 'integer', 'example': 80},
                    'temperature':       {'type': 'number',  'example': 37.5},
                    'weight':            {'type': 'number',  'example': 65.0},
                    'height':            {'type': 'number',  'example': 170.0},
                },
                'required': ['visit_id', 'doctor_staff_id']
            }
        }
    )
    def post(self, request):
        serializer = ConsultationCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        try:
            visit = Visit.objects.get(id=data['visit_id'])
        except Visit.DoesNotExist:
            return Response({'error': 'Visit not found'}, status=status.HTTP_404_NOT_FOUND)

        try:
            doctor = ClinicStaff.objects.get(staff_id=data['doctor_staff_id'])
        except ClinicStaff.DoesNotExist:
            return Response({'error': 'Doctor not found'}, status=status.HTTP_404_NOT_FOUND)

        # ── check if consultation already exists ──
        existing = getattr(visit, 'consultation', None)

        if existing:
            # ── STEP 2 — update existing consultation with final diagnosis ──
            if data.get('clinical_notes'):
                existing.clinical_notes    = data['clinical_notes']
            if data.get('diagnosis'):
                existing.diagnosis         = data['diagnosis']
            if data.get('severity_override'):
                existing.severity_override = data['severity_override']
            if data.get('bp_systolic'):
                existing.bp_systolic       = data['bp_systolic']
            if data.get('bp_diastolic'):
                existing.bp_diastolic      = data['bp_diastolic']
            if data.get('temperature'):
                existing.temperature       = data['temperature']
            if data.get('weight'):
                existing.weight            = data['weight']
            if data.get('height'):
                existing.height            = data['height']

            existing.save()

            return Response({
                'consultation_id': existing.id,
                'message':         'Consultation updated with final diagnosis',
                'visit_status':    visit.status,
                'is_update':       True,
            }, status=status.HTTP_200_OK)

        else:
            # ── STEP 1 — create new consultation ──
            consultation = Consultation.objects.create(
                visit             = visit,
                doctor            = doctor,
                clinical_notes    = data.get('clinical_notes', ''),
                diagnosis         = data.get('diagnosis', 'PENDING LAB RESULTS'),
                severity_override = data.get('severity_override'),
                bp_systolic       = data.get('bp_systolic'),
                bp_diastolic      = data.get('bp_diastolic'),
                temperature       = data.get('temperature'),
                weight            = data.get('weight'),
                height            = data.get('height'),
            )

            visit.status = 'IN_CONSULTATION'
            visit.save()

            Notification.objects.create(
                user              = visit.patient.user,
                message           = f"Dr. {doctor.username} has started your consultation.",
                notification_type = 'GENERAL'
            )

            return Response({
                'consultation_id': consultation.id,
                'message':         'Consultation created — awaiting lab results or final diagnosis',
                'visit_status':    visit.status,
                'is_update':       False,
            }, status=status.HTTP_201_CREATED)


# ─────────────────────────────────────────────
# 2. GET /api/consultation/{visit_id}/
# Get full consultation details for a visit
# ─────────────────────────────────────────────
class ConsultationDetailView(APIView):
    """Returns full consultation details including symptoms and lab status"""
    permission_classes = [IsAuthenticated]
    def get(self, request, visit_id):
        try:
            consultation = Consultation.objects.get(visit__id=visit_id)
        except Consultation.DoesNotExist:
            return Response(
                {'error': 'No consultation found for this visit'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = ConsultationDetailSerializer(consultation)
        return Response(serializer.data)


# ─────────────────────────────────────────────
# 3. POST /api/consultation/lab-request/
# Doctor sends lab request
# ─────────────────────────────────────────────
class CreateLabRequestView(APIView):
    """Doctor types tests needed and sends to lab"""
    permission_classes = [IsAuthenticated]
    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'visit_id':        {'type': 'integer', 'example': 1},
                    'tests_requested': {'type': 'string',  'example': 'Malaria RDT, FBC, Typhoid'},
                    'notes_to_lab':    {'type': 'string',  'example': 'Patient febrile for 3 days'},
                },
                'required': ['visit_id', 'tests_requested']
            }
        }
    )
    def post(self, request):
        serializer = LabRequestCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        try:
            consultation = Consultation.objects.get(visit__id=data['visit_id'])
        except Consultation.DoesNotExist:
            return Response(
                {'error': 'Complete consultation first before sending lab request'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if hasattr(consultation, 'lab_request'):
            return Response(
                {'error': 'Lab request already sent for this consultation'},
                status=status.HTTP_400_BAD_REQUEST
            )

        lab_request = LabRequest.objects.create(
            consultation    = consultation,
            tests_requested = data['tests_requested'],
            notes_to_lab    = data.get('notes_to_lab', ''),
        )

        consultation.visit.status = 'LAB'
        consultation.visit.save()

        return Response({
            'lab_request_id': lab_request.id,
            'message':        'Lab request sent successfully',
            'tests':          lab_request.tests_requested,
            'visit_status':   'LAB',
        }, status=status.HTTP_201_CREATED)


# ─────────────────────────────────────────────
# 4. POST /api/consultation/lab-result/
# Lab attendant uploads results
# ─────────────────────────────────────────────
class UploadLabResultView(APIView):
    """Lab attendant uploads results for a pending lab request"""

    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'visit_id':     {'type': 'integer', 'example': 1},
                    'lab_staff_id': {'type': 'string',  'example': '126-010103-00001'},
                    'result':       {'type': 'string',  'example': 'Malaria RDT: Positive\nFBC: WBC 12,400'},
                },
                'required': ['visit_id', 'lab_staff_id', 'result']
            }
        }
    )
    def post(self, request):
        visit_id     = request.data.get('visit_id')
        lab_staff_id = request.data.get('lab_staff_id')
        result       = request.data.get('result')

        if not all([visit_id, lab_staff_id, result]):
            return Response(
                {'error': 'visit_id, lab_staff_id and result are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            lab_request = LabRequest.objects.get(consultation__visit__id=visit_id)
        except LabRequest.DoesNotExist:
            return Response(
                {'error': 'No lab request found for this visit'},
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            lab_attendant = ClinicStaff.objects.get(staff_id=lab_staff_id)
        except ClinicStaff.DoesNotExist:
            return Response(
                {'error': 'Lab attendant not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        if hasattr(lab_request, 'result'):
            return Response(
                {'error': 'Results already uploaded for this request'},
                status=status.HTTP_400_BAD_REQUEST
            )

        lab_result = LabResult.objects.create(
            lab_request   = lab_request,
            lab_attendant = lab_attendant,
            result        = result,
        )

        lab_request.status = 'COMPLETE'
        lab_request.save()

        # move visit back to IN_CONSULTATION so doctor can finalize
        lab_request.consultation.visit.status = 'IN_CONSULTATION'
        lab_request.consultation.visit.save()

        # notify doctor
        Notification.objects.create(
            user              = lab_request.consultation.doctor.user,
            message           = f"Lab results ready for {lab_request.consultation.visit.patient.username}",
            notification_type = 'LAB_RESULT'
        )

        # notify patient
        Notification.objects.create(
            user              = lab_request.consultation.visit.patient.user,
            message           = 'Your lab results are ready. Please return to the doctor.',
            notification_type = 'LAB_RESULT'
        )

        return Response({
            'lab_result_id': lab_result.id,
            'message':       'Lab results uploaded successfully',
            'visit_status':  'IN_CONSULTATION',
        }, status=status.HTTP_201_CREATED)


# ─────────────────────────────────────────────
# 5. GET /api/consultation/lab-result/{visit_id}/
# Doctor reads lab results
# ─────────────────────────────────────────────
class GetLabResultView(APIView):
    """Doctor reads lab results for a specific visit"""

    def get(self, request, visit_id):
        try:
            lab_result = LabResult.objects.get(
                lab_request__consultation__visit__id=visit_id
            )
        except LabResult.DoesNotExist:
            return Response(
                {'error': 'No lab results found for this visit'},
                status=status.HTTP_404_NOT_FOUND
            )

        return Response({
            'visit_id':        visit_id,
            'patient_name':    lab_result.lab_request.consultation.visit.patient.username,
            'tests_requested': lab_result.lab_request.tests_requested,
            'result':          lab_result.result,
            'lab_attendant':   lab_result.lab_attendant.username if lab_result.lab_attendant else None,
            'uploaded_at':     lab_result.uploaded_at,
            'status':          lab_result.lab_request.status,
        })


# ─────────────────────────────────────────────
# 6. POST /api/consultation/prescribe/
# Doctor writes prescriptions
# ─────────────────────────────────────────────
class CreatePrescriptionView(APIView):
    """Doctor writes one or more medicines for a patient"""

    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'visit_id': {'type': 'integer', 'example': 1},
                    'prescriptions': {
                        'type': 'array',
                        'items': {
                            'type': 'object',
                            'properties': {
                                'medicine_name': {'type': 'string', 'example': 'Paracetamol'},
                                'dosage':        {'type': 'string', 'example': '500mg'},
                                'duration':      {'type': 'string', 'example': '5 days'},
                                'instructions':  {'type': 'string', 'example': 'Take after meals'},
                            }
                        }
                    }
                },
                'required': ['visit_id', 'prescriptions']
            }
        }
    )
    def post(self, request):
        serializer = PrescriptionCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        try:
            consultation = Consultation.objects.get(visit__id=data['visit_id'])
        except Consultation.DoesNotExist:
            return Response(
                {'error': 'Complete consultation first'},
                status=status.HTTP_400_BAD_REQUEST
            )

        created = []
        for item in data['prescriptions']:
            p = Prescription.objects.create(
                consultation  = consultation,
                medicine_name = item.get('medicine_name', ''),
                dosage        = item.get('dosage', ''),
                duration      = item.get('duration', ''),
                instructions  = item.get('instructions', ''),
            )
            created.append({
                'id':            p.id,
                'medicine_name': p.medicine_name,
                'dosage':        p.dosage,
                'duration':      p.duration,
            })

        consultation.visit.status = 'PHARMACY'
        consultation.visit.save()

        Notification.objects.create(
            user              = consultation.visit.patient.user,
            message           = 'Your prescription is ready. Please go to the pharmacy.',
            notification_type = 'PRESCRIPTION'
        )

        return Response({
            'message':       'Prescriptions created successfully',
            'prescriptions': created,
            'visit_status':  'PHARMACY',
        }, status=status.HTTP_201_CREATED)


# ─────────────────────────────────────────────
# 7. GET /api/consultation/doctor/dashboard/
# Doctor home screen stats
# ─────────────────────────────────────────────
class DoctorDashboardView(APIView):
    """Returns all stats needed for doctor home screen"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.now().date()

        waiting_visits = Visit.objects.filter(status='WAITING')
        in_queue       = waiting_visits.count()
        urgent_count   = waiting_visits.filter(queue_category='SEVERE').count()
        seen_today     = Consultation.objects.filter(consulted_at__date=today).count()
        pending_labs   = LabRequest.objects.filter(status='PENDING').count()
        avg_consult    = 8

        notifications = Notification.objects.filter(
            user=request.user
        ).order_by('-created_at')[:5]

        notif_data = [
            {
                'message':           n.message,
                'notification_type': n.notification_type,
                'is_read':           n.is_read,
                'created_at':        n.created_at,
            }
            for n in notifications
        ]

        announcements = Announcement.objects.all()[:5]
        ann_data = [
            {
                'title':      a.title,
                'message':    a.message,
                'posted_by':  a.posted_by.username if a.posted_by else 'Admin',
                'is_pinned':  a.is_pinned,
                'created_at': a.created_at,
            }
            for a in announcements
        ]

        return Response({
            'in_queue':      in_queue,
            'urgent_count':  urgent_count,
            'seen_today':    seen_today,
            'pending_labs':  pending_labs,
            'avg_consult':   f"{avg_consult}m",
            'notifications': notif_data,
            'announcements': ann_data,
        })

# ─────────────────────────────────────────────
# POST /api/consultation/announcements/
# Admin posts a clinic-wide announcement
# ─────────────────────────────────────────────
class CreateAnnouncementView(APIView):

    def post(self, request):
        title     = request.data.get('title')
        message   = request.data.get('message')
        is_pinned = request.data.get('is_pinned', False)
        staff_id  = request.data.get('staff_id')

        if not title or not message:
            return Response(
                {'error': 'title and message are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        posted_by = None
        if staff_id:
            try:
                posted_by = ClinicStaff.objects.get(staff_id=staff_id)
            except ClinicStaff.DoesNotExist:
                pass

        announcement = Announcement.objects.create(
            title     = title,
            message   = message,
            posted_by = posted_by,
            is_pinned = is_pinned,
        )

        return Response({
            'id':        announcement.id,
            'title':     announcement.title,
            'message':   announcement.message,
            'posted_by': posted_by.username if posted_by else 'Admin',
            'is_pinned': announcement.is_pinned,
            'created_at': announcement.created_at,
        }, status=status.HTTP_201_CREATED)
 



# ─────────────────────────────────────────────
# GET /api/lab/dashboard/
# Lab attendant home screen stats
# ─────────────────────────────────────────────
class LabDashboardView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        today = timezone.now().date()

        pending_tests   = LabRequest.objects.filter(status='PENDING').count()
        completed_today = LabResult.objects.filter(
            uploaded_at__date=today
        ).count()
        flagged_results = LabResult.objects.filter(
            result__icontains='positive'
        ).count()

        # pending lab requests with patient info
        pending_list = LabRequest.objects.filter(
            status='PENDING'
        ).select_related(
            'consultation__visit__patient'
        ).order_by('requested_at')[:10]

        pending_data = [
            {
                'lab_request_id': lr.id,
                'visit_id':       lr.consultation.visit.id,
                'patient_name':   lr.consultation.visit.patient.username,
                'reg_no':         lr.consultation.visit.patient.reg_no,
                'tests_requested':lr.tests_requested,
                'notes_to_lab':   lr.notes_to_lab,
                'requested_at':   lr.requested_at,
            }
            for lr in pending_list
        ]

        return Response({
            'pending_tests':    pending_tests,
            'completed_today':  completed_today,
            'flagged_results':  flagged_results,
            'avg_turnaround':   '22m',  # placeholder
            'pending_requests': pending_data,
        })


# ─────────────────────────────────────────────
# GET /api/admin/dashboard/
# Admin home screen stats
# ─────────────────────────────────────────────

from django.db.models import Count, F
from django.db.models.functions import TruncDate
from patients.models import Visit
from consultation.models import Prescription, Consultation
from pharmacy.models import MedicineStock
from users.models import Shift
class AdminDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today    = timezone.now().date()
        week_ago = today - timezone.timedelta(days=7)

        total_visits_today = Visit.objects.filter(created_at__date=today).count()
        total_visits_week  = Visit.objects.filter(created_at__date__gte=week_ago).count()

        top_diagnoses = (
            Consultation.objects.filter(consulted_at__date__gte=week_ago)
            .exclude(diagnosis__isnull=True)
            .exclude(diagnosis='')
            .values('diagnosis')
            .annotate(count=Count('id'))
            .order_by('-count')[:5]
)

        top_medicines = (
            Prescription.objects.filter(prescribed_at__date__gte=week_ago)
            .values('medicine_name')
            .annotate(count=Count('id'))
            .order_by('-count')[:5]
        )

        daily_visits = (
            Visit.objects.filter(created_at__date__gte=week_ago)
            .annotate(visit_date=TruncDate('created_at'))
            .values('visit_date')
            .annotate(count=Count('id'))
            .order_by('date')
        )

        low_stock   = MedicineStock.objects.filter(quantity__lte=F('low_stock_threshold')).count()
        staff_shift = Shift.objects.filter(date=today, is_active=True).count()

        return Response({
            'total_visits_today': total_visits_today,
            'total_visits_week':  total_visits_week,
            'low_stock_items':    low_stock,
            'staff_on_shift':     staff_shift,
            'ml_alerts':          low_stock,
            'top_diagnoses':      list(top_diagnoses),
            'top_medicines':      list(top_medicines),
            'daily_visits':       [
                {'date': str(d['visit_date']), 'count': d['count']}
                for d in daily_visits
            ],
        })   
# ─────────────────────────────────────────────
# GET /api/consultation/lab-tests/
# Returns all active lab tests for doctor and lab screens
# ─────────────────────────────────────────────
class LabTestListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        tests = LabTest.objects.filter(is_active=True)
        data = [
            {
                'id':              t.id,
                'name':            t.name,
                'unit':            t.unit,
                'reference_range': t.reference_range,
                'input_type':      t.input_type,
            }
            for t in tests
        ]
        return Response(data)

# ─────────────────────────────────────────────
# GET /api/consultation/lab-results/completed/
# Lab tech completed results list
# ─────────────────────────────────────────────
class CompletedLabResultsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.now().date()

        results = LabResult.objects.filter(
            #uploaded_at__date__gte=today - timezone.timedelta(days=7)
            uploaded_at__date=today
        ).select_related(
            'lab_request__consultation__visit__patient',
            'lab_attendant__user'
        ).order_by('-uploaded_at')[:20]

        data = [
            {
                'lab_request_id': r.lab_request.id,
                'visit_id':       r.lab_request.consultation.visit.id,
                'patient_name':   r.lab_request.consultation.visit.patient.username,
                'reg_no':         r.lab_request.consultation.visit.patient.reg_no,
                'tech_name':      r.lab_attendant.user.username if r.lab_attendant else 'Lab Tech',
                'result':         r.result,
                'uploaded_at':    r.uploaded_at,
            }
            for r in results
        ]
        return Response(data)