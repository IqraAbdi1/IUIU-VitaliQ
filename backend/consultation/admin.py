from django.contrib import admin
from .models import (
    Consultation, LabRequest, LabResult,
    Prescription, Announcement, LabTest
)
class LabRequestInline(admin.StackedInline):
    model  = LabRequest
    extra  = 0
    fields = ('tests_requested', 'notes_to_lab', 'status')


class PrescriptionInline(admin.TabularInline):
    model  = Prescription
    extra  = 1
    fields = ('medicine_name', 'dosage', 'duration', 'instructions', 'dispense_status')


class ConsultationAdmin(admin.ModelAdmin):
    list_display    = ('get_patient', 'doctor', 'get_severity', 'diagnosis', 'consulted_at')
    list_filter     = ('severity_override',)
    search_fields   = ('visit__patient__username', 'diagnosis')
    readonly_fields = ('consulted_at',)
    inlines         = [LabRequestInline, PrescriptionInline]

    def get_patient(self, obj):
        return obj.visit.patient.username
    get_patient.short_description = 'Patient'

    def get_severity(self, obj):
        return obj.get_severity()
    get_severity.short_description = 'Severity'


class LabRequestAdmin(admin.ModelAdmin):
    list_display  = ('get_patient', 'tests_requested', 'status', 'requested_at')
    list_filter   = ('status',)
    search_fields = ('consultation__visit__patient__username',)

    def get_patient(self, obj):
        return obj.consultation.visit.patient.username
    get_patient.short_description = 'Patient'


class LabResultAdmin(admin.ModelAdmin):
    list_display    = ('get_patient', 'lab_attendant', 'uploaded_at')
    search_fields   = ('lab_request__consultation__visit__patient__username',)
    readonly_fields = ('uploaded_at',)

    def get_patient(self, obj):
        return obj.lab_request.consultation.visit.patient.username
    get_patient.short_description = 'Patient'


class PrescriptionAdmin(admin.ModelAdmin):
    list_display    = ('medicine_name', 'get_patient', 'dosage',
                       'duration', 'dispense_status', 'prescribed_at')
    list_filter     = ('dispense_status',)
    search_fields   = ('medicine_name', 'consultation__visit__patient__username')
    readonly_fields = ('prescribed_at',)

    def get_patient(self, obj):
        return obj.consultation.visit.patient.username
    get_patient.short_description = 'Patient'



class AnnouncementAdmin(admin.ModelAdmin):
    list_display  = ('title', 'posted_by', 'is_pinned', 'created_at')
    list_filter   = ('is_pinned',)
    search_fields = ('title',)


@admin.register(LabTest)
class LabTestAdmin(admin.ModelAdmin):
    list_display  = ('name', 'unit', 'reference_range', 'input_type', 'is_active')
    list_editable = ('is_active',)
    list_filter   = ('input_type', 'is_active')
    search_fields = ('name',)

admin.site.register(Announcement, AnnouncementAdmin)
admin.site.register(Consultation, ConsultationAdmin)
admin.site.register(LabRequest,   LabRequestAdmin)
admin.site.register(LabResult,    LabResultAdmin)
admin.site.register(Prescription, PrescriptionAdmin)
