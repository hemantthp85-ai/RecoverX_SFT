from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
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
    current_user: dict = Depends(get_current_user),
):
    return create_recommendation(recommendation)


@router.post("/session/start")
async def start_recovery_session(
    session: TherapySession,
    current_user: dict = Depends(get_current_user),
):
    return start_therapy_session(session)
