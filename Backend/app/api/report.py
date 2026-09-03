from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
from app.services.report_service import (
    get_clinical_report,
    get_recovery_history,
)


router = APIRouter(
    prefix="/reports",
    tags=["Recovery Analytics"],
)


@router.get("/{user_id}")
async def get_report(
    user_id: str,
    current_user: dict = Depends(get_current_user),
):
    return get_clinical_report(user_id)


@router.get("/{user_id}/history")
async def get_history(
    user_id: str,
    current_user: dict = Depends(get_current_user),
):
    return get_recovery_history(user_id)
