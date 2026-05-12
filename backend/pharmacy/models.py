from django.db import models
from clinic_staff.models import ClinicStaff

UNIT_CHOICES = [
    ('TABLETS',  'Tablets'),
    ('CAPSULES', 'Capsules'),
    ('BOTTLES',  'Bottles'),
    ('VIALS',    'Vials'),
    ('SACHETS',  'Sachets'),
]

class MedicineStock(models.Model):
    # ── basic info ──
    medicine_name       = models.CharField(max_length=200, unique=True)
    quantity            = models.IntegerField(default=0)
    unit                = models.CharField(max_length=20, choices=UNIT_CHOICES, default='TABLETS')
    medical_condition   = models.CharField(max_length=200, blank=True, help_text='Linked disease e.g. Malaria')

    # ── thresholds ──
    low_stock_threshold = models.IntegerField(default=50)
    reorder_threshold   = models.IntegerField(default=50, help_text='Reorder when stock falls below this')

    # ── ML model inputs ──
    avg_monthly_units   = models.FloatField(default=30.0, help_text='Average units dispensed per month')
    avg_monthly_rx      = models.FloatField(default=10.0, help_text='Average prescriptions per month')
    avg_duration        = models.FloatField(default=7.0,  help_text='Average prescription duration in days')
    avg_frequency       = models.FloatField(default=3.0,  help_text='Average doses per day')
    last_restocked      = models.DateField(null=True, blank=True, help_text='Date last restocked')

    # ── audit ──
    updated_by          = models.ForeignKey(
                            ClinicStaff, on_delete=models.SET_NULL,
                            null=True, blank=True, related_name='stock_updates'
                          )
    updated_at          = models.DateTimeField(auto_now=True)
    created_at          = models.DateTimeField(auto_now_add=True)

    def is_low_stock(self):
        return self.quantity <= self.low_stock_threshold

    def is_out_of_stock(self):
        return self.quantity == 0

    def compute_avg_monthly_units(self):
        """Auto-compute from real prescription history if available"""
        from consultation.models import Prescription
        from django.utils import timezone
        six_months_ago = timezone.now() - timezone.timedelta(days=180)
        count = Prescription.objects.filter(
            medicine_name__icontains=self.medicine_name,
            prescribed_at__gte=six_months_ago
        ).count()
        return round(count / 6, 1) if count > 0 else self.avg_monthly_units

    def __str__(self):
        return f"{self.medicine_name} — {self.quantity} {self.unit}"

    class Meta:
        ordering = ['medicine_name']