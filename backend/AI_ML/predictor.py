'''import numpy as np
import os
import joblib

# ─── Path setup ───
BASE_DIR     = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH   = os.path.join(BASE_DIR, 'AI_ML', 'models', 'rf_model_smote.pkl')
ENCODER_PATH = os.path.join(BASE_DIR, 'AI_ML', 'models', 'label_encoder.pkl')

# ─── Lazy loaded — only when first prediction is made ───
_model         = None
_label_encoder = None


def load_models():
    global _model, _label_encoder
    if _model is None:
        _model = joblib.load(MODEL_PATH)
    if _label_encoder is None:
        _label_encoder = joblib.load(ENCODER_PATH)


# ─── Maps IUIU symptom names to model column names ───
SYMPTOM_MAP = {
    "Abdominal Pain":      "cc_abdominalpain",
    "Chest Pain":          "cc_chestpain",
    "Cough":               "cc_cough",
    "Fever":               "cc_fever",
    "Headache":            "cc_headache",
    "Diarrhea":            "cc_diarrhea",
    "Sore Throat":         "cc_sorethroat",
    "Shortness of Breath": "cc_shortnessofbreath",
    "Fatigue":             "cc_fatigue",
    "Rash":                "cc_rash",
    "Nausea":              "cc_nausea",
    "Vomiting":            "cc_nauseavomit",
    "Back Pain":           "cc_backpain",
    "Eye Pain":            "cc_eyepain",
    "Ear Pain":            "cc_earpain",
    "Neck Pain":           "cc_neckpain",
    "Body Aches":          "cc_generalizedbodyaches",
    "Dizziness":           "cc_dizziness",
    "Joint Pain":          "cc_pain",
    "Loss of Appetite":    "cc_fatigue",
}

# ─── All 207 features in exact training order ───
ALL_FEATURES = [
    'age', 'arrivalmonth', 'arrivalday', 'arrivalhour_bin',
    'cc_abdominalcramping', 'cc_abdominaldistention', 'cc_abdominalpain',
    'cc_abdominalpainpregnant', 'cc_abnormallab', 'cc_abscess',
    'cc_addictionproblem', 'cc_agitation', 'cc_alcoholintoxication',
    'cc_alcoholproblem', 'cc_allergicreaction', 'cc_alteredmentalstatus',
    'cc_animalbite', 'cc_ankleinjury', 'cc_anklepain', 'cc_anxiety',
    'cc_arminjury', 'cc_armpain', 'cc_armswelling', 'cc_assaultvictim',
    'cc_asthma', 'cc_backpain', 'cc_bleeding/bruising', 'cc_blurredvision',
    'cc_bodyfluidexposure', 'cc_breastpain', 'cc_breathingdifficulty',
    'cc_breathingproblem', 'cc_burn', 'cc_cardiacarrest', 'cc_cellulitis',
    'cc_chestpain', 'cc_chesttightness', 'cc_chills', 'cc_coldlikesymptoms',
    'cc_confusion', 'cc_conjunctivitis', 'cc_constipation', 'cc_cough',
    'cc_cyst', 'cc_decreasedbloodsugar-symptomatic', 'cc_dehydration',
    'cc_dentalpain', 'cc_depression', 'cc_detoxevaluation', 'cc_diarrhea',
    'cc_dizziness', 'cc_drug/alcoholassessment', 'cc_drugproblem',
    'cc_dyspnea', 'cc_dysuria', 'cc_earpain', 'cc_earproblem', 'cc_edema',
    'cc_elbowpain', 'cc_elevatedbloodsugar-nosymptoms',
    'cc_elevatedbloodsugar-symptomatic', 'cc_emesis', 'cc_epigastricpain',
    'cc_epistaxis', 'cc_exposuretostd', 'cc_extremitylaceration',
    'cc_extremityweakness', 'cc_eyeinjury', 'cc_eyepain', 'cc_eyeproblem',
    'cc_eyeredness', 'cc_facialinjury', 'cc_faciallaceration', 'cc_facialpain',
    'cc_facialswelling', 'cc_fall', 'cc_fall>65', 'cc_fatigue',
    'cc_femaleguproblem', 'cc_fever', 'cc_fever-75yearsorolder',
    'cc_fever-9weeksto74years', 'cc_feverimmunocompromised', 'cc_fingerinjury',
    'cc_fingerpain', 'cc_fingerswelling', 'cc_flankpain',
    'cc_follow-upcellulitis', 'cc_footinjury', 'cc_footpain', 'cc_footswelling',
    'cc_foreignbodyineye', 'cc_fulltrauma', 'cc_generalizedbodyaches',
    'cc_gibleeding', 'cc_giproblem', 'cc_groinpain', 'cc_hallucinations',
    'cc_handinjury', 'cc_handpain', 'cc_headache',
    'cc_headache-newonsetornewsymptoms', 'cc_headache-recurrentorknowndxmigraines',
    'cc_headachere-evaluation', 'cc_headinjury', 'cc_headlaceration',
    'cc_hematuria', 'cc_hemoptysis', 'cc_hippain', 'cc_homicidal',
    'cc_hyperglycemia', 'cc_hypertension', 'cc_hypotension', 'cc_influenza',
    'cc_ingestion', 'cc_insectbite', 'cc_irregularheartbeat', 'cc_jawpain',
    'cc_jointswelling', 'cc_kneeinjury', 'cc_kneepain', 'cc_laceration',
    'cc_leginjury', 'cc_legpain', 'cc_legswelling', 'cc_lethargy',
    'cc_lossofconsciousness', 'cc_maleguproblem', 'cc_mass',
    'cc_medicalproblem', 'cc_medicalscreening', 'cc_medicationproblem',
    'cc_medicationrefill', 'cc_migraine', 'cc_modifiedtrauma',
    'cc_motorcyclecrash', 'cc_motorvehiclecrash', 'cc_multiplefalls',
    'cc_nasalcongestion', 'cc_nausea', 'cc_nearsyncope', 'cc_neckpain',
    'cc_neurologicproblem', 'cc_numbness', 'cc_oralswelling', 'cc_otalgia',
    'cc_other', 'cc_overdose-accidental', 'cc_overdose-intentional', 'cc_pain',
    'cc_palpitations', 'cc_panicattack', 'cc_pelvicpain', 'cc_poisoning',
    'cc_post-opproblem', 'cc_psychiatricevaluation', 'cc_psychoticsymptoms',
    'cc_rapidheartrate', 'cc_rash', 'cc_rectalbleeding', 'cc_rectalpain',
    'cc_respiratorydistress', 'cc_ribinjury', 'cc_ribpain',
    'cc_seizure-newonset', 'cc_seizure-priorhxof', 'cc_seizures',
    'cc_shortnessofbreath', 'cc_shoulderinjury', 'cc_shoulderpain',
    'cc_sicklecellpain', 'cc_sinusproblem', 'cc_skinirritation',
    'cc_skinproblem', 'cc_sorethroat', 'cc_stdcheck', 'cc_strokealert',
    'cc_suicidal', 'cc_suture/stapleremoval', 'cc_swallowedforeignbody',
    'cc_syncope', 'cc_tachycardia', 'cc_testiclepain', 'cc_thumbinjury',
    'cc_tickremoval', 'cc_toeinjury', 'cc_toepain', 'cc_trauma',
    'cc_unresponsive', 'cc_uri', 'cc_urinaryfrequency', 'cc_urinaryretention',
    'cc_urinarytractinfection', 'cc_vaginalbleeding', 'cc_vaginaldischarge',
    'cc_vaginalpain', 'cc_weakness', 'cc_wheezing', 'cc_withdrawal-alcohol',
    'cc_woundcheck', 'cc_woundinfection', 'cc_woundre-evaluation',
    'cc_wristinjury', 'cc_wristpain', 'gender_Male', 'dep_name_B', 'dep_name_C',
]


def check_free_text(free_text: str):
    """Scans free text for known symptoms → matched go to ML, rest go to doctor"""
    if not free_text:
        return [], free_text
    matched = []
    for iuiu_name in SYMPTOM_MAP.keys():
        if iuiu_name.lower() in free_text.lower():
            matched.append(iuiu_name)
    return matched, free_text


def predict_severity(selected_symptoms: list, free_text: str = None,
                     age: int = 25, gender: str = 'M',
                     arrival_datetime=None) -> dict:
    """
    Input:
        selected_symptoms : ['Fever', 'Cough']
        free_text         : "my left eye itches"
        age               : patient age (from birthdate)
        gender            : 'M' or 'F'
        arrival_datetime  : visit created_at datetime
    Output:
        {
          'severity'   : 'MODERATE',
          'doctor_note': 'my left eye itches'
        }
    """
    from datetime import datetime

    # ─── load models lazily ───
    load_models()

    # ─── arrival time features ───
    now              = arrival_datetime or datetime.now()
    arrival_month    = now.month
    arrival_day      = now.weekday()   # 0=Monday
    arrival_hour_bin = now.hour // 4   # 0-5 bins

    # ─── free text check ───
    extra_symptoms = []
    doctor_note    = free_text
    if free_text:
        extra_symptoms, doctor_note = check_free_text(free_text)

    # ─── combine all symptoms ───
    all_symptoms = selected_symptoms + extra_symptoms
    mapped       = [SYMPTOM_MAP.get(s) for s in all_symptoms if SYMPTOM_MAP.get(s)]

    # ─── build input vector ───
    feature_values = {
        'age':             age,
        'arrivalmonth':    arrival_month,
        'arrivalday':      arrival_day,
        'arrivalhour_bin': arrival_hour_bin,
        'gender_Male':     1 if gender == 'M' else 0,
        'dep_name_B':      0,  # not applicable for IUIU
        'dep_name_C':      0,  # not applicable for IUIU
    }

    # symptom columns
    for feature in ALL_FEATURES:
        if feature not in feature_values:
            feature_values[feature] = 1 if feature in mapped else 0

    # build final ordered vector
    input_vector = [feature_values.get(f, 0) for f in ALL_FEATURES]
    input_array  = np.array(input_vector).reshape(1, -1)

    # ─── predict ───
    prediction = _model.predict(input_array)
    prediction = _model.predict(input_array)
    print("RAW PREDICTION:", prediction, type(prediction[0]))
    severity   = _label_encoder.inverse_transform(prediction)[0].upper()

    return {
        'severity':    severity,   # MINOR, MODERATE, SEVERE
        'doctor_note': doctor_note
    }'''


