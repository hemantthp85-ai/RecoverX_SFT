from fastapi import APIRouter

from app.schemas.recovery import (
    TherapyRecommendation,
    TherapySession,
)
from app.services.recovery_service import (
    create_recommendation,
    start_therapy_session,
)


router = APIRouter(
    prefix="/recovery",
    tags=["Recovery"],
)


@router.post("/recommendation")
async def create_therapy_recommendation(
    recommendation: TherapyRecommendation,
):
    return create_recommendation(recommendation)


@router.post("/session/start")
async def start_recovery_session(
    session: TherapySession,
):
    return start_therapy_session(session)
