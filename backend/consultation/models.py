from django.db import models
from patients.models import Visit
from clinic_staff.models import ClinicStaff

SEVERITY_CHOICES = [
    ('SEVERE',   'Severe'),
    ('MODERATE', 'Moderate'),
    ('MINOR',    'Minor'),
]

DISPENSE_STATUS_CHOICES = [
    ('PENDING',   'Pending'),
    ('DISPENSED', 'Dispensed'),
]

LAB_STATUS_CHOICES = [
    ('PENDING',  'Pending'),
    ('COMPLETE', 'Complete'),
]


# ─────────────────────────────────────────────
# CONSULTATION — doctor fills this
# ─────────────────────────────────────────────
class Consultation(models.Model):
    visit              = models.OneToOneField(
                            Visit,
                            on_delete=models.CASCADE,
                            related_name='consultation'
                         )
    doctor             = models.ForeignKey(
                            ClinicStaff,
                            on_delete=models.SET_NULL,
                            null=True,
                            related_name='consultations'
                         )
    clinical_notes     = models.TextField(null=True, blank=True)
    diagnosis          = models.TextField(null=True, blank=True)
    severity_override  = models.CharField(
                            max_length=10,
                            choices=SEVERITY_CHOICES,
                            null=True, blank=True
                         )

    # vitals — optional, recorded during consultation
    bp_systolic        = models.IntegerField(null=True, blank=True)
    bp_diastolic       = models.IntegerField(null=True, blank=True)
    temperature        = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    weight             = models.DecimalField(max_digits=5, decimal_places=1, null=True, blank=True)
    height             = models.DecimalField(max_digits=5, decimal_places=1, null=True, blank=True)

    consulted_at       = models.DateTimeField(auto_now_add=True)

    def get_severity(self):
        return self.severity_override or self.visit.queue_category

    def __str__(self):
        return f"Consultation — {self.visit.patient.username} — {self.consulted_at.date()}"

    class Meta:
        ordering = ['-consulted_at']


# ─────────────────────────────────────────────
# LAB REQUEST — one request per consultation
# doctor types whatever tests he needs freely
# ─────────────────────────────────────────────
class LabRequest(models.Model):
    consultation  = models.OneToOneField(
                        Consultation,
                        on_delete=models.CASCADE,
                        related_name='lab_request'
                    )
    tests_requested = models.TextField(
                        help_text="Doctor types all tests needed e.g. Malaria RDT, FBC, Typhoid"
                    )
    notes_to_lab    = models.TextField(null=True, blank=True)
    status          = models.CharField(
                        max_length=10,
                        choices=LAB_STATUS_CHOICES,
                        default='PENDING'
                    )
    requested_at    = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Lab Request — {self.consultation.visit.patient.username} — {self.status}"

    class Meta:
        ordering = ['-requested_at']


# ─────────────────────────────────────────────
# LAB RESULT — lab attendant uploads one result
# for the whole lab request
# ─────────────────────────────────────────────
class LabResult(models.Model):
    lab_request   = models.OneToOneField(
                        LabRequest,
                        on_delete=models.CASCADE,
                        related_name='result'
                    )
    lab_attendant = models.ForeignKey(
                        ClinicStaff,
                        on_delete=models.SET_NULL,
                        null=True,
                        related_name='lab_results'
                    )
    result        = models.TextField(
                        help_text="Lab attendant writes all results here"
                    )
    result_file   = models.FileField(
                        upload_to='lab_results/',
                        null=True, blank=True
                    )
    uploaded_at   = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Result — {self.lab_request.consultation.visit.patient.username}"

    class Meta:
        ordering = ['-uploaded_at']


# ─────────────────────────────────────────────
# PRESCRIPTION — doctor writes medicines
# one row per medicine
# ─────────────────────────────────────────────
class Prescription(models.Model):
    consultation     = models.ForeignKey(
                            Consultation,
                            on_delete=models.CASCADE,
                            related_name='prescriptions'
                        )
    medicine_name    = models.CharField(max_length=200)
    dosage           = models.CharField(max_length=100)
    duration         = models.CharField(max_length=100)
    instructions     = models.TextField(null=True, blank=True)
    dispense_status  = models.CharField(
                            max_length=10,
                            choices=DISPENSE_STATUS_CHOICES,
                            default='PENDING'
                        )
    dispensed_at     = models.DateTimeField(null=True, blank=True)
    pharmacist       = models.ForeignKey(
                            ClinicStaff,
                            on_delete=models.SET_NULL,
                            null=True, blank=True,
                            related_name='dispensed_prescriptions'
                        )
    prescribed_at    = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.medicine_name} — {self.consultation.visit.patient.username}"

    class Meta:
        ordering = ['-prescribed_at']


# ─────────────────────────────────────────────
# ANNOUNCEMENT — clinic wide, posted by admin/doctor
# ─────────────────────────────────────────────
class Announcement(models.Model):
    title      = models.CharField(max_length=200)
    message    = models.TextField()
    posted_by  = models.ForeignKey(
                    ClinicStaff,
                    on_delete=models.SET_NULL,
                    null=True,
                    related_name='announcements'
                 )
    is_pinned  = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} — {self.created_at.date()}"

    class Meta:
        ordering = ['-is_pinned', '-created_at']


class LabTest(models.Model):
    INPUT_TYPES = [
        ('BOOLEAN', 'Positive/Negative'),
        ('NUMBER',  'Numeric value'),
        ('TEXT',    'Free text'),
    ]

    name            = models.CharField(max_length=100, unique=True)
    unit            = models.CharField(max_length=20,  blank=True, null=True)
    reference_range = models.CharField(max_length=50,  blank=True, null=True)
    input_type      = models.CharField(max_length=10,  choices=INPUT_TYPES, default='TEXT')
    is_active       = models.BooleanField(default=True)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']