from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

from .models import User


class LoginSerializer(serializers.Serializer):
    reg_no = serializers.CharField(help_text="Your registration number e.g. 126-063061-00001")
    password = serializers.CharField(help_text="Your password")


@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):

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