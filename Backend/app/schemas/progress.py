from pydantic import BaseModel
from typing import Optional


class PhysiologicalMetric(BaseModel):
    value: Optional[float] = None
    unit: Optional[str] = None
    status: Optional[str] = None
    interpretation: Optional[str] = None


class RecoveryProgressResponse(BaseModel):
    user_id: str

    recovery_score: float
    recovery_stage: str
    progress_status: str

    summary: Optional[str] = None

    temperature: PhysiologicalMetric
    swelling: PhysiologicalMetric
    joint_mobility: PhysiologicalMetric
    blood_flow: PhysiologicalMetric