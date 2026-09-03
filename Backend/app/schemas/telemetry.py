from datetime import datetime
from typing import Optional, Union

from pydantic import BaseModel, Field


class TelemetryData(BaseModel):
    """
    Standard sensor telemetry format for RecoverX.
    Supports ESP32-C3 Wearable live telemetry and legacy sensor parameters.
    """

    device_id: str = Field(..., min_length=1)

    # Accepts ISO datetime string, unix epoch int/float, or datetime object
    timestamp: Union[datetime, int, float, str]

    # Temperature (DS18B20)
    temperature_c: Optional[float] = None

    # MAX30102 Raw Optical PPG & Calculated States
    max_ir: Optional[int] = None
    max_red: Optional[int] = None
    finger_detected: Optional[bool] = None

    # ESP32 Local Therapy States
    therapy_requested: Optional[bool] = None
    therapy_status: Optional[str] = None
    therapy_direction: Optional[str] = None

    # Legacy / Optional Sensor Fields (Heart Rate & SpO2)
    heart_rate_bpm: Optional[float] = None
    spo2_percent: Optional[float] = None

    # Optional FSR402 Pressure
    pressure_raw: Optional[float] = None
    force_estimate_n: Optional[float] = None

    # Optional MPU6050 Accelerometer
    accel_x_g: Optional[float] = None
    accel_y_g: Optional[float] = None
    accel_z_g: Optional[float] = None

    # Optional MPU6050 Gyroscope
    gyro_x_dps: Optional[float] = None
    gyro_y_dps: Optional[float] = None
    gyro_z_dps: Optional[float] = None