
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
import sys, os
from consultation.models import Prescription

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from AI_ML.pharmacy_predictor import predict_disease_spikes, compute_demand_pressure, predict_restock

from .models import MedicineStock
from clinic_staff.models import ClinicStaff


# ─────────────────────────────────────────────
# GET /api/pharmacy/stock/
# Returns all medicines with current stock status
# ─────────────────────────────────────────────
class StockListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        medicines = MedicineStock.objects.all()
        data = [
            {
                'id':                 m.id,
                'medicine_name':      m.medicine_name,
                'quantity':           m.quantity,
                'unit':               m.unit,
                'low_stock_threshold': m.low_stock_threshold,
                'is_low_stock':       m.is_low_stock(),
                'is_out_of_stock':    m.is_out_of_stock(),
                'medical_condition':  m.medical_condition,
                'updated_at':         m.updated_at,
            }
            for m in medicines
        ]
        return Response(data)


# ─────────────────────────────────────────────
# GET /api/pharmacy/recommendations/
# Returns AI-powered restock recommendations
# ─────────────────────────────────────────────
class RestockRecommendationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Step 1 — get disease spike forecasts from trend model
        disease_forecasts = predict_disease_spikes()

        # Step 2 — get all medicines
        medicines = MedicineStock.objects.all()

        recommendations = []
        for m in medicines:
            # Step 3 — compute demand pressure from trend model
            pressure = compute_demand_pressure(
                m.medical_condition,
                disease_forecasts
            )

            # Step 4 — predict days to stockout
            medicine_data = {
                'current_stock':    m.quantity,
                'reorder_threshold': m.reorder_threshold,
                'avg_monthly_units': m.avg_monthly_units,
                'avg_monthly_rx':   m.avg_monthly_rx,
                'avg_duration':     m.avg_duration,
                'avg_frequency':    m.avg_frequency,
                'last_restocked':   m.last_restocked,
            }

            prediction = predict_restock(medicine_data, pressure)

            recommendations.append({
                'medicine_name':    m.medicine_name,
                'current_stock':    m.quantity,
                'unit':             m.unit,
                'urgency':          prediction['urgency'],
                'days_to_stockout': prediction['days_to_stockout'],
                'reorder_flag':     prediction['reorder_flag'],
                'daily_consumption': prediction['daily_consumption'],
                'demand_pressure':  prediction['demand_pressure'],
                'medical_condition': m.medical_condition,
            })

        # sort by urgency — critical first
        urgency_order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'OK': 3, 'UNKNOWN': 4}
        recommendations.sort(key=lambda x: urgency_order.get(x['urgency'], 4))

        return Response({
            'recommendations': recommendations,
            'disease_forecasts': disease_forecasts,
            'generated_at': timezone.now(),
        })


# ─────────────────────────────────────────────
# PATCH /api/pharmacy/stock/{id}/update/
# Pharmacist updates stock quantity
# ─────────────────────────────────────────────
class UpdateStockView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, medicine_id):
        try:
            medicine = MedicineStock.objects.get(id=medicine_id)
        except MedicineStock.DoesNotExist:
            return Response({'error': 'Medicine not found'}, status=404)

        quantity = request.data.get('quantity')
        if quantity is not None:
            medicine.quantity    = quantity
            medicine.last_restocked = timezone.now().date()
            medicine.save()

        return Response({
            'medicine_name': medicine.medicine_name,
            'quantity':      medicine.quantity,
            'updated_at':    medicine.updated_at,
        })


# ─────────────────────────────────────────────
# GET /api/pharmacy/prescriptions/pending/
# Returns all pending prescriptions for pharmacist
# ─────────────────────────────────────────────
class PendingPrescriptionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        prescriptions = Prescription.objects.filter(
            dispense_status='PENDING'
        ).select_related(
            'consultation__visit__patient',
            'consultation__visit'
        ).order_by('-prescribed_at')[:50]

        data = [
            {
                'id':             p.id,
                'medicine_name':  p.medicine_name,
                'dosage':         p.dosage,
                'duration':       p.duration,
                'instructions':   p.instructions,
                'patient_name':   p.consultation.visit.patient.username,
                'reg_no':         p.consultation.visit.patient.reg_no,
                'visit_id':       p.consultation.visit.id,
                'prescribed_at':  p.prescribed_at,
            }
            for p in prescriptions
        ]
        return Response(data)


# ─────────────────────────────────────────────
# PATCH /api/pharmacy/prescriptions/{id}/dispense/
# Pharmacist marks prescription as dispensed
# Also deducts from MedicineStock
# ─────────────────────────────────────────────
class DispensePrescriptionView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, prescription_id):
        try:
            prescription = Prescription.objects.get(id=prescription_id)
        except Prescription.DoesNotExist:
            return Response({'error': 'Prescription not found'}, status=404)

        if prescription.dispense_status == 'DISPENSED':
            return Response({'error': 'Already dispensed'}, status=400)

        # get pharmacist staff profile
        try:
            staff = ClinicStaff.objects.get(user=request.user)
            prescription.pharmacist = staff
        except ClinicStaff.DoesNotExist:
            pass

        prescription.dispense_status = 'DISPENSED'
        prescription.dispensed_at    = timezone.now()
        prescription.save()

        # deduct from stock if medicine exists
        try:
            stock = MedicineStock.objects.get(
                medicine_name__icontains=prescription.medicine_name
            )
            units_to_deduct = request.data.get('units_dispensed', 1)
            stock.quantity  = max(stock.quantity - int(units_to_deduct), 0)
            stock.save()
        except MedicineStock.DoesNotExist:
            pass  # medicine not in stock table — still dispense

        return Response({
            'id':             prescription.id,
            'medicine_name':  prescription.medicine_name,
            'dispense_status': prescription.dispense_status,
            'dispensed_at':   prescription.dispensed_at,
        })