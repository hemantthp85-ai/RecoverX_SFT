from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class PatientInformation(BaseModel):
    patient_name: str
    diagnostic_date: Optional[datetime] = None
    recovery_stage: str
    diagnostic_class: str
    hardware_status: str


class SensorMetric(BaseModel):
    value: float
    unit: str
    status: str
    interpretation: str


class ClinicalReport(BaseModel):
    user_id: str
    patient_information: PatientInformation

    recovery_score: float
    recovery_status: str
    recovery_insight: str

    skin_temperature: SensorMetric
    circulatory_flow: SensorMetric
    joint_rom: SensorMetric
    swelling: SensorMetric

    clinician_notes: Optional[str] = None
    clinician_name: Optional[str] = None
    clinician_designation: Optional[str] = None


class TherapyHistoryItem(BaseModel):
    session_id: str
    therapy_type: str
    date_time: datetime
    duration_minutes: int
    progress_before: float
    progress_after: float


class RecoveryHistory(BaseModel):
    user_id: str
    sessions: List[TherapyHistoryItem]