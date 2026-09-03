from typing import Optional
from fastapi import APIRouter, Query

from app.db.database import get_database
from app.models.sensor_analysis import (
    create_sensor_analysis_document,
    create_sensor_telemetry_document,
)
from app.schemas.telemetry import TelemetryData

from app.services.sensor_service import (
    process_sensor_data,
    calculate_acceleration_magnitude,
)

from app.services.safety_service import evaluate_safety


router = APIRouter(
    tags=["Sensors & Telemetry"],
)


@router.post("/api/sensors/telemetry")
@router.post("/api/telemetry")
async def receive_telemetry(
    data: TelemetryData,
    user_id: Optional[str] = Query(default="RecoverX_User"),
):
    """
    Ingests live sensor telemetry from ESP32-C3 Wearable or Frontend app.
    Evaluates safety, stores in MongoDB collections (sensor_telemetry & sensor_analysis),
    and returns standardized processing status.
    """
    # 1. Process raw sensor data
    processed_data = process_sensor_data(data)

    # 2. Calculate movement magnitude
    acceleration_magnitude = calculate_acceleration_magnitude(data)

    # 3. Evaluate sensor safety
    safety_result = evaluate_safety(
        data,
        acceleration_magnitude,
    )

    # 4. Determine basic recovery state
    if not safety_result["overall_safe"]:
        recovery_result = {
            "recovery_state": "SAFETY_HOLD",
            "recommendation": "NO_THERAPY",
            "reason": "Safety condition requires attention: " + "; ".join(safety_result.get("flags", [])),
            "therapy_allowed": False,
        }
    else:
        recovery_result = {
            "recovery_state": "STABLE",
            "recommendation": "MONITOR",
            "reason": "Sensor readings are within prototype monitoring conditions",
            "therapy_allowed": True,
        }

    # 5. Connect to MongoDB
    database = get_database()

    # 6. Store exact telemetry document in sensor_telemetry collection
    telemetry_doc = create_sensor_telemetry_document(
        device_id=data.device_id,
        timestamp=data.timestamp,
        temperature_c=data.temperature_c,
        max_ir=data.max_ir,
        max_red=data.max_red,
        finger_detected=data.finger_detected,
        therapy_requested=data.therapy_requested,
        therapy_status=data.therapy_status,
        therapy_direction=data.therapy_direction,
        user_id=user_id,
    )
    telemetry_result = database["sensor_telemetry"].insert_one(telemetry_doc)

    # 7. Store analytical document in sensor_analysis collection for reporting
    sensor_document = create_sensor_analysis_document(
        user_id=user_id,
        processed_data=processed_data,
        safety_result=safety_result,
        recovery_result=recovery_result,
    )
    analysis_result = database["sensor_analysis"].insert_one(sensor_document)

    return {
        "status": "success",
        "message": "Sensor telemetry processed and stored successfully",
        "user_id": user_id,
        "telemetry_id": str(telemetry_result.inserted_id),
        "analysis_id": str(analysis_result.inserted_id),
        "data": processed_data,
        "safety": safety_result,
        "recovery": recovery_result,
    }