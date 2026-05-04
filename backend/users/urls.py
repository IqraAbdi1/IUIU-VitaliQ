from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.LoginView.as_view(), name='login'),
    path('dashboard/', views.UserDashboardView.as_view(), name='dashboard'),
]
