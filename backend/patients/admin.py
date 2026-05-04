from django.contrib import admin
from .models import PatientProfile, Symptom, Visit, VisitSymptom


class PatientProfileAdmin(admin.ModelAdmin):
    fields          = ('username', 'gender', 'patient_type', 'program', 'year',
                       'department', 'birthdate', 'phone_number', 'emergency_contact')
    list_display    = ('username', 'reg_no', 'gender', 'program', 'year', 'patient_type', 'created_at')
    list_filter     = ('patient_type', 'program', 'year', 'gender')
    search_fields   = ('username', 'reg_no')
    readonly_fields = ('reg_no', 'user')

    def save_model(self, request, obj, form, change):
        obj.save()


class SymptomAdmin(admin.ModelAdmin):
    list_display  = ('name',)
    search_fields = ('name',)


class VisitAdmin(admin.ModelAdmin):
    list_display    = ('id', 'patient', 'status', 'queue_position', 'queue_category', 'date')
    list_filter     = ('status', 'queue_category')
    search_fields   = ('patient__username',)
    readonly_fields = ('queue_position', 'queue_category', 'date', 'created_at')


class VisitSymptomAdmin(admin.ModelAdmin):
    list_display  = ('visit', 'symptom')
    search_fields = ('visit__patient__username', 'symptom__name')


admin.site.register(PatientProfile, PatientProfileAdmin)
admin.site.register(Symptom, SymptomAdmin)
admin.site.register(Visit, VisitAdmin)
admin.site.register(VisitSymptom, VisitSymptomAdmin)