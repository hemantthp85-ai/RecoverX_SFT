from app.schemas.telemetry import TelemetryData


def check_temperature_safety(
    temperature_c: float | None,
) -> dict:
    """
    Prototype temperature safety check.

    These limits are engineering/demo limits only.
    They are NOT medical treatment limits.
    """

    if temperature_c is None:
        return {
            "status": "UNKNOWN",
            "safe": False,
            "reason": "Temperature reading is missing",
        }

    # Basic sensor-data validity check
    if temperature_c < -55 or temperature_c > 125:
        return {
            "status": "INVALID",
            "safe": False,
            "reason": "Temperature is outside DS18B20 sensor range",
        }

    # Prototype safety boundary.
    # We will make these configurable later.
    if temperature_c < 10:
        return {
            "status": "WARNING",
            "safe": False,
            "reason": "Temperature is below prototype safety boundary",
        }

    if temperature_c > 40:
        return {
            "status": "CRITICAL",
            "safe": False,
            "reason": "Temperature is above prototype safety boundary",
        }

    return {
        "status": "SAFE",
        "safe": True,
        "reason": "Temperature is within prototype monitoring range",
    }


def check_heart_rate(
    heart_rate_bpm: float | None,
) -> dict:
    """
    Basic data-quality check for heart-rate data.
    This does NOT diagnose a medical condition.
    """

    if heart_rate_bpm is None:
        return {
            "status": "NOT_MONITORED",
            "valid": True,
            "reason": "Heart-rate sensor inactive or not required for MVP",
        }

    if heart_rate_bpm <= 0 or heart_rate_bpm > 250:
        return {
            "status": "INVALID",
            "valid": False,
            "reason": "Heart-rate value is outside the prototype sensor-data range",
        }

    return {
        "status": "VALID",
        "valid": True,
        "reason": "Heart-rate reading is valid",
    }


def check_spo2(
    spo2_percent: float | None,
) -> dict:
    """
    Basic data-quality check for SpO2.
    This does NOT diagnose a medical condition.
    """

    if spo2_percent is None:
        return {
            "status": "NOT_MONITORED",
            "valid": True,
            "reason": "SpO2 sensor inactive or not required for MVP",
        }

    if spo2_percent < 0 or spo2_percent > 100:
        return {
            "status": "INVALID",
            "valid": False,
            "reason": "SpO2 must be between 0 and 100 percent",
        }

    return {
        "status": "VALID",
        "valid": True,
        "reason": "SpO2 reading is valid",
    }


def check_movement(
    acceleration_magnitude_g: float | None,
) -> dict:
    """
    Basic movement safety check.
    """

    if acceleration_magnitude_g is None:
        return {
            "status": "NOT_MONITORED",
            "safe": True,
            "reason": "Movement sensor inactive or not required for MVP",
        }

    if acceleration_magnitude_g > 4.0:
        return {
            "status": "HIGH_MOVEMENT",
            "safe": False,
            "reason": "Movement is unusually high for the prototype",
        }

    return {
        "status": "SAFE",
        "safe": True,
        "reason": "Movement is within prototype range",
    }


def evaluate_safety(
    data: TelemetryData,
    acceleration_magnitude_g: float | None,
) -> dict:
    """
    Evaluate the overall safety state of the incoming telemetry.
    """

    temperature = check_temperature_safety(data.temperature_c)

    heart_rate = check_heart_rate(data.heart_rate_bpm)

    spo2 = check_spo2(data.spo2_percent)

    movement = check_movement(acceleration_magnitude_g)

    safety_flags = []

    if not temperature["safe"]:
        safety_flags.append(temperature["reason"])

    if not movement["safe"]:
        safety_flags.append(movement["reason"])

    if not heart_rate["valid"]:
        safety_flags.append(heart_rate["reason"])

    if not spo2["valid"]:
        safety_flags.append(spo2["reason"])

    overall_safe = len(safety_flags) == 0

    return {
        "overall_safe": overall_safe,
        "status": "SAFE" if overall_safe else "CHECK_REQUIRED",
        "flags": safety_flags,
        "temperature": temperature,
        "heart_rate": heart_rate,
        "spo2": spo2,
        "movement": movement,
    }