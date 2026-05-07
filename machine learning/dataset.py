import pandas as pd
import numpy as np
symptoms = [
    'fever_high',         # high fever
    'fever_low',          # mild fever
    'abdominal_pain',
    'fatigue',
    'headache',
    'nausea',
    'vomiting',
    'diarrhea',
    'constipation',
    'chills',
    'sweating',
    'burning_urination',
    'frequent_urination',
    'rash',
    'itching',
    'redness',
    'swelling',
    'cough',
    'sore_throat',
    'runny_nose',
    'body_ache',
    'bloating',
    'heartburn',
    'dizziness',
    'fainting',
    'cold_hands_feet',
    'blurred_vision'
]

# Number of patients
n_patients = 1000

# Randomly generate symptom presence (0 or 1)
data = np.random.randint(0, 2, size=(n_patients, len(symptoms)))
df = pd.DataFrame(data, columns=symptoms)

# Function to assign severity
def assign_severity(row):
    # Severe conditions
    if (row['fever_high'] and row['chills'] and row['fatigue']) or \
       (row['abdominal_pain'] and row['vomiting'] and row['fever_high']) or \
       (row['burning_urination'] and row['fever_high']):
        return 'Severe'
    
    # Moderate conditions
    elif (row['fever_low'] and row['headache'] and row['fatigue']) or \
         (row['rash'] and row['itching']) or \
         (row['abdominal_pain'] and row['bloating']):
        return 'Moderate'
    
    # Minor conditions
    else:
        return 'Minor'

df['severity'] = df.apply(assign_severity, axis=1)

# Quick look
print(df.head())
print(df['severity'].value_counts())
df.to_csv('patient_symptoms_dataset.csv', index=False)