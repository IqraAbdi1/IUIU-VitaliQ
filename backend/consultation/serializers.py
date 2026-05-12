from rest_framework import serializers
from .models import Consultation, LabRequest, LabResult, Prescription, Announcement


class ConsultationCreateSerializer(serializers.Serializer):
    visit_id          = serializers.IntegerField(help_text="Visit ID from queue")
    doctor_staff_id   = serializers.CharField(help_text="Doctor's staff_id e.g. 126-010101-00001")
    clinical_notes    = serializers.CharField(required=False, allow_blank=True)
    diagnosis         = serializers.CharField(required=False, allow_blank=True)
    severity_override = serializers.ChoiceField(
                            choices=['SEVERE', 'MODERATE', 'MINOR'],
                            required=False, allow_null=True
                        )
    bp_systolic       = serializers.IntegerField(required=False, allow_null=True)
    bp_diastolic      = serializers.IntegerField(required=False, allow_null=True)
    temperature       = serializers.DecimalField(max_digits=4, decimal_places=1, required=False, allow_null=True)
    weight            = serializers.DecimalField(max_digits=5, decimal_places=1, required=False, allow_null=True)
    height            = serializers.DecimalField(max_digits=5, decimal_places=1, required=False, allow_null=True)


class LabRequestCreateSerializer(serializers.Serializer):
    visit_id        = serializers.IntegerField(help_text="Visit ID")
    tests_requested = serializers.CharField(help_text="e.g. Malaria RDT, FBC, Typhoid")
    notes_to_lab    = serializers.CharField(required=False, allow_blank=True)


class PrescriptionCreateSerializer(serializers.Serializer):
    visit_id      = serializers.IntegerField(help_text="Visit ID")
    prescriptions = serializers.ListField(
                        child=serializers.DictField(),
                        help_text="List of medicines e.g. [{medicine_name, dosage, duration, instructions}]"
                    )


class ConsultationDetailSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='visit.patient.username', read_only=True)
    reg_no       = serializers.CharField(source='visit.patient.reg_no',   read_only=True)
    doctor_name  = serializers.CharField(source='doctor.username',        read_only=True)
    severity     = serializers.SerializerMethodField()
    symptoms     = serializers.SerializerMethodField()
    lab_status   = serializers.SerializerMethodField()

    class Meta:
        model  = Consultation
        fields = [
            'id', 'patient_name', 'reg_no', 'doctor_name',
            'clinical_notes', 'diagnosis', 'severity',
            'bp_systolic', 'bp_diastolic', 'temperature', 'weight', 'height',
            'symptoms', 'lab_status', 'consulted_at'
        ]

    def get_severity(self, obj):
        return obj.get_severity()

    def get_symptoms(self, obj):
        return list(
            obj.visit.visit_symptoms.values_list('symptom__name', flat=True)
        )

    def get_lab_status(self, obj):
        """
        None     → no lab request sent yet
        PENDING  → lab request sent, waiting for results
        COMPLETE → results uploaded, doctor can read them
        """
        if not hasattr(obj, 'lab_request'):
            return None
        if hasattr(obj.lab_request, 'result'):
            return 'COMPLETE'
        return 'PENDING'


class LabResultSerializer(serializers.ModelSerializer):
    patient_name    = serializers.SerializerMethodField()
    tests_requested = serializers.CharField(source='lab_request.tests_requested', read_only=True)
    lab_attendant   = serializers.CharField(source='lab_attendant.username', read_only=True)

    class Meta:
        model  = LabResult
        fields = ['id', 'patient_name', 'tests_requested', 'result',
                  'lab_attendant', 'uploaded_at']

    def get_patient_name(self, obj):
        return obj.lab_request.consultation.visit.patient.username


class AnnouncementSerializer(serializers.ModelSerializer):
    posted_by_name = serializers.CharField(source='posted_by.username', read_only=True)

    class Meta:
        model  = Announcement
        fields = ['id', 'title', 'message', 'posted_by_name', 'is_pinned', 'created_at']