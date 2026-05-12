from django.urls import path
from .views import (
    LoginView,
    UserDashboardView,
    NotificationListView,
    MarkNotificationReadView,
    ShiftView,
    AssignShiftView,
)

urlpatterns = [
    path('login/',                              LoginView.as_view(),               name='login'),
    path('dashboard/',                          UserDashboardView.as_view(),        name='dashboard'),
    path('notifications/',                      NotificationListView.as_view(),     name='notifications'),
    path('notifications/<int:notif_id>/read/',  MarkNotificationReadView.as_view(), name='mark-read'),
    path('shift/',                              ShiftView.as_view(),                name='shift'),
    path('shift/assign/',                       AssignShiftView.as_view(),          name='assign-shift'),
]