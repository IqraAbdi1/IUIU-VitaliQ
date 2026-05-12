import pandas as pd
import numpy as np
import joblib
import os

# ─────────────────────────────────────────────
# PATH SETUP
# ─────────────────────────────────────────────
BASE_DIR      = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH    = os.path.join(BASE_DIR, 'AI_ML', 'models', 'rf_model_synthetic.pkl')
FEATURES_PATH = os.path.join(BASE_DIR, 'AI_ML', 'models', 'feature_names.pkl')

# ─────────────────────────────────────────────
# LAZY LOAD
# ─────────────────────────────────────────────
_model         = None
_feature_names = None


def load_models():
    global _model, _feature_names
    if _model is None:
        _model = joblib.load(MODEL_PATH)
    if _feature_names is None:
        _feature_names = joblib.load(FEATURES_PATH)


# ─────────────────────────────────────────────
# SYMPTOM LIST — matches training data exactly
# ─────────────────────────────────────────────
ALL_SYMPTOMS = [
    'Fever', 'High Fever', 'Headache', 'Severe Headache',
    'Cough', 'Sore Throat', 'Body Aches', 'Fatigue',
    'Nausea', 'Vomiting', 'Diarrhea', 'Abdominal Pain',
    'Severe Abdominal Pain', 'Chest Pain', 'Shortness of Breath',
    'Dizziness', 'Rash', 'Back Pain', 'Neck Pain',
    'Eye Pain', 'Ear Pain', 'Joint Pain', 'Loss of Appetite',
    'Loss of Consciousness', 'Seizure', 'Confusion',
]

# label encoder mapping
LABELS = {0: 'MINOR', 1: 'MODERATE', 2: 'SEVERE'}


# ─────────────────────────────────────────────
# TEXT SYMPTOM DETECTION
# ─────────────────────────────────────────────
def check_free_text(free_text: str):
    """Scans free text for known symptoms — matched go to ML, rest go to doctor"""
    if not free_text:
        return [], free_text
    matched = []
    for symptom in ALL_SYMPTOMS:
        if symptom.lower() in free_text.lower():
            matched.append(symptom)
    return matched, free_text


# ─────────────────────────────────────────────
# MAIN PREDICTION FUNCTION
# ─────────────────────────────────────────────
def predict_severity(selected_symptoms, free_text=None,
                     age=25, gender='M', arrival_datetime=None):
    from datetime import datetime

    # ── load models lazily ──
    load_models()

    now = arrival_datetime or datetime.now()

    # ── extract free text symptoms ──
    extra_symptoms, doctor_note = check_free_text(free_text) if free_text else ([], free_text)
    all_symptoms = selected_symptoms + extra_symptoms

    # ── build feature values ──
    feature_values = {f: 0 for f in _feature_names}

    # time and demographic features
    feature_values.update({
        'age':             age,
        'arrivalmonth':    now.month,
        'arrivalday':      now.weekday(),
        'arrivalhour':     now.hour,
        'arrivalhour_bin': now.hour // 4,
        'gender_Male':     1 if gender == 'M' else 0,
    })

    # ── activate symptom features ──
    for symptom in all_symptoms:
        if symptom in feature_values:
            feature_values[symptom] = 1

    # ── build input dataframe ──
    input_vector = [feature_values[f] for f in _feature_names]
    input_df     = pd.DataFrame([input_vector], columns=_feature_names)

    # ── predict ──
    prediction = _model.predict(input_df)
    raw        = prediction[0]

    # handle both string and integer predictions
    if isinstance(raw, str):
        severity = raw.upper()
    else:
        severity = LABELS.get(int(raw), 'MINOR')

    return {
        'severity':    severity,    # MINOR, MODERATE, SEVERE
        'doctor_note': doctor_note
    }