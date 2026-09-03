from datetime import datetime, timezone
from typing import Optional


def create_sensor_telemetry_document(
    device_id: str,
    timestamp,
    temperature_c: Optional[float],
    max_ir: Optional[int],
    max_red: Optional[int],
    finger_detected: Optional[bool],
    therapy_requested: Optional[bool],
    therapy_status: Optional[str],
    therapy_direction: Optional[str],
    user_id: Optional[str] = None,
):
    """
    Standard MongoDB document for the 'sensor_telemetry' collection.
    Matches the exact telemetry fields specified for RecoverX.
    """
    return {
        "device_id": device_id,
        "timestamp": timestamp,
        "temperature_c": temperature_c,
        "max_ir": max_ir,
        "max_red": max_red,
        "finger_detected": finger_detected,
        "therapy_requested": therapy_requested,
        "therapy_status": therapy_status,
        "therapy_direction": therapy_direction,
        "user_id": user_id,
        "created_at": datetime.now(timezone.utc),
    }


def create_sensor_analysis_document(
    user_id: str,
    processed_data: dict,
    safety_result: dict,
    recovery_result: dict,
):
    return {
        "user_id": user_id,

        "device_id": processed_data.get("device_id"),
        "timestamp": processed_data.get("timestamp"),

        "temperature": processed_data.get("temperature"),
        "movement": processed_data.get("movement"),
        "heart_rate": processed_data.get("heart_rate"),
        "spo2": processed_data.get("spo2"),
        "pressure": processed_data.get("pressure"),

        "max_ir": processed_data.get("max_ir"),
        "max_red": processed_data.get("max_red"),
        "finger_detected": processed_data.get("finger_detected"),
        "therapy_requested": processed_data.get("therapy_requested"),
        "therapy_status": processed_data.get("therapy_status"),
        "therapy_direction": processed_data.get("therapy_direction"),

        "safety": safety_result,
        "recovery": recovery_result,

        "created_at": datetime.now(timezone.utc),
    }