import numpy as np
import pandas as pd
import os
import joblib

# ─────────────────────────────────────────────
# PATH SETUP
# ─────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, 'AI_ML', 'models', 'rf_model.pkl')

# ─────────────────────────────────────────────
# LAZY LOAD
# ─────────────────────────────────────────────
_model = None


def load_models():
    global _model
    if _model is None:
        _model = joblib.load(MODEL_PATH)


# ─────────────────────────────────────────────
# SYMPTOM MAPPING
# ─────────────────────────────────────────────
SYMPTOM_MAP = {
    "Abdominal Pain":      "cc_abdominalpain",
    "Chest Pain":          "cc_chestpain",
    "Cough":               "cc_cough",
    "Fever":               "cc_fever",
    "Headache":            "cc_headache",
    "Diarrhea":            "cc_diarrhea",
    "Sore Throat":         "cc_sorethroat",
    "Shortness of Breath": "cc_shortnessofbreath",
    "Fatigue":             "cc_fatigue",
    "Rash":                "cc_rash",
    "Nausea":              "cc_nausea",
    "Vomiting":            "cc_nauseavomit",
    "Back Pain":           "cc_backpain",
    "Eye Pain":            "cc_eyepain",
    "Ear Pain":            "cc_earpain",
    "Neck Pain":           "cc_neckpain",
    "Body Aches":          "cc_generalizedbodyaches",
    "Dizziness":           "cc_dizziness",
    "Joint Pain":          "cc_pain",
    "Loss of Appetite":    "cc_fatigue",
}


