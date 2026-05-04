from django.contrib.auth.hashers import make_password
from .models import User, PatientProfile, ClinicStaff, generate_student_id, generate_employee_id
import datetime

def register_new_patient(first_name, last_name, program, year_of_study, phone_number, emergency_contact):
    """
    Register a new patient (student) WITHOUT creating user first.
    System auto-generates ID and creates user in background.
    """
    current_year = datetime.datetime.now().year
    
    # 1. Generate the student ID
    generated_id = generate_student_id(program, current_year)
    
    # 2. Create the User in background
    user = User.objects.create(
        username=generated_id,
        first_name=first_name,
        last_name=last_name,
        password=make_password('123'),  # Default password
        role='PATIENT',
        is_first_login=True
    )
    
    # 3. Create the Patient Profile linked to that user
    patient = PatientProfile.objects.create(
        user=user,
        student_id=generated_id,
        program=program,
        year_of_study=year_of_study,
        phone_number=phone_number,
        emergency_contact=emergency_contact
    )
    
    return patient

def register_new_staff_patient(first_name, last_name, department, phone_number, emergency_contact):
    """
    Register a university staff member as patient
    """
    current_year = datetime.datetime.now().year
    
    # Generate staff patient ID
    last_staff = PatientProfile.objects.filter(
        staff_id__startswith=f"STF-{current_year}"
    ).order_by('-staff_id').first()
    
    if last_staff and last_staff.staff_id:
        last_number = int(last_staff.staff_id.split('-')[-1])
        new_number = last_number + 1
    else:
        new_number = 1
    
    generated_id = f"STF-{current_year}-{new_number:05d}"
    
    # Create User
    user = User.objects.create(
        username=generated_id,
        first_name=first_name,
        last_name=last_name,
        password=make_password('123'),
        role='PATIENT',
        is_first_login=True
    )
    
    # Create Patient Profile
    patient = PatientProfile.objects.create(
        user=user,
        staff_id=generated_id,
        program='STAFF',
        staff_department=department,
        phone_number=phone_number,
        emergency_contact=emergency_contact
    )
    
    return patient

def register_new_clinic_staff(first_name, last_name, staff_type, specialization, phone_number):
    """
    Register a clinic staff member (Doctor, Nurse, etc.)
    """
    current_year = datetime.datetime.now().year
    
    # Generate employee ID
    generated_id = generate_employee_id(staff_type, current_year)
    
    # Create User
    user = User.objects.create(
        username=generated_id,
        first_name=first_name,
        last_name=last_name,
        password=make_password('123'),
        role=staff_type,
        is_first_login=True
    )
    
    # Create Clinic Staff Profile
    staff = ClinicStaff.objects.create(
        user=user,
        employee_id=generated_id,
        staff_type=staff_type,
        specialization=specialization,
        phone_number=phone_number
    )
    
    return staff