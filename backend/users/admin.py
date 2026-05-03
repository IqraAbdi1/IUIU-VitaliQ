from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'reg_no', 'email', 'role', 'is_first_login', 'is_staff')
    list_filter = ('role', 'is_staff')
    fieldsets = UserAdmin.fieldsets + (
        ('Clinic Info', {'fields': ('role', 'is_first_login', 'reg_no')}),
    )


admin.site.register(User, CustomUserAdmin)