# ─────────────────────────────────────────────
# FEATURE ORDER (MUST MATCH TRAINING)
# ─────────────────────────────────────────────
ALL_FEATURES = [
    'age','arrivalmonth','arrivalday','arrivalhour_bin',
    'cc_abdominalcramping','cc_abdominaldistention','cc_abdominalpain',
    'cc_abdominalpainpregnant','cc_abnormallab','cc_abscess',
    'cc_addictionproblem','cc_agitation','cc_alcoholintoxication',
    'cc_alcoholproblem','cc_allergicreaction','cc_alteredmentalstatus',
    'cc_animalbite','cc_ankleinjury','cc_anklepain','cc_anxiety',
    'cc_arminjury','cc_armpain','cc_armswelling','cc_assaultvictim',
    'cc_asthma','cc_backpain','cc_bleeding/bruising','cc_blurredvision',
    'cc_bodyfluidexposure','cc_breastpain','cc_breathingdifficulty',
    'cc_breathingproblem','cc_burn','cc_cardiacarrest','cc_cellulitis',
    'cc_chestpain','cc_chesttightness','cc_chills','cc_coldlikesymptoms',
    'cc_confusion','cc_conjunctivitis','cc_constipation','cc_cough',
    'cc_cyst','cc_decreasedbloodsugar-symptomatic','cc_dehydration',
    'cc_dentalpain','cc_depression','cc_detoxevaluation','cc_diarrhea',
    'cc_dizziness','cc_drug/alcoholassessment','cc_drugproblem',
    'cc_dyspnea','cc_dysuria','cc_earpain','cc_earproblem','cc_edema',
    'cc_elbowpain','cc_elevatedbloodsugar-nosymptoms',
    'cc_elevatedbloodsugar-symptomatic','cc_emesis','cc_epigastricpain',
    'cc_epistaxis','cc_exposuretostd','cc_extremitylaceration',
    'cc_extremityweakness','cc_eyeinjury','cc_eyepain','cc_eyeproblem',
    'cc_eyeredness','cc_facialinjury','cc_faciallaceration','cc_facialpain',
    'cc_facialswelling','cc_fall','cc_fall>65','cc_fatigue',
    'cc_femaleguproblem','cc_fever','cc_fever-75yearsorolder',
    'cc_fever-9weeksto74years','cc_feverimmunocompromised','cc_fingerinjury',
    'cc_fingerpain','cc_fingerswelling','cc_flankpain',
    'cc_follow-upcellulitis','cc_footinjury','cc_footpain','cc_footswelling',
    'cc_foreignbodyineye','cc_fulltrauma','cc_generalizedbodyaches',
    'cc_gibleeding','cc_giproblem','cc_groinpain','cc_hallucinations',
    'cc_handinjury','cc_handpain','cc_headache',
    'cc_headache-newonsetornewsymptoms',
    'cc_headache-recurrentorknowndxmigraines',
    'cc_headachere-evaluation','cc_headinjury','cc_headlaceration',
    'cc_hematuria','cc_hemoptysis','cc_hippain','cc_homicidal',
    'cc_hyperglycemia','cc_hypertension','cc_hypotension','cc_influenza',
    'cc_ingestion','cc_insectbite','cc_irregularheartbeat','cc_jawpain',
    'cc_jointswelling','cc_kneeinjury','cc_kneepain','cc_laceration',
    'cc_leginjury','cc_legpain','cc_legswelling','cc_lethargy',
    'cc_lossofconsciousness','cc_maleguproblem','cc_mass',
    'cc_medicalproblem','cc_medicalscreening','cc_medicationproblem',
    'cc_medicationrefill','cc_migraine','cc_modifiedtrauma',
    'cc_motorcyclecrash','cc_motorvehiclecrash','cc_multiplefalls',
    'cc_nasalcongestion','cc_nausea','cc_nearsyncope','cc_neckpain',
    'cc_neurologicproblem','cc_numbness','cc_oralswelling','cc_otalgia',
    'cc_other','cc_overdose-accidental','cc_overdose-intentional','cc_pain',
    'cc_palpitations','cc_panicattack','cc_pelvicpain','cc_poisoning',
    'cc_post-opproblem','cc_psychiatricevaluation','cc_psychoticsymptoms',
    'cc_rapidheartrate','cc_rash','cc_rectalbleeding','cc_rectalpain',
    'cc_respiratorydistress','cc_ribinjury','cc_ribpain',
    'cc_seizure-newonset','cc_seizure-priorhxof','cc_seizures',
    'cc_shortnessofbreath','cc_shoulderinjury','cc_shoulderpain',
    'cc_sicklecellpain','cc_sinusproblem','cc_skinirritation',
    'cc_skinproblem','cc_sorethroat','cc_stdcheck','cc_strokealert',
    'cc_suicidal','cc_suture/stapleremoval','cc_swallowedforeignbody',
    'cc_syncope','cc_tachycardia','cc_testiclepain','cc_thumbinjury',
    'cc_tickremoval','cc_toeinjury','cc_toepain','cc_trauma',
    'cc_unresponsive','cc_uri','cc_urinaryfrequency','cc_urinaryretention',
    'cc_urinarytractinfection','cc_vaginalbleeding','cc_vaginaldischarge',
    'cc_vaginalpain','cc_weakness','cc_wheezing','cc_withdrawal-alcohol',
    'cc_woundcheck','cc_woundinfection','cc_woundre-evaluation',
    'cc_wristinjury','cc_wristpain','gender_Male','dep_name_B','dep_name_C'
]


