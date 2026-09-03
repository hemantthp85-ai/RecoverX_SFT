from fastapi import HTTPException, status

from app.db.database import get_database
from app.models.recovery import (
    create_therapy_recommendation_document,
    create_therapy_session_document,
)
from app.schemas.recovery import (
    TherapyRecommendation,
    TherapySession,
)


def create_recommendation(
    recommendation: TherapyRecommendation,
):
    database = get_database()
    collection = database["therapy_recommendations"]

    document = create_therapy_recommendation_document(
        recommendation_id=recommendation.recommendation_id,
        user_id=recommendation.user_id,
        therapy_type=recommendation.therapy_type,
        duration_minutes=recommendation.duration_minutes,
        recommended_schedule=recommendation.recommended_schedule,
        clinical_rationale=recommendation.clinical_rationale,
        expected_benefits=recommendation.expected_benefits,
    )

    result = collection.insert_one(document)

    document["_id"] = str(result.inserted_id)

    return document


def start_therapy_session(
    session: TherapySession,
):
    database = get_database()

    recommendations = database["therapy_recommendations"]
    sessions = database["therapy_sessions"]

    # Make sure the recommendation exists
    recommendation = recommendations.find_one(
        {
            "recommendation_id": session.recommendation_id,
            "user_id": session.user_id,
        }
    )

    if not recommendation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Therapy recommendation not found",
        )

    # Prevent duplicate active sessions
    active_session = sessions.find_one(
        {
            "user_id": session.user_id,
            "status": "ACTIVE",
        }
    )

    if active_session:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An active therapy session already exists",
        )

    document = create_therapy_session_document(
        session_id=session.session_id,
        recommendation_id=session.recommendation_id,
        user_id=session.user_id,
        therapy_type=session.therapy_type,
        duration_minutes=session.duration_minutes,
    )

    result = sessions.insert_one(document)

    document["_id"] = str(result.inserted_id)

    return document