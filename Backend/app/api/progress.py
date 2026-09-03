from fastapi import APIRouter

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
):
    return create_recovery_progress(progress)


@router.get("/{user_id}")
async def get_progress(user_id: str):
    return get_recovery_progress(user_id)