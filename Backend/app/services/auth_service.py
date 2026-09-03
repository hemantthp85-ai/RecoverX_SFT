from fastapi import HTTPException, status

from app.db.database import get_database
from app.models.user import create_user_document
from app.schemas.auth import RegisterRequest


async def register_user(user: RegisterRequest):
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

    # Temporary placeholder.
    # Friend's security layer will provide the actual
    # bcrypt/Argon2 password hashing function.
    password_hash = user.password

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