# ─────────────────────────────────────────────
# TEXT SYMPTOM DETECTION
# ─────────────────────────────────────────────
def check_free_text(free_text: str):
    if not free_text:
        return [], free_text
    matched = []
    for name in SYMPTOM_MAP:
        if name.lower() in free_text.lower():
            matched.append(name)
    return matched, free_text


# ─────────────────────────────────────────────
# MAIN PREDICTION FUNCTION
# ─────────────────────────────────────────────
def predict_severity(selected_symptoms, free_text=None,
                     age=25, gender='M', arrival_datetime=None):
    from datetime import datetime

    # ── load model lazily ──
    load_models()

    now = arrival_datetime or datetime.now()

    # ── extract symptoms ──
    extra_symptoms, doctor_note = check_free_text(free_text) if free_text else ([], free_text)
    all_symptoms = selected_symptoms + extra_symptoms
    mapped = [SYMPTOM_MAP.get(s) for s in all_symptoms if SYMPTOM_MAP.get(s)]

    # ── build feature values ──
    feature_values = {f: 0 for f in ALL_FEATURES}
    feature_values.update({
        'age':             age,
        'arrivalmonth':    now.month,
        'arrivalday':      now.weekday(),
        'arrivalhour_bin': now.hour // 4,
        'gender_Male':     1 if gender == 'M' else 0,
        'dep_name_B':      0,
        'dep_name_C':      0,
    })

    # ── activate symptom features ──
    for f in mapped:
        if f in feature_values:
            feature_values[f] = 1

    # ── build input dataframe ──
    input_vector = [feature_values[f] for f in ALL_FEATURES]
    input_df     = pd.DataFrame([input_vector], columns=ALL_FEATURES)

    # ── predict — RF returns string directly ──
    prediction = _model.predict(input_df)
    severity   = prediction[0].upper()

    return {
        'severity':    severity,
        'doctor_note': doctor_note
    }


