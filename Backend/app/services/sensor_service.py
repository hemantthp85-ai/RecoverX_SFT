import math

from app.schemas.telemetry import TelemetryData


def calculate_acceleration_magnitude(data: TelemetryData) -> float | None:
    """
    Calculate total acceleration magnitude from MPU6050 data.
    """

    if (
        data.accel_x_g is None
        or data.accel_y_g is None
        or data.accel_z_g is None
    ):
        return None

    magnitude = math.sqrt(
        data.accel_x_g ** 2
        + data.accel_y_g ** 2
        + data.accel_z_g ** 2
    )

    return round(magnitude, 3)


def classify_movement(acceleration_magnitude: float | None) -> str:
    """
    Classify movement using prototype engineering thresholds.

    These are NOT medical thresholds.
    They are only for backend testing.
    """

    if acceleration_magnitude is None:
        return "UNKNOWN"

    if acceleration_magnitude < 0.5:
        return "LOW"

    if acceleration_magnitude < 1.5:
        return "MEDIUM"

    return "HIGH"


def classify_temperature(temperature_c: float | None) -> str:
    """
    Basic temperature state for prototype monitoring.

    These are NOT clinical therapy limits.
    """

    if temperature_c is None:
        return "UNKNOWN"

    if temperature_c < 15:
        return "LOW"

    if temperature_c <= 40:
        return "NORMAL"

    return "HIGH"


def process_sensor_data(data: TelemetryData) -> dict:
    """
    Process all available sensor data and return
    standardized RecoverX processing results.
    """

    acceleration_magnitude = calculate_acceleration_magnitude(data)

    movement_state = classify_movement(acceleration_magnitude)

    temperature_state = classify_temperature(data.temperature_c)

    return {
        "device_id": data.device_id,
        "timestamp": data.timestamp,

        "temperature": {
            "value_c": data.temperature_c,
            "state": temperature_state,
        },

        "max_ir": data.max_ir,
        "max_red": data.max_red,
        "finger_detected": data.finger_detected,

        "therapy_requested": data.therapy_requested,
        "therapy_status": data.therapy_status,
        "therapy_direction": data.therapy_direction,

        "movement": {
            "acceleration_magnitude_g": acceleration_magnitude,
            "state": movement_state,
        },

        "heart_rate": {
            "value_bpm": data.heart_rate_bpm,
        },

        "spo2": {
            "value_percent": data.spo2_percent,
        },

        "pressure": {
            "raw": data.pressure_raw,
            "force_estimate_n": data.force_estimate_n,
        },
    }