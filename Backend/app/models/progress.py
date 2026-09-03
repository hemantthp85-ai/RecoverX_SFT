from datetime import datetime, timezone


def create_recovery_progress_document(
    user_id: str,
    recovery_score: float,
    recovery_stage: str,
    progress_status: str,
    summary: str | None,
    temperature: dict,
    swelling: dict,
    joint_mobility: dict,
    blood_flow: dict,
):
    return {
        "user_id": user_id,

        "recovery_score": recovery_score,
        "recovery_stage": recovery_stage,
        "progress_status": progress_status,

        "summary": summary,

        "physiological_metrics": {
            "temperature": temperature,
            "swelling": swelling,
            "joint_mobility": joint_mobility,
            "blood_flow": blood_flow,
        },

        "updated_at": datetime.now(timezone.utc),
    }