from django.db import models
from users.models import User
import datetime

# ------- University code -------
UNIVERSITY_CODE = '1'  # IUIU = 1

# ------- Fixed program codes -------
PROGRAM_CODES = {
    'CS':  '063061',
    'IT':  '063062',
    'SE':  '063063',
    'BIT': '063064',
    # Add more as needed
}

PROGRAM_CHOICES = [(k, k) for k in PROGRAM_CODES.keys()]

YEAR_CHOICES = [(str(i), f'Year {i}') for i in range(1, 6)]

PATIENT_TYPE_CHOICES = [
    ('STUDENT',          'Student'),
    ('UNIVERSITY_STAFF', 'University Staff'),
    ('CLINIC_STAFF',     'Clinic Staff'),
]

GENDER_CHOICES = [
    ('M', 'Male'),
    ('F', 'Female'),
]


def generate_reg_no(program):
    yy           = datetime.datetime.now().strftime('%y')
    uni_year     = f"{UNIVERSITY_CODE}{yy}"
    program_code = PROGRAM_CODES.get(program.upper(), None)

    if not program_code:
        raise ValueError(f"Unknown program: {program}. Add it to PROGRAM_CODES.")

    prefix   = f"{uni_year}-{program_code}-"
    existing = PatientProfile.objects.filter(
        reg_no__startswith=prefix
    ).values_list('reg_no', flat=True)

    if existing:
        last_num   = max(int(r.split('-')[-1]) for r in existing)
        unique_id  = str(last_num + 1).zfill(5)
    else:
        unique_id  = '00001'

    return f"{uni_year}-{program_code}-{unique_id}"


def generate_staff_reg_no():
    yy       = datetime.datetime.now().strftime('%y')
    uni_year = f"{UNIVERSITY_CODE}{yy}"
    prefix   = f"{uni_year}-063065-"

    existing = PatientProfile.objects.filter(
        reg_no__startswith=prefix
    ).values_list('reg_no', flat=True)

    if existing:
        last_num  = max(int(r.split('-')[-1]) for r in existing)
        unique_id = str(last_num + 1).zfill(5)
    else:
        unique_id = '00001'

    return f"{uni_year}-063065-{unique_id}"


class PatientProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        null=True, blank=True,
        related_name='patient_profile'
    )

    username          = models.CharField(max_length=150)
    gender            = models.CharField(max_length=1, choices=GENDER_CHOICES, null=True, blank=True)
    patient_type      = models.CharField(max_length=20, choices=PATIENT_TYPE_CHOICES, default='STUDENT')
    program           = models.CharField(max_length=20, choices=PROGRAM_CHOICES, null=True, blank=True)
    year              = models.CharField(max_length=1, choices=YEAR_CHOICES, null=True, blank=True)
    department        = models.CharField(max_length=100, null=True, blank=True)
    birthdate         = models.DateField(null=True, blank=True)
    phone_number      = models.CharField(max_length=20, null=True, blank=True)
    emergency_contact = models.CharField(max_length=20, null=True, blank=True)

    reg_no     = models.CharField(max_length=30, unique=True, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def get_age(self):
        """Calculate age from birthdate automatically"""
        if self.birthdate:
            today = datetime.date.today()
            return today.year - self.birthdate.year - (
                (today.month, today.day) < (self.birthdate.month, self.birthdate.day)
            )
        return 25  # default if no birthdate

    def save(self, *args, **kwargs):
        if self.patient_type == 'CLINIC_STAFF':
            if not self.user_id:
                try:
                    existing_user  = User.objects.get(username=self.username)
                    self.user      = existing_user
                    self.reg_no    = existing_user.reg_no
                except User.DoesNotExist:
                    raise ValueError(f"No user found for '{self.username}'. Register them as clinic staff first.")
        else:
            if not self.reg_no:
                if self.patient_type == 'STUDENT' and self.program:
                    self.reg_no = generate_reg_no(self.program)
                elif self.patient_type == 'UNIVERSITY_STAFF':
                    self.reg_no = generate_staff_reg_no()

            if not self.user_id and self.reg_no:
                from django.contrib.auth.hashers import make_password
                user = User.objects.create(
                    username   = self.username,
                    reg_no     = self.reg_no,
                    first_name = self.username.split(' ')[0] if ' ' in self.username else self.username,
                    last_name  = self.username.split(' ', 1)[1] if ' ' in self.username else '',
                    password   = make_password('123'),
                    role       = 'PATIENT',
                    is_first_login = True
                )
                self.user = user

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.username} | {self.reg_no}"

    class Meta:
        verbose_name        = 'Patient Profile'
        verbose_name_plural = 'Patient Profiles'


# ─────────────────────────────────────────
# SYMPTOM
# ─────────────────────────────────────────

class Symptom(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']


# ─────────────────────────────────────────
# VISIT
# ─────────────────────────────────────────

VISIT_STATUS_CHOICES = [
    ('WAITING',         'Waiting'),
    ('IN_CONSULTATION', 'In Consultation'),
    ('LAB',             'Lab'),
    ('PHARMACY',        'Pharmacy'),
    ('COMPLETE',        'Complete'),
]

SEVERITY_CHOICES = [
    ('SEVERE',   'Severe'),
    ('MODERATE', 'Moderate'),
    ('MINOR',    'Minor'),
]


class Visit(models.Model):
    patient        = models.ForeignKey(
                        PatientProfile,
                        on_delete=models.CASCADE,
                        related_name='visits'
                     )
    status         = models.CharField(max_length=20, choices=VISIT_STATUS_CHOICES, default='WAITING')
    queue_position = models.IntegerField(null=True, blank=True)
    queue_category = models.CharField(max_length=10, choices=SEVERITY_CHOICES, null=True, blank=True)
    other_symptoms = models.TextField(null=True, blank=True)
    date           = models.DateField(auto_now_add=True)
    created_at     = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Visit {self.id} — {self.patient.username} — {self.status}"

    class Meta:
        ordering = ['-created_at']


# ─────────────────────────────────────────
# VISITSYMPTOM
# ─────────────────────────────────────────

class VisitSymptom(models.Model):
    visit   = models.ForeignKey(Visit,    on_delete=models.CASCADE, related_name='visit_symptoms')
    symptom = models.ForeignKey(Symptom,  on_delete=models.CASCADE, related_name='symptom_visits')

    class Meta:
        unique_together = ('visit', 'symptom')

    def __str__(self):
        return f"Visit {self.visit.id} — {self.symptom.name}"