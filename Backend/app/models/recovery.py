from datetime import datetime, timezone


def create_therapy_recommendation_document(
    recommendation_id: str,
    user_id: str,
    therapy_type: str,
    duration_minutes: int,
    recommended_schedule: str,
    clinical_rationale: str,
    expected_benefits: list[str],
):
    return {
        "recommendation_id": recommendation_id,
        "user_id": user_id,
        "therapy_type": therapy_type,
        "duration_minutes": duration_minutes,
        "recommended_schedule": recommended_schedule,
        "clinical_rationale": clinical_rationale,
        "expected_benefits": expected_benefits,
        "status": "RECOMMENDED",
        "created_at": datetime.now(timezone.utc),
    }


def create_therapy_session_document(
    session_id: str,
    recommendation_id: str,
    user_id: str,
    therapy_type: str,
    duration_minutes: int,
):
    return {
        "session_id": session_id,
        "recommendation_id": recommendation_id,
        "user_id": user_id,
        "therapy_type": therapy_type,
        "duration_minutes": duration_minutes,
        "status": "PENDING",
        "started_at": None,
        "ended_at": None,
        "stop_reason": None,
        "created_at": datetime.now(timezone.utc),
    }