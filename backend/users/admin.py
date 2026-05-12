from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Notification, Shift


class CustomUserAdmin(BaseUserAdmin):
    list_display = ('username', 'reg_no', 'email', 'role', 'is_first_login', 'is_staff')
    list_filter = ('role', 'is_staff')
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Clinic Info', {'fields': ('role', 'is_first_login', 'reg_no')}),
    )


class ShiftAdmin(admin.ModelAdmin):
    list_display = ('staff', 'shift_type', 'start_time', 'end_time', 'supervisor', 'date', 'is_active')
    list_filter = ('shift_type', 'is_active', 'date')
    search_fields = ('staff__username',)
    ordering = ('-date',)
    list_editable = ('is_active',)


class NotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'notification_type', 'message', 'is_read', 'created_at')
    list_filter = ('notification_type', 'is_read')
    search_fields = ('user__username',)


# Register models (each only once)
admin.site.register(User, CustomUserAdmin)
admin.site.register(Notification, NotificationAdmin)
admin.site.register(Shift, ShiftAdmin)