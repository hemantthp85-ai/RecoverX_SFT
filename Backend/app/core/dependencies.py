from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from app.core.security import decode_access_token
from app.db.database import get_database

# Tells FastAPI that the token must come from the Authorization: Bearer header.
# The tokenUrl points to the login endpoint so Swagger UI shows a login button.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


async def get_current_user(token: str = Depends(oauth2_scheme)) -> dict:
    """FastAPI dependency that validates the JWT and returns the current user.

    Usage in any route:
        current_user = Depends(get_current_user)

    Raises:
        HTTPException 401: If the token is missing, invalid, or expired.
        HTTPException 404: If the user no longer exists in the database.
    """
    payload = decode_access_token(token)

    email: str | None = payload.get("sub")
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    database = get_database()
    user = database["users"].find_one({"email": email})
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Return a safe subset (never expose password_hash to routes)
    return {
        "user_id": str(user["_id"]),
        "email": user["email"],
        "full_name": user["full_name"],
        "role": user.get("role", "patient"),
    }
