from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import ClinicStaff


class ClinicStaffAdmin(admin.ModelAdmin):
    fields = ('username', 'staff_type', 'specialization',
              'phone_number', 'birthdate')

    list_display  = ('username', 'staff_id', 'staff_type', 'specialization', 'created_at')
    list_filter   = ('staff_type', 'specialization')
    search_fields = ('username', 'staff_id')

    readonly_fields = ('staff_id', 'user')

    def save_model(self, request, obj, form, change):
        obj.save()


admin.site.register(ClinicStaff, ClinicStaffAdmin)