''' this code under is a working one that loades rf with smote
import numpy as np
import pandas as pd
import os
import joblib

BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, 'AI_ML', 'models', 'rf_model_smote.pkl')

_model = None


def load_models():
    global _model
    if _model is None:
        _model = joblib.load(MODEL_PATH)


SYMPTOM_MAP = {
    "Abdominal Pain":      "cc_abdominalpain",
    "Chest Pain":          "cc_chestpain",
    "Cough":               "cc_cough",
    "Fever":               "cc_fever",
    "Headache":            "cc_headache",
    "Diarrhea":            "cc_diarrhea",
    "Sore Throat":         "cc_sorethroat",
    "Shortness of Breath": "cc_shortnessofbreath",
    "Fatigue":             "cc_fatigue",
    "Rash":                "cc_rash",
    "Nausea":              "cc_nausea",
    "Vomiting":            "cc_nauseavomit",
    "Back Pain":           "cc_backpain",
    "Eye Pain":            "cc_eyepain",
    "Ear Pain":            "cc_earpain",
    "Neck Pain":           "cc_neckpain",
    "Body Aches":          "cc_generalizedbodyaches",
    "Dizziness":           "cc_dizziness",
    "Joint Pain":          "cc_pain",
    "Loss of Appetite":    "cc_fatigue",
}


ALL_FEATURES = [
    'age','arrivalmonth','arrivalday','arrivalhour_bin',
    'cc_abdominalcramping','cc_abdominaldistention','cc_abdominalpain',
    'cc_abdominalpainpregnant','cc_abnormallab','cc_abscess',
    'cc_addictionproblem','cc_agitation','cc_alcoholintoxication',
    'cc_alcoholproblem','cc_allergicreaction','cc_alteredmentalstatus',
    'cc_animalbite','cc_ankleinjury','cc_anklepain','cc_anxiety',
    'cc_arminjury','cc_armpain','cc_armswelling','cc_assaultvictim',
    'cc_asthma','cc_backpain','cc_bleeding/bruising','cc_blurredvision',
    'cc_bodyfluidexposure','cc_breastpain','cc_breathingdifficulty',
    'cc_breathingproblem','cc_burn','cc_cardiacarrest','cc_cellulitis',
    'cc_chestpain','cc_chesttightness','cc_chills','cc_coldlikesymptoms',
    'cc_confusion','cc_conjunctivitis','cc_constipation','cc_cough',
    'cc_cyst','cc_decreasedbloodsugar-symptomatic','cc_dehydration',
    'cc_dentalpain','cc_depression','cc_detoxevaluation','cc_diarrhea',
    'cc_dizziness','cc_drug/alcoholassessment','cc_drugproblem',
    'cc_dyspnea','cc_dysuria','cc_earpain','cc_earproblem','cc_edema',
    'cc_elbowpain','cc_elevatedbloodsugar-nosymptoms',
    'cc_elevatedbloodsugar-symptomatic','cc_emesis','cc_epigastricpain',
    'cc_epistaxis','cc_exposuretostd','cc_extremitylaceration',
    'cc_extremityweakness','cc_eyeinjury','cc_eyepain','cc_eyeproblem',
    'cc_eyeredness','cc_facialinjury','cc_faciallaceration','cc_facialpain',
    'cc_facialswelling','cc_fall','cc_fall>65','cc_fatigue',
    'cc_femaleguproblem','cc_fever','cc_fever-75yearsorolder',
    'cc_fever-9weeksto74years','cc_feverimmunocompromised','cc_fingerinjury',
    'cc_fingerpain','cc_fingerswelling','cc_flankpain',
    'cc_follow-upcellulitis','cc_footinjury','cc_footpain','cc_footswelling',
    'cc_foreignbodyineye','cc_fulltrauma','cc_generalizedbodyaches',
    'cc_gibleeding','cc_giproblem','cc_groinpain','cc_hallucinations',
    'cc_handinjury','cc_handpain','cc_headache',
    'cc_headache-newonsetornewsymptoms',
    'cc_headache-recurrentorknowndxmigraines',
    'cc_headachere-evaluation','cc_headinjury','cc_headlaceration',
    'cc_hematuria','cc_hemoptysis','cc_hippain','cc_homicidal',
    'cc_hyperglycemia','cc_hypertension','cc_hypotension','cc_influenza',
    'cc_ingestion','cc_insectbite','cc_irregularheartbeat','cc_jawpain',
    'cc_jointswelling','cc_kneeinjury','cc_kneepain','cc_laceration',
    'cc_leginjury','cc_legpain','cc_legswelling','cc_lethargy',
    'cc_lossofconsciousness','cc_maleguproblem','cc_mass',
    'cc_medicalproblem','cc_medicalscreening','cc_medicationproblem',
    'cc_medicationrefill','cc_migraine','cc_modifiedtrauma',
    'cc_motorcyclecrash','cc_motorvehiclecrash','cc_multiplefalls',
    'cc_nasalcongestion','cc_nausea','cc_nearsyncope','cc_neckpain',
    'cc_neurologicproblem','cc_numbness','cc_oralswelling','cc_otalgia',
    'cc_other','cc_overdose-accidental','cc_overdose-intentional','cc_pain',
    'cc_palpitations','cc_panicattack','cc_pelvicpain','cc_poisoning',
    'cc_post-opproblem','cc_psychiatricevaluation','cc_psychoticsymptoms',
    'cc_rapidheartrate','cc_rash','cc_rectalbleeding','cc_rectalpain',
    'cc_respiratorydistress','cc_ribinjury','cc_ribpain',
    'cc_seizure-newonset','cc_seizure-priorhxof','cc_seizures',
    'cc_shortnessofbreath','cc_shoulderinjury','cc_shoulderpain',
    'cc_sicklecellpain','cc_sinusproblem','cc_skinirritation',
    'cc_skinproblem','cc_sorethroat','cc_stdcheck','cc_strokealert',
    'cc_suicidal','cc_suture/stapleremoval','cc_swallowedforeignbody',
    'cc_syncope','cc_tachycardia','cc_testiclepain','cc_thumbinjury',
    'cc_tickremoval','cc_toeinjury','cc_toepain','cc_trauma',
    'cc_unresponsive','cc_uri','cc_urinaryfrequency','cc_urinaryretention',
    'cc_urinarytractinfection','cc_vaginalbleeding','cc_vaginaldischarge',
    'cc_vaginalpain','cc_weakness','cc_wheezing','cc_withdrawal-alcohol',
    'cc_woundcheck','cc_woundinfection','cc_woundre-evaluation',
    'cc_wristinjury','cc_wristpain','gender_Male','dep_name_B','dep_name_C'
]


def check_free_text(free_text: str):
    if not free_text:
        return [], free_text
    matched = []
    for name in SYMPTOM_MAP:
        if name.lower() in free_text.lower():
            matched.append(name)
    return matched, free_text


def predict_severity(selected_symptoms, free_text=None, age=25, gender='M', arrival_datetime=None):
    from datetime import datetime

    load_models()

    now = arrival_datetime or datetime.now()

    extra_symptoms, doctor_note = check_free_text(free_text) if free_text else ([], free_text)
    all_symptoms = selected_symptoms + extra_symptoms
    mapped = [SYMPTOM_MAP.get(s) for s in all_symptoms if SYMPTOM_MAP.get(s)]

    feature_values = {
        'age': age,
        'arrivalmonth': now.month,
        'arrivalday': now.weekday(),
        'arrivalhour_bin': now.hour // 4,
        'gender_Male': 1 if gender == 'M' else 0,
        'dep_name_B': 0,
        'dep_name_C': 0
    }
    active_features = [f for f in ALL_FEATURES if feature_values.get(f) == 1]
    print("ACTIVE FEATURES:", active_features[:20])

    for f in ALL_FEATURES:
        if f not in feature_values:
            feature_values[f] = 1 if f in mapped else 0

    input_vector = [feature_values.get(f, 0) for f in ALL_FEATURES]
    input_df = pd.DataFrame([input_vector], columns=ALL_FEATURES)
    
    active_features = [f for f in ALL_FEATURES if feature_values.get(f) == 1]
    print("ACTIVE FEATURES:", active_features[:20])
    

    prediction = _model.predict(input_df)
    severity = prediction[0].upper()

    return {
        'severity': severity,
        'doctor_note': doctor_note
    }'''


