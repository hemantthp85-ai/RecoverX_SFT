from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class SensorReadingCreate(BaseModel):
    temperature: Optional[float] = Field(default=None)
    angle_x: Optional[float] = Field(default=None)
    angle_y: Optional[float] = Field(default=None)
    pressure: Optional[float] = Field(default=None)
    heart_rate: Optional[float] = Field(default=None)
    spo2: Optional[float] = Field(default=None)


class SensorReadingResponse(SensorReadingCreate):
    user_id: str
    timestamp: datetime