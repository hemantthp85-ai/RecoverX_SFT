from fastapi import HTTPException, status

from app.core.security import hash_password, verify_password, create_access_token
from app.db.database import get_database
from app.models.user import create_user_document
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse


async def register_user(user: RegisterRequest) -> dict:
    """Register a new user with a bcrypt-hashed password."""
    database = get_database()
    users_collection = database["users"]

    # Check whether email already exists
    existing_user = users_collection.find_one(
        {"email": user.email.lower()}
    )

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        )

    # Hash the password with bcrypt before storing
    password_hash = hash_password(user.password)

    user_document = create_user_document(
        full_name=user.full_name,
        email=user.email,
        password_hash=password_hash,
        age=user.age,
        height_cm=user.height_cm,
        weight_kg=user.weight_kg,
        gender=user.gender,
        sport=user.sport,
        sport_level=user.sport_level,
        position=user.position,
        dominant_side=user.dominant_side,
    )

    result = users_collection.insert_one(user_document)

    return {
        "message": "Registration successful",
        "user_id": str(result.inserted_id),
    }


async def login_user(credentials: LoginRequest) -> TokenResponse:
    """Verify email/password and return a JWT access token."""
    database = get_database()
    users_collection = database["users"]

    # Look up user by email
    user = users_collection.find_one({"email": credentials.email.lower()})

    if not user or not verify_password(credentials.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Issue JWT — the 'sub' (subject) claim holds the user's email
    access_token = create_access_token(data={"sub": user["email"]})

    return TokenResponse(access_token=access_token)