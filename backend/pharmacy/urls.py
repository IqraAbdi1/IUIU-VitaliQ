from django.urls import path
from .views import (
    StockListView,
    RestockRecommendationsView,
    UpdateStockView,
    PendingPrescriptionsView,
    DispensePrescriptionView,
)

urlpatterns = [
    path('stock/',                              StockListView.as_view(),              name='stock-list'),
    path('recommendations/',                    RestockRecommendationsView.as_view(), name='restock-recommendations'),
    path('stock/<int:medicine_id>/update/',     UpdateStockView.as_view(),            name='update-stock'),
    path('prescriptions/pending/',              PendingPrescriptionsView.as_view(),   name='pending-prescriptions'),
    path('prescriptions/<int:prescription_id>/dispense/', DispensePrescriptionView.as_view(), name='dispense-prescription'),
]