from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    remember_me: bool = False


class RegisterRequest(BaseModel):
    # Account details
    full_name: str
    email: EmailStr
    password: str
    confirm_password: str

    # Athlete details
    age: int
    height_cm: float
    weight_kg: float
    gender: str | None = None
    sport: str
    sport_level: str | None = None
    position: str | None = None
    dominant_side: str | None = None