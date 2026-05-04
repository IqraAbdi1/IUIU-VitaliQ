from django.db import models

# Create your models here.
from django.db import models
from users.models import User
import datetime

# ------- University code -------
UNIVERSITY_CODE = '1'  # IUIU = 1

# ------- Staff type codes -------
STAFF_TYPE_CODES = {
    'DOCTOR':        '010101',
    'NURSE':         '010102',
    'LAB_ATTENDANT': '010103',
    'ADMIN':         '010104',
}

STAFF_TYPE_CHOICES = [
    ('DOCTOR',        'Doctor'),
    ('NURSE',         'Nurse'),
    ('LAB_ATTENDANT', 'Lab Attendant'),
    ('ADMIN',         'Admin'),
]

SPECIALIZATION_CHOICES = [
    ('GENERAL_MEDICINE', 'General Medicine'),
    ('DENTAL',           'Dental'),
    ('PHARMACY',         'Pharmacy'),
    ('LABORATORY',       'Laboratory'),
    ('NURSING',          'Nursing'),
    ('ADMINISTRATION',   'Administration'),
]


def generate_staff_id(staff_type):
    """
    Format: 126-010101-00001
    1      = university code (IUIU)
    26     = last 2 digits of current year
    010101 = staff type code
    00001  = unique 5-digit number
    """
    yy = datetime.datetime.now().strftime('%y')
    uni_year = f"{UNIVERSITY_CODE}{yy}"
    type_code = STAFF_TYPE_CODES.get(staff_type.upper(), None)

    if not type_code:
        raise ValueError(f"Unknown staff type: {staff_type}. Add it to STAFF_TYPE_CODES.")

    prefix = f"{uni_year}-{type_code}-"
    existing = ClinicStaff.objects.filter(
        staff_id__startswith=prefix
    ).values_list('staff_id', flat=True)

    if existing:
        last_num = max(int(r.split('-')[-1]) for r in existing)
        unique_id = str(last_num + 1).zfill(5)
    else:
        unique_id = '00001'

    return f"{uni_year}-{type_code}-{unique_id}"


class ClinicStaff(models.Model):
    # --- Linked user (auto-created on save) ---
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        null=True, blank=True,
        related_name='clinicstaff_profile'
    )

    # --- Fields filled in by admin ---
    username       = models.CharField(max_length=150)
    staff_type     = models.CharField(max_length=20, choices=STAFF_TYPE_CHOICES)
    specialization = models.CharField(max_length=50, choices=SPECIALIZATION_CHOICES, null=True, blank=True)
    phone_number   = models.CharField(max_length=20, null=True, blank=True)
    birthdate      = models.DateField(null=True, blank=True)

    # --- Auto-generated ---
    staff_id       = models.CharField(max_length=30, unique=True, null=True, blank=True)
    created_at     = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        # Step 1 — Auto-generate staff_id on first save
        if not self.staff_id:
            self.staff_id = generate_staff_id(self.staff_type)

        # Step 2 — Auto-create User if not linked
        if not self.user_id and self.staff_id:
            from django.contrib.auth.hashers import make_password
            user = User.objects.create(
                username=self.username,
                reg_no=self.staff_id,
                first_name=self.username.split(' ')[0] if ' ' in self.username else self.username,
                last_name=self.username.split(' ', 1)[1] if ' ' in self.username else '',
                password=make_password('123'),
                role=self.staff_type,
                is_first_login=True
            )
            self.user = user

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.username} | {self.staff_id}"

    class Meta:
        verbose_name = 'Clinic Staff'
        verbose_name_plural = 'Clinic Staff'