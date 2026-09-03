from pydantic import BaseModel, EmailStr, model_validator


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

    @model_validator(mode="after")
    def passwords_must_match(self) -> "RegisterRequest":
        if self.password != self.confirm_password:
            raise ValueError("Passwords do not match")
        if len(self.password) < 8:
            raise ValueError("Password must be at least 8 characters long")
        return self


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"