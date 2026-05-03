from django.urls import path
from .views import (
    SymptomListView,
    CreateVisitView,
    QueueView,
    VisitDetailView,
)

urlpatterns = [
    path('symptoms/',        SymptomListView.as_view(),  name='symptom-list'),
    path('visits/',          CreateVisitView.as_view(),  name='create-visit'),
    path('queue/',           QueueView.as_view(),        name='queue'),
    path('visits/<int:visit_id>/', VisitDetailView.as_view(), name='visit-detail'),
]