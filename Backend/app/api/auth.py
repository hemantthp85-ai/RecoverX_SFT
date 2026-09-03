from fastapi import APIRouter

from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse
from app.services.auth_service import login_user, register_user


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/register", status_code=201)
async def register(user: RegisterRequest):
    """Register a new user account."""
    return await register_user(user)


@router.post("/login", response_model=TokenResponse)
async def login(credentials: LoginRequest):
    """Login with email and password. Returns a JWT access token."""
    return await login_user(credentials)