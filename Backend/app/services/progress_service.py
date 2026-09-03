from fastapi import HTTPException, status

from app.db.database import get_database
from app.models.progress import create_recovery_progress_document
from app.schemas.progress import RecoveryProgressResponse


def get_recovery_progress(user_id: str):
    database = get_database()
    collection = database["recovery_progress"]

    document = collection.find_one(
        {"user_id": user_id},
        sort=[("updated_at", -1)],
    )

    if not document:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recovery progress not found",
        )

    document["_id"] = str(document["_id"])

    return document


def create_recovery_progress(
    progress: RecoveryProgressResponse,
):
    database = get_database()
    collection = database["recovery_progress"]

    document = create_recovery_progress_document(
        user_id=progress.user_id,
        recovery_score=progress.recovery_score,
        recovery_stage=progress.recovery_stage,
        progress_status=progress.progress_status,
        summary=progress.summary,
        temperature=progress.temperature.model_dump(),
        swelling=progress.swelling.model_dump(),
        joint_mobility=progress.joint_mobility.model_dump(),
        blood_flow=progress.blood_flow.model_dump(),
    )

    result = collection.insert_one(document)

    document["_id"] = str(result.inserted_id)

    return document