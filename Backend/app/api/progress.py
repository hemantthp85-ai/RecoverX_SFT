from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
from app.schemas.progress import RecoveryProgressResponse
from app.services.progress_service import (
    create_recovery_progress,
    get_recovery_progress,
)


router = APIRouter(
    prefix="/progress",
    tags=["Recovery Progress"],
)


@router.post("/")
async def create_progress(
    progress: RecoveryProgressResponse,
    current_user: dict = Depends(get_current_user),
):
    return create_recovery_progress(progress)


@router.get("/{user_id}")
async def get_progress(
    user_id: str,
    current_user: dict = Depends(get_current_user),
):
    return get_recovery_progress(user_id)