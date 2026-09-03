from fastapi import APIRouter

from app.schemas.auth import RegisterRequest
from app.services.auth_service import register_user


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/register")
async def register(user: RegisterRequest):
    return await register_user(user)