'''this is just giving the severe as a class and not minor or moderate
import numpy as np
import pandas as pd
import os

import tensorflow as tf
from keras.models import load_model

# ─────────────────────────────────────────────
# PATH SETUP
# ─────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, 'AI_ML', 'models', 'snn_model.h5')

_model = None

# ─────────────────────────────────────────────
# LOAD MODEL (SNN - CORRECT WAY)
# ─────────────────────────────────────────────
def load_models():
    global _model
    if _model is None:
        _model = load_model(MODEL_PATH)


# ─────────────────────────────────────────────
# SYMPTOM MAPPING
# ─────────────────────────────────────────────
SYMPTOM_MAP = {
    "Abdominal Pain": "cc_abdominalpain",
    "Chest Pain": "cc_chestpain",
    "Cough": "cc_cough",
    "Fever": "cc_fever",
    "Headache": "cc_headache",
    "Diarrhea": "cc_diarrhea",
    "Sore Throat": "cc_sorethroat",
    "Shortness of Breath": "cc_shortnessofbreath",
    "Fatigue": "cc_fatigue",
    "Rash": "cc_rash",
    "Nausea": "cc_nausea",
    "Vomiting": "cc_nauseavomit",
    "Back Pain": "cc_backpain",
    "Eye Pain": "cc_eyepain",
    "Ear Pain": "cc_earpain",
    "Neck Pain": "cc_neckpain",
    "Body Aches": "cc_generalizedbodyaches",
    "Dizziness": "cc_dizziness",
    "Joint Pain": "cc_pain",
    "Loss of Appetite": "cc_fatigue",
}


# ─────────────────────────────────────────────
# FEATURE ORDER (MUST MATCH TRAINING)
# ─────────────────────────────────────────────
ALL_FEATURES = [
    'age','arrivalmonth','arrivalday','arrivalhour_bin',
    'cc_abdominalcramping','cc_abdominaldistention','cc_abdominalpain',
    'cc_abdominalpainpregnant','cc_abnormallab','cc_abscess',
    'cc_addictionproblem','cc_agitation','cc_alcoholintoxication',
    'cc_alcoholproblem','cc_allergicreaction','cc_alteredmentalstatus',
    'cc_animalbite','cc_ankleinjury','cc_anklepain','cc_anxiety',
    'cc_arminjury','cc_armpain','cc_armswelling','cc_assaultvictim',
    'cc_asthma','cc_backpain','cc_bleeding/bruising','cc_blurredvision',
    'cc_bodyfluidexposure','cc_breastpain','cc_breathingdifficulty',
    'cc_breathingproblem','cc_burn','cc_cardiacarrest','cc_cellulitis',
    'cc_chestpain','cc_chesttightness','cc_chills','cc_coldlikesymptoms',
    'cc_confusion','cc_conjunctivitis','cc_constipation','cc_cough',
    'cc_cyst','cc_decreasedbloodsugar-symptomatic','cc_dehydration',
    'cc_dentalpain','cc_depression','cc_detoxevaluation','cc_diarrhea',
    'cc_dizziness','cc_drug/alcoholassessment','cc_drugproblem',
    'cc_dyspnea','cc_dysuria','cc_earpain','cc_earproblem','cc_edema',
    'cc_elbowpain','cc_elevatedbloodsugar-nosymptoms',
    'cc_elevatedbloodsugar-symptomatic','cc_emesis','cc_epigastricpain',
    'cc_epistaxis','cc_exposuretostd','cc_extremitylaceration',
    'cc_extremityweakness','cc_eyeinjury','cc_eyepain','cc_eyeproblem',
    'cc_eyeredness','cc_facialinjury','cc_faciallaceration','cc_facialpain',
    'cc_facialswelling','cc_fall','cc_fall>65','cc_fatigue',
    'cc_femaleguproblem','cc_fever','cc_fever-75yearsorolder',
    'cc_fever-9weeksto74years','cc_feverimmunocompromised','cc_fingerinjury',
    'cc_fingerpain','cc_fingerswelling','cc_flankpain',
    'cc_follow-upcellulitis','cc_footinjury','cc_footpain','cc_footswelling',
    'cc_foreignbodyineye','cc_fulltrauma','cc_generalizedbodyaches',
    'cc_gibleeding','cc_giproblem','cc_groinpain','cc_hallucinations',
    'cc_handinjury','cc_handpain','cc_headache',
    'cc_headache-newonsetornewsymptoms',
    'cc_headache-recurrentorknowndxmigraines',
    'cc_headachere-evaluation','cc_headinjury','cc_headlaceration',
    'cc_hematuria','cc_hemoptysis','cc_hippain','cc_homicidal',
    'cc_hyperglycemia','cc_hypertension','cc_hypotension','cc_influenza',
    'cc_ingestion','cc_insectbite','cc_irregularheartbeat','cc_jawpain',
    'cc_jointswelling','cc_kneeinjury','cc_kneepain','cc_laceration',
    'cc_leginjury','cc_legpain','cc_legswelling','cc_lethargy',
    'cc_lossofconsciousness','cc_maleguproblem','cc_mass',
    'cc_medicalproblem','cc_medicalscreening','cc_medicationproblem',
    'cc_medicationrefill','cc_migraine','cc_modifiedtrauma',
    'cc_motorcyclecrash','cc_motorvehiclecrash','cc_multiplefalls',
    'cc_nasalcongestion','cc_nausea','cc_nearsyncope','cc_neckpain',
    'cc_neurologicproblem','cc_numbness','cc_oralswelling','cc_otalgia',
    'cc_other','cc_overdose-accidental','cc_overdose-intentional','cc_pain',
    'cc_palpitations','cc_panicattack','cc_pelvicpain','cc_poisoning',
    'cc_post-opproblem','cc_psychiatricevaluation','cc_psychoticsymptoms',
    'cc_rapidheartrate','cc_rash','cc_rectalbleeding','cc_rectalpain',
    'cc_respiratorydistress','cc_ribinjury','cc_ribpain',
    'cc_seizure-newonset','cc_seizure-priorhxof','cc_seizures',
    'cc_shortnessofbreath','cc_shoulderinjury','cc_shoulderpain',
    'cc_sicklecellpain','cc_sinusproblem','cc_skinirritation',
    'cc_skinproblem','cc_sorethroat','cc_stdcheck','cc_strokealert',
    'cc_suicidal','cc_suture/stapleremoval','cc_swallowedforeignbody',
    'cc_syncope','cc_tachycardia','cc_testiclepain','cc_thumbinjury',
    'cc_tickremoval','cc_toeinjury','cc_toepain','cc_trauma',
    'cc_unresponsive','cc_uri','cc_urinaryfrequency','cc_urinaryretention',
    'cc_urinarytractinfection','cc_vaginalbleeding','cc_vaginaldischarge',
    'cc_vaginalpain','cc_weakness','cc_wheezing','cc_withdrawal-alcohol',
    'cc_woundcheck','cc_woundinfection','cc_woundre-evaluation',
    'cc_wristinjury','cc_wristpain','gender_Male','dep_name_B','dep_name_C'
]

# ─────────────────────────────────────────────
# TEXT SYMPTOM DETECTION
# ─────────────────────────────────────────────
def check_free_text(free_text: str):
    if not free_text:
        return [], free_text

    matched = []
    text = free_text.lower()

    for name in SYMPTOM_MAP:
        if name.lower() in text:
            matched.append(name)

    return matched, free_text


# ─────────────────────────────────────────────
# MAIN PREDICTION FUNCTION
# ─────────────────────────────────────────────
def predict_severity(selected_symptoms, free_text=None,
                     age=25, gender='M', arrival_datetime=None):

    from datetime import datetime

    load_models()

    now = arrival_datetime or datetime.now()

    # ── extract symptoms ──
    extra_symptoms, doctor_note = check_free_text(free_text) if free_text else ([], free_text)
    all_symptoms = selected_symptoms + extra_symptoms

    mapped = [SYMPTOM_MAP[s] for s in all_symptoms if s in SYMPTOM_MAP]

    # ── base features ──
    feature_values = {f: 0 for f in ALL_FEATURES}

    feature_values.update({
        'age': age,
        'arrivalmonth': now.month,
        'arrivalday': now.weekday(),
        'arrivalhour_bin': now.hour // 4,
        'gender_Male': 1 if gender == 'M' else 0,
        'dep_name_B': 0,
        'dep_name_C': 0
    })

    # ── activate symptom features ──
    for f in mapped:
        if f in feature_values:
            feature_values[f] = 1

    # ── build input (CRITICAL: must be (1,207)) ──
    input_vector = np.array([feature_values[f] for f in ALL_FEATURES], dtype=np.float32)
    input_vector = input_vector.reshape(1, -1)

    print("INPUT SHAPE:", input_vector.shape)  # DEBUG

    # ── prediction ──
    probs = _model.predict(input_vector, verbose=0)
    pred_class = np.argmax(probs, axis=1)[0]

    # map output manually (IMPORTANT)
    LABELS = ["MINOR", "MODERATE", "SEVERE"]
    severity = LABELS[pred_class]

    return {
        "severity": severity,
        "doctor_note": doctor_note
    }'''


