from fastapi import HTTPException, status

from app.db.database import get_database


def get_clinical_report(user_id: str):
    database = get_database()

    progress_collection = database["recovery_progress"]

    progress = progress_collection.find_one(
        {"user_id": user_id},
        sort=[("updated_at", -1)],
    )

    if not progress:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recovery progress not found",
        )

    progress.pop("_id", None)

    return progress


def get_recovery_history(user_id: str):
    database = get_database()

    sessions_collection = database["therapy_sessions"]

    sessions = list(
        sessions_collection.find(
            {"user_id": user_id}
        ).sort("created_at", -1)
    )

    history = []

    for session in sessions:
        history.append(
            {
                "session_id": session.get("session_id"),
                "therapy_type": session.get("therapy_type"),
                "date_time": session.get("created_at"),
                "duration_minutes": session.get("duration_minutes"),
                "progress_before": session.get("progress_before", 0),
                "progress_after": session.get("progress_after", 0),
            }
        )

    return {
        "user_id": user_id,
        "sessions": history,
    }