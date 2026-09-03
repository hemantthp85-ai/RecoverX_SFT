from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm

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
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """Login with email and password. Returns a JWT access token.
    
    Note: The 'username' field here is your email address.
    This format is required for Swagger UI compatibility.
    """
    # OAuth2PasswordRequestForm uses 'username' field — we treat it as email
    credentials = LoginRequest(email=form_data.username, password=form_data.password)
    return await login_user(credentials)
