# VitalIQ: Smart Clinic Management System with ML Triage

VitalIQ digitizes the full clinical workflow at the IUIU Health Centre, from patient check-in to prescription dispensing. Two machine-learning components sit at its core: a **triage model** that ranks patients by urgency, and a **demand-forecasting pipeline** that tells the pharmacy what to restock before stock runs out.

Built as a final-year (capstone) project for the Bachelor of Computer Science at the Islamic University in Uganda.

## What it does

| Area | Features |
| :--- | :--- |
| **ML triage** | Patients report symptoms; a Random Forest classifier predicts severity (Minor / Moderate / Severe) to order the doctor's queue. Free-text symptoms are matched to known symptoms; anything unmatched is flagged for the doctor. |
| **Pharmacy forecasting** | Exponential Smoothing models forecast disease trends three months ahead. Forecasts are converted into demand pressure per medicine, and a restock model recommends what to reorder. |
| **Clinical workflow** | Patient profiles, visits, consultations, lab requests and results, prescriptions, announcements |
| **Roles and access** | JWT authentication with role-based dashboards for patients, doctors, nurses, lab attendants and admins, plus forced password change on first login |
| **API docs** | Interactive OpenAPI / Swagger documentation at `/api/docs/` |

## Architecture

```
Flutter app (web, mobile, desktop)
        |
        |  REST + JWT
        v
Django REST Framework API  --->  ML layer (backend/AI_ML)
        |                          - triage: Random Forest (scikit-learn)
        v                          - forecasting: Exponential Smoothing (statsmodels)
   PostgreSQL                      - restock recommendation (scikit-learn)
```

| Folder | Contents |
| :--- | :--- |
| `backend/` | Django REST API: `users`, `patients`, `consultation`, `pharmacy`, `clinic_staff` apps |
| `backend/AI_ML/` | Prediction code and the trained models the API loads at runtime |
| `ai_ml/` | Research notebook comparing triage models (Random Forest with SMOTE, neural network, BERT). The raw training data is not included because of its size. |
| `machine learning/` | Synthetic symptom dataset generator used to train the triage model |
| `frontend/` | Flutter client |

## Tech stack

| Tier | Technology |
| :--- | :--- |
| Frontend | Flutter (Dart) |
| Backend | Python, Django, Django REST Framework, SimpleJWT, drf-spectacular |
| Machine learning | scikit-learn, statsmodels, pandas, NumPy, imbalanced-learn (SMOTE) |
| Database | PostgreSQL |
| DevOps | Docker, Docker Compose |

## Getting started

### 1. Configure environment variables

Secrets are never committed. Copy the template and fill in your own values:

```bash
cp backend/.env.example backend/.env
```

Generate a Django secret key with:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 2a. Run with Docker (recommended)

```bash
docker compose up --build
```

The API runs at http://localhost:8000 and the API docs at http://localhost:8000/api/docs/.

### 2b. Or run the backend locally

Requires Python 3.11+ and a running PostgreSQL server that matches the `DB_*` values in `backend/.env`.

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### 3. Run the Flutter app

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

The app calls the API at `http://127.0.0.1:8000` (set in `frontend/lib/services/api_service.dart`).

## Team

- **Iqra Abdirizak Mohamed** ([@IqraAbdi1](https://github.com/IqraAbdi1))
- **Khalid Gurashi** ([@NullUmbra](https://github.com/NullUmbra))

Islamic University in Uganda, 2026