'''this is the snn model code its working but its giving the severe as a class and not minor or moderate
import numpy as np
import os
import tensorflow as tf
from keras.models import load_model

# ─────────────────────────────────────────────
# PATH SETUP
# ─────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, 'AI_ML', 'models', 'snn_model.h5')

_model = None

# ─────────────────────────────────────────────
# LOAD MODEL (SNN - CORRECT WAY)
# ─────────────────────────────────────────────
def load_models():
    global _model
    if _model is None:
        _model = load_model(MODEL_PATH)


# ─────────────────────────────────────────────
# SYMPTOM MAPPING
# ─────────────────────────────────────────────
SYMPTOM_MAP = {
    "Abdominal Pain":      "cc_abdominalpain",
    "Chest Pain":          "cc_chestpain",
    "Cough":               "cc_cough",
    "Fever":               "cc_fever",
    "Headache":            "cc_headache",
    "Diarrhea":            "cc_diarrhea",
    "Sore Throat":         "cc_sorethroat",
    "Shortness of Breath": "cc_shortnessofbreath",
    "Fatigue":             "cc_fatigue",
    "Rash":                "cc_rash",
    "Nausea":              "cc_nausea",
    "Vomiting":            "cc_nauseavomit",
    "Back Pain":           "cc_backpain",
    "Eye Pain":            "cc_eyepain",
    "Ear Pain":            "cc_earpain",
    "Neck Pain":           "cc_neckpain",
    "Body Aches":          "cc_generalizedbodyaches",
    "Dizziness":           "cc_dizziness",
    "Joint Pain":          "cc_pain",
    "Loss of Appetite":    "cc_fatigue",
}


# ─────────────────────────────────────────────
# FEATURE ORDER (MUST MATCH TRAINING)
# ─────────────────────────────────────────────
ALL_FEATURES = [
    'age','arrivalmonth','arrivalday','arrivalhour_bin',
    'cc_abdominalcramping','cc_abdominaldistention','cc_abdominalpain',
    'cc_abdominalpainpregnant','cc_abnormallab','cc_abscess',
    'cc_addictionproblem','cc_agitation','cc_alcoholintoxication',
    'cc_alcoholproblem','cc_allergicreaction','cc_alteredmentalstatus',
    'cc_animalbite','cc_ankleinjury','cc_anklepain','cc_anxiety',
    'cc_arminjury','cc_armpain','cc_armswelling','cc_assaultvictim',
    'cc_asthma','cc_backpain','cc_bleeding/bruising','cc_blurredvision',
    'cc_bodyfluidexposure','cc_breastpain','cc_breathingdifficulty',
    'cc_breathingproblem','cc_burn','cc_cardiacarrest','cc_cellulitis',
    'cc_chestpain','cc_chesttightness','cc_chills','cc_coldlikesymptoms',
    'cc_confusion','cc_conjunctivitis','cc_constipation','cc_cough',
    'cc_cyst','cc_decreasedbloodsugar-symptomatic','cc_dehydration',
    'cc_dentalpain','cc_depression','cc_detoxevaluation','cc_diarrhea',
    'cc_dizziness','cc_drug/alcoholassessment','cc_drugproblem',
    'cc_dyspnea','cc_dysuria','cc_earpain','cc_earproblem','cc_edema',
    'cc_elbowpain','cc_elevatedbloodsugar-nosymptoms',
    'cc_elevatedbloodsugar-symptomatic','cc_emesis','cc_epigastricpain',
    'cc_epistaxis','cc_exposuretostd','cc_extremitylaceration',
    'cc_extremityweakness','cc_eyeinjury','cc_eyepain','cc_eyeproblem',
    'cc_eyeredness','cc_facialinjury','cc_faciallaceration','cc_facialpain',
    'cc_facialswelling','cc_fall','cc_fall>65','cc_fatigue',
    'cc_femaleguproblem','cc_fever','cc_fever-75yearsorolder',
    'cc_fever-9weeksto74years','cc_feverimmunocompromised','cc_fingerinjury',
    'cc_fingerpain','cc_fingerswelling','cc_flankpain',
    'cc_follow-upcellulitis','cc_footinjury','cc_footpain','cc_footswelling',
    'cc_foreignbodyineye','cc_fulltrauma','cc_generalizedbodyaches',
    'cc_gibleeding','cc_giproblem','cc_groinpain','cc_hallucinations',
    'cc_handinjury','cc_handpain','cc_headache',
    'cc_headache-newonsetornewsymptoms',
    'cc_headache-recurrentorknowndxmigraines',
    'cc_headachere-evaluation','cc_headinjury','cc_headlaceration',
    'cc_hematuria','cc_hemoptysis','cc_hippain','cc_homicidal',
    'cc_hyperglycemia','cc_hypertension','cc_hypotension','cc_influenza',
    'cc_ingestion','cc_insectbite','cc_irregularheartbeat','cc_jawpain',
    'cc_jointswelling','cc_kneeinjury','cc_kneepain','cc_laceration',
    'cc_leginjury','cc_legpain','cc_legswelling','cc_lethargy',
    'cc_lossofconsciousness','cc_maleguproblem','cc_mass',
    'cc_medicalproblem','cc_medicalscreening','cc_medicationproblem',
    'cc_medicationrefill','cc_migraine','cc_modifiedtrauma',
    'cc_motorcyclecrash','cc_motorvehiclecrash','cc_multiplefalls',
    'cc_nasalcongestion','cc_nausea','cc_nearsyncope','cc_neckpain',
    'cc_neurologicproblem','cc_numbness','cc_oralswelling','cc_otalgia',
    'cc_other','cc_overdose-accidental','cc_overdose-intentional','cc_pain',
    'cc_palpitations','cc_panicattack','cc_pelvicpain','cc_poisoning',
    'cc_post-opproblem','cc_psychiatricevaluation','cc_psychoticsymptoms',
    'cc_rapidheartrate','cc_rash','cc_rectalbleeding','cc_rectalpain',
    'cc_respiratorydistress','cc_ribinjury','cc_ribpain',
    'cc_seizure-newonset','cc_seizure-priorhxof','cc_seizures',
    'cc_shortnessofbreath','cc_shoulderinjury','cc_shoulderpain',
    'cc_sicklecellpain','cc_sinusproblem','cc_skinirritation',
    'cc_skinproblem','cc_sorethroat','cc_stdcheck','cc_strokealert',
    'cc_suicidal','cc_suture/stapleremoval','cc_swallowedforeignbody',
    'cc_syncope','cc_tachycardia','cc_testiclepain','cc_thumbinjury',
    'cc_tickremoval','cc_toeinjury','cc_toepain','cc_trauma',
    'cc_unresponsive','cc_uri','cc_urinaryfrequency','cc_urinaryretention',
    'cc_urinarytractinfection','cc_vaginalbleeding','cc_vaginaldischarge',
    'cc_vaginalpain','cc_weakness','cc_wheezing','cc_withdrawal-alcohol',
    'cc_woundcheck','cc_woundinfection','cc_woundre-evaluation',
    'cc_wristinjury','cc_wristpain','gender_Male','dep_name_B','dep_name_C'
]


# ─────────────────────────────────────────────
# TEXT SYMPTOM DETECTION
# ─────────────────────────────────────────────
def check_free_text(free_text: str):
    if not free_text:
        return [], free_text

    matched = []
    text = free_text.lower()

    for name in SYMPTOM_MAP:
        if name.lower() in text:
            matched.append(name)

    return matched, free_text


# ─────────────────────────────────────────────
# MAIN PREDICTION FUNCTION
# ─────────────────────────────────────────────
def predict_severity(selected_symptoms, free_text=None,
                     age=25, gender='M', arrival_datetime=None):

    from datetime import datetime

    load_models()

    now = arrival_datetime or datetime.now()

    # ── extract symptoms ──
    extra_symptoms, doctor_note = check_free_text(free_text) if free_text else ([], free_text)
    all_symptoms = selected_symptoms + extra_symptoms

    mapped = [SYMPTOM_MAP[s] for s in all_symptoms if s in SYMPTOM_MAP]

    # ── base features ──
    feature_values = {f: 0 for f in ALL_FEATURES}

    feature_values.update({
        'age':             age,
        'arrivalmonth':    now.month,
        'arrivalday':      now.weekday(),
        'arrivalhour_bin': now.hour // 4,
        'gender_Male':     1 if gender == 'M' else 0,
        'dep_name_B':      0,
        'dep_name_C':      0
    })

    # ── activate symptom features ──
    for f in mapped:
        if f in feature_values:
            feature_values[f] = 1

    # ── build input (CRITICAL: must be (1,207)) ──
    input_vector = np.array([feature_values[f] for f in ALL_FEATURES], dtype=np.float32)
    input_vector = input_vector.reshape(1, -1)

    # ─── DEBUG ───────────────────────────────
    print("=" * 50)
    print("MODEL TYPE    :", type(_model))
    print("SYMPTOMS IN   :", selected_symptoms)
    print("MAPPED TO     :", mapped)
    print("INPUT SHAPE   :", input_vector.shape)
    print("ACTIVE FEATS  :", int(np.sum(input_vector > 0)))
    # ─────────────────────────────────────────

    # ── prediction ──
    probs      = _model.predict(input_vector, verbose=0)
    pred_class = np.argmax(probs, axis=1)[0]

    # ─── DEBUG ───────────────────────────────
    print("PROBABILITIES :", probs)
    print("PRED CLASS    :", pred_class)
    print("LABELS MAP    : 0=MINOR  1=MODERATE  2=SEVERE")
    print("=" * 50)
    # ─────────────────────────────────────────

    # map output manually (IMPORTANT)
    LABELS   = ["MINOR", "MODERATE", "SEVERE"]
    severity = LABELS[pred_class]

    return {
        "severity":    severity,
        "doctor_note": doctor_note
    }'''