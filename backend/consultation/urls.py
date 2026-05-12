from django.urls import path
from .views import (
    CreateConsultationView,
    ConsultationDetailView,
    CreateLabRequestView,
    UploadLabResultView,
    GetLabResultView,
    CreatePrescriptionView,
    DoctorDashboardView,
    CreateAnnouncementView,
    LabDashboardView, 
    AdminDashboardView,
    LabTestListView,
    CompletedLabResultsView,
)

urlpatterns = [
    path('',                               CreateConsultationView.as_view(), name='create-consultation'),
    path('<int:visit_id>/',                ConsultationDetailView.as_view(), name='consultation-detail'),
    path('lab-request/',                   CreateLabRequestView.as_view(),   name='create-lab-request'),
    path('lab-result/',                    UploadLabResultView.as_view(),    name='upload-lab-result'),
    path('lab-result/<int:visit_id>/',     GetLabResultView.as_view(),       name='get-lab-result'),
    path('prescribe/',                     CreatePrescriptionView.as_view(), name='create-prescription'),
    path('announcements/',                 CreateAnnouncementView.as_view(), name='create-announcement'),
    path('doctor/dashboard/',              DoctorDashboardView.as_view(),    name='doctor-dashboard'),
    path('lab/dashboard/',                 LabDashboardView.as_view(),       name='lab-dashboard'),
    path('admin/dashboard/',               AdminDashboardView.as_view(),     name='admin-dashboard'),
    path('lab-tests/',                     LabTestListView.as_view(),         name='lab-tests'),
    path('lab-result/completed/',         CompletedLabResultsView.as_view(),  name='completed-lab-result'),
]
