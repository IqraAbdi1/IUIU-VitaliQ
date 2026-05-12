from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    groups = models.ManyToManyField(
        'auth.Group',
        related_name='custom_user_set',
        blank=True,
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='custom_user_permissions_set',
        blank=True,
    )
    
    ROLE_CHOICES = (
        ('PATIENT', 'Patient'),
        ('DOCTOR', 'Doctor'),
        ('NURSE', 'Nurse'),
        ('LAB_ATTENDANT', 'Lab Attendant'),
        ('ADMIN', 'Admin'),
        ('PHARMACIST', 'Pharmacist'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='PATIENT')
    is_first_login = models.BooleanField(default=True)
    reg_no = models.CharField(max_length=30, unique=True, null=True, blank=True)

    def __str__(self):
        return f"{self.username} - {self.role}"
    


# ─────────────────────────────────────────────
# NOTIFICATION — system-wide, all users
# ─────────────────────────────────────────────
class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('QUEUE',        'Queue Update'),
        ('LAB_RESULT',   'Lab Result Ready'),
        ('PRESCRIPTION', 'Prescription Ready'),
        ('STOCK_ALERT',  'Stock Alert'),
        ('GENERAL',      'General'),
    ]

    user              = models.ForeignKey(
                            User,
                            on_delete=models.CASCADE,
                            related_name='notifications'
                        )
    message           = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES, default='GENERAL')
    is_read           = models.BooleanField(default=False)
    created_at        = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} — {self.notification_type} — {self.created_at.date()}"

    class Meta:
        ordering = ['-created_at']

from django.utils import timezone as tz

# ─────────────────────────────────────────────
# SHIFT — assigned by admin to staff
# ─────────────────────────────────────────────
class Shift(models.Model):
    SHIFT_CHOICES = [
        ('MORNING',   'Morning Shift'),
        ('AFTERNOON', 'Afternoon Shift'),
        ('NIGHT',     'Night Shift'),
    ]

    staff      = models.ForeignKey(
                    User,
                    on_delete=models.CASCADE,
                    related_name='shifts',
                    limit_choices_to={'role__in': ['DOCTOR', 'NURSE', 'LAB_ATTENDANT', 'ADMIN']}
                 )
    shift_type = models.CharField(max_length=10, choices=SHIFT_CHOICES, default='MORNING')
    start_time = models.TimeField()
    end_time   = models.TimeField()
    supervisor = models.ForeignKey(
                    User,
                    on_delete=models.SET_NULL,
                    null=True, blank=True,
                    related_name='supervised_shifts',
                    limit_choices_to={'role': 'DOCTOR'}
                 )
    date       = models.DateField(default=tz.now)
    is_active  = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.staff.username} — {self.get_shift_type_display()} — {self.date}"

    class Meta:
        ordering = ['-date', 'start_time']