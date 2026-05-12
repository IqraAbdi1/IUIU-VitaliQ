from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import serializers
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.permissions import IsAuthenticated
from .models import Notification
from .models import User
from rest_framework.permissions import IsAuthenticated
from .models import Shift


class LoginSerializer(serializers.Serializer):
    reg_no = serializers.CharField(help_text="Your registration number e.g. 126-063061-00001")
    password = serializers.CharField(help_text="Your password")


@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    permission_classes = [AllowAny]
    @extend_schema(request=LoginSerializer)
    def post(self, request):
        reg_no = request.data.get('reg_no')
        password = request.data.get('password')

        try:
            user = User.objects.get(reg_no=reg_no)
        except User.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.check_password(password):
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        access = str(refresh.access_token)

        # Base response data
        response_data = {
            'access':        access,
            'refresh':       str(refresh),
            'role':          user.role,
            'username':      user.username,
            'reg_no':        user.reg_no,
            'is_first_login': user.is_first_login,
        }

        # Force password change on first login
        if user.is_first_login:
            response_data['redirect'] = '/change-password/'
            return Response(response_data)

        # Redirect based on role
        if user.role == 'DOCTOR':
            response_data['redirect'] = '/doctor/dashboard/'
        elif user.role == 'NURSE':
            response_data['redirect'] = '/nurse/dashboard/'
        elif user.role == 'LAB_ATTENDANT':
            response_data['redirect'] = '/lab/dashboard/'
        elif user.role == 'ADMIN':
            response_data['redirect'] = '/admin/dashboard/'
        else:
            response_data['redirect'] = '/patient/dashboard/'

        return Response(response_data)


class UserDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        return Response({
            'username':      user.username,
            'reg_no':        user.reg_no,
            'role':          user.role,
            'is_first_login': user.is_first_login,
        })
    


# ─────────────────────────────────────────────
# GET /api/users/notifications/
# All notifications for logged in user
# ─────────────────────────────────────────────
class NotificationListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        notifs = Notification.objects.filter(
            user=request.user
        ).order_by('-created_at')[:50]

        data = [
            {
                'id':                n.id,
                'message':           n.message,
                'notification_type': n.notification_type,
                'is_read':           n.is_read,
                'created_at':        n.created_at,
            }
            for n in notifs
        ]
        return Response(data)


# ─────────────────────────────────────────────
# PATCH /api/users/notifications/{id}/read/
# Mark a notification as read
# ─────────────────────────────────────────────
class MarkNotificationReadView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, notif_id):
        try:
            notif = Notification.objects.get(
                id=notif_id,
                user=request.user
            )
        except Notification.DoesNotExist:
            return Response(
                {'error': 'Notification not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        notif.is_read = True
        notif.save()
        return Response({'message': 'Marked as read'})

from .models import User, Notification, Shift
from django.utils import timezone

# ─────────────────────────────────────────────
# GET /api/users/shift/
# Returns today's active shift for logged in staff
# ─────────────────────────────────────────────
class ShiftView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.now().date()

        try:
            shift = Shift.objects.get(
                staff     = request.user,
                date      = today,
                is_active = True,
            )
            return Response({
                'shift_type':      shift.get_shift_type_display(),
                'start_time':      shift.start_time.strftime('%H:%M'),
                'end_time':        shift.end_time.strftime('%H:%M'),
                'supervisor_name': shift.supervisor.username if shift.supervisor else 'No supervisor assigned',
                'date':            str(shift.date),
            })
        except Shift.DoesNotExist:
            # no shift assigned today — return empty
            return Response({
                'shift_type':      None,
                'start_time':      None,
                'end_time':        None,
                'supervisor_name': None,
                'date':            str(today),
            })


# ─────────────────────────────────────────────
# POST /api/users/shift/
# Admin assigns a shift to a staff member
# ─────────────────────────────────────────────
class AssignShiftView(APIView):

    def post(self, request):
        staff_reg_no    = request.data.get('staff_reg_no')
        shift_type      = request.data.get('shift_type')
        start_time      = request.data.get('start_time')
        end_time        = request.data.get('end_time')
        supervisor_reg  = request.data.get('supervisor_reg_no')
        date            = request.data.get('date', str(timezone.now().date()))

        if not all([staff_reg_no, shift_type, start_time, end_time]):
            return Response(
                {'error': 'staff_reg_no, shift_type, start_time, end_time are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            staff = User.objects.get(reg_no=staff_reg_no)
        except User.DoesNotExist:
            return Response({'error': 'Staff not found'}, status=status.HTTP_404_NOT_FOUND)

        supervisor = None
        if supervisor_reg:
            try:
                supervisor = User.objects.get(reg_no=supervisor_reg)
            except User.DoesNotExist:
                pass

        # deactivate any existing shift for this staff today
        Shift.objects.filter(staff=staff, date=date).update(is_active=False)

        shift = Shift.objects.create(
            staff      = staff,
            shift_type = shift_type,
            start_time = start_time,
            end_time   = end_time,
            supervisor = supervisor,
            date       = date,
        )

        return Response({
            'message':         'Shift assigned successfully',
            'shift_type':      shift.get_shift_type_display(),
            'start_time':      shift.start_time.strftime('%H:%M'),
            'end_time':        shift.end_time.strftime('%H:%M'),
            'supervisor_name': supervisor.username if supervisor else None,
            'date':            str(shift.date),
        }, status=status.HTTP_201_CREATED)