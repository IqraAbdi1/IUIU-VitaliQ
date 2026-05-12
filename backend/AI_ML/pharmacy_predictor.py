import pickle
import numpy as np
import os
from datetime import datetime

# ── load models ──
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def _load_model(filename):
    path = os.path.join(BASE_DIR, 'models', filename)
    with open(path, 'rb') as f:
        return pickle.load(f)

# lazy load — only load when first called
_restock_model  = None
_trend_analyzer = None

def get_restock_model():
    global _restock_model
    if _restock_model is None:
        _restock_model = _load_model('restock_model.pkl')
    return _restock_model

def get_trend_analyzer():
    global _trend_analyzer
    if _trend_analyzer is None:
        _trend_analyzer = _load_model('trend_analyzer.pkl')
    return _trend_analyzer


def predict_disease_spikes():
    """
    Returns dict of {disease: [forecast_month1, forecast_month2, forecast_month3]}
    Uses the trend_analyzer model which is a dict of ExponentialSmoothing models
    """
    try:
        trend_models = get_trend_analyzer()
        forecasts = {}
        for disease, model in trend_models.items():
            forecast = model.forecast(3)
            forecasts[disease] = {
                'values':       [round(float(v), 1) for v in forecast.values],
                'trend':        'up' if forecast.values[-1] > forecast.values[0] else 'stable',
                'peak_month':   int(forecast.values.argmax() + 1),
            }
        return forecasts
    except Exception as e:
        print(f'Trend prediction error: {e}')
        return {}


def compute_demand_pressure(medical_condition, disease_forecasts):
    """
    Maps a medicine's medical_condition to a disease forecast
    Returns pressure ratio > 1.0 means spike expected
    """
    # 👇 ADD THESE THREE LINES FOR TESTING
    '''if medical_condition and "Bacterial" in medical_condition:
        print("DEBUG: Spike test active for Bacterial Infection")
        return 2.5 

    if not medical_condition or not disease_forecasts:
        return 1.0'''
    if not medical_condition or not disease_forecasts:
        return 1.0

    condition_lower = medical_condition.lower()
    for disease, forecast in disease_forecasts.items():
        if disease.lower() in condition_lower or condition_lower in disease.lower():
            values = forecast['values']
            # pressure = mean forecast / baseline (first value)
            baseline = values[0] if values[0] > 0 else 1
            pressure = sum(values) / (len(values) * baseline)
            return round(pressure, 3)
    return 1.0


def predict_restock(medicine_data, demand_pressure):
    """
    Predicts days to stockout for a single medicine.

    medicine_data: dict with keys matching MedicineStock fields
    demand_pressure: float from trend model

    Returns: {days_to_stockout, urgency, reorder_flag}
    """
    try:
        model = get_restock_model()

        current_stock    = float(medicine_data.get('current_stock', 0))
        reorder_threshold = float(medicine_data.get('reorder_threshold', 50))
        avg_monthly_units = float(medicine_data.get('avg_monthly_units', 30))
        avg_monthly_rx    = float(medicine_data.get('avg_monthly_rx', 10))
        avg_duration      = float(medicine_data.get('avg_duration', 7))
        avg_frequency     = float(medicine_data.get('avg_frequency', 3))

        daily_consumption = max(avg_monthly_units / 30, 0.1)
        days_formula      = round(current_stock / daily_consumption, 1)
        stock_coverage    = current_stock / max(reorder_threshold, 1)

        last_restocked = medicine_data.get('last_restocked')
        if last_restocked:
            days_since_restock = (datetime.today().date() - last_restocked).days
        else:
            days_since_restock = 30  # default

        features = np.array([[
            current_stock,
            reorder_threshold,
            avg_monthly_units,
            avg_monthly_rx,
            avg_duration,
            avg_frequency,
            daily_consumption,
            days_formula,
            stock_coverage,
            days_since_restock,
            demand_pressure,
        ]])

        days_predicted = float(model.predict(features)[0])
        days_predicted = round(max(days_predicted, 0), 1)

        # urgency labels matching training
        if days_predicted < 3:
            urgency = 'CRITICAL'
        elif days_predicted < 7:
            urgency = 'HIGH'
        elif days_predicted < 14:
            urgency = 'MEDIUM'
        else:
            urgency = 'OK'

        return {
            'days_to_stockout': days_predicted,
            'urgency':          urgency,
            'reorder_flag':     days_predicted < 14,
            'daily_consumption': round(daily_consumption, 2),
            'demand_pressure':  demand_pressure,
        }

    except Exception as e:
        print(f'Restock prediction error: {e}')
        return {
            'days_to_stockout': 999,
            'urgency':          'UNKNOWN',
            'reorder_flag':     False,
            'daily_consumption': 0,
            'demand_pressure':  1.0,
        }
def get_restock_model():
    global _restock_model
    if _restock_model is None:
        try:
            _restock_model = _load_model('restock_model.pkl')
            print(f'Restock model loaded: {type(_restock_model)}')
        except Exception as e:
            print(f'RESTOCK MODEL LOAD ERROR: {e}')
    return _restock_model

def get_trend_analyzer():
    global _trend_analyzer
    if _trend_analyzer is None:
        try:
            _trend_analyzer = _load_model('trend_analyzer.pkl')
            print(f'Trend model loaded: {type(_trend_analyzer)}')
        except Exception as e:
            print(f'TREND MODEL LOAD ERROR: {e}')
    return _trend_analyzer