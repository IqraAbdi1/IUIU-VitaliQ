from rest_framework import serializers
from .models import PatientProfile, Symptom, Visit, VisitSymptom


class SymptomSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Symptom
        fields = ['id', 'name']


class VisitSymptomSerializer(serializers.ModelSerializer):
    symptom_name = serializers.CharField(source='symptom.name', read_only=True)

    class Meta:
        model  = VisitSymptom
        fields = ['id', 'symptom', 'symptom_name']


class VisitCreateSerializer(serializers.Serializer):
    reg_no         = serializers.CharField(help_text="Patient reg_no e.g. 126-063061-00001")
    symptoms       = serializers.ListField(
                        child=serializers.IntegerField(),
                        help_text="List of symptom IDs e.g. [1, 2, 3]"
                     )
    other_symptoms = serializers.CharField(required=False, allow_blank=True)

    def validate_reg_no(self, value):
        try:
            patient = PatientProfile.objects.get(reg_no=value)
            return value
        except PatientProfile.DoesNotExist:
            raise serializers.ValidationError(f"No patient found with reg_no '{value}'")

class VisitDetailSerializer(serializers.ModelSerializer):
    symptoms     = VisitSymptomSerializer(source='visit_symptoms', many=True, read_only=True)
    patient_name = serializers.CharField(source='patient.username', read_only=True)
    reg_no       = serializers.CharField(source='patient.reg_no', read_only=True)

    class Meta:
        model  = Visit
        fields = [
            'id', 'patient', 'patient_name', 'reg_no',
            'status', 'queue_position', 'queue_category',
            'symptoms', 'other_symptoms', 'date', 'created_at'
        ]


class QueueSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.username', read_only=True)
    reg_no       = serializers.CharField(source='patient.reg_no',   read_only=True)

    class Meta:
        model  = Visit
        fields = [
            'id', 'patient_name', 'reg_no',
            'queue_position', 'queue_category', 'status', 'created_at'
        ]