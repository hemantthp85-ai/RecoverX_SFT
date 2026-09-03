from datetime import datetime
from pydantic import BaseModel, Field


class TherapyRecommendation(BaseModel):
    recommendation_id: str
    user_id: str
    therapy_type: str
    duration_minutes: int = Field(gt=0)
    recommended_schedule: str
    clinical_rationale: str
    expected_benefits: list[str]
    status: str = "RECOMMENDED"
    created_at: datetime


class TherapySession(BaseModel):
    session_id: str
    recommendation_id: str
    user_id: str
    therapy_type: str
    duration_minutes: int = Field(gt=0)
    status: str = "PENDING"
    started_at: datetime | None = None
    ended_at: datetime | None = None
    stop_reason: str | None = None