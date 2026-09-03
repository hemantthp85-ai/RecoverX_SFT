from datetime import datetime, timezone


def create_user_document(
    full_name: str,
    email: str,
    password_hash: str,
    age: int,
    height_cm: float,
    weight_kg: float,
    gender: str | None,
    sport: str,
    sport_level: str | None,
    position: str | None,
    dominant_side: str | None,
):
    return {
        "full_name": full_name,
        "email": email.lower(),
        "password_hash": password_hash,

        "athlete_profile": {
            "age": age,
            "height_cm": height_cm,
            "weight_kg": weight_kg,
            "gender": gender,
            "sport": sport,
            "sport_level": sport_level,
            "position": position,
            "dominant_side": dominant_side,
        },

        "role": "patient",
        "created_at": datetime.now(timezone.utc),
        "updated_at": datetime.now(timezone.utc),
    }