from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class TemperatureAnalysis(BaseModel):
    value_c: Optional[float] = None
    state: str


class MovementAnalysis(BaseModel):
    acceleration_magnitude_g: Optional[float] = None
    state: str


class HeartRateAnalysis(BaseModel):
    value_bpm: Optional[float] = None


class SpO2Analysis(BaseModel):
    value_percent: Optional[float] = None


class PressureAnalysis(BaseModel):
    raw: Optional[float] = None
    force_estimate_n: Optional[float] = None


class SafetyAnalysis(BaseModel):
    overall_safe: bool
    status: str
    flags: list[str]

    temperature: dict
    heart_rate: dict
    spo2: dict
    movement: dict


class RecoveryAnalysis(BaseModel):
    recovery_state: str
    recommendation: str
    reason: str
    therapy_allowed: bool


class SensorAnalysis(BaseModel):
    device_id: str
    timestamp: datetime

    temperature: TemperatureAnalysis
    movement: MovementAnalysis
    heart_rate: HeartRateAnalysis
    spo2: SpO2Analysis
    pressure: PressureAnalysis

    safety: SafetyAnalysis
    recovery: RecoveryAnalysis