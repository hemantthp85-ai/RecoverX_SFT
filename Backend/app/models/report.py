from datetime import datetime, timezone


def create_clinical_report_document(
    user_id,
    patient_information,
    recovery_score,
    recovery_status,
    recovery_insight,
    skin_temperature,
    circulatory_flow,
    joint_rom,
    swelling,
    clinician_notes=None,
    clinician_name=None,
    clinician_designation=None,
):
    return {
        "user_id": user_id,
        "patient_information": patient_information.model_dump(),

        "recovery_score": recovery_score,
        "recovery_status": recovery_status,
        "recovery_insight": recovery_insight,

        "skin_temperature": skin_temperature.model_dump(),
        "circulatory_flow": circulatory_flow.model_dump(),
        "joint_rom": joint_rom.model_dump(),
        "swelling": swelling.model_dump(),

        "clinician_notes": clinician_notes,
        "clinician_name": clinician_name,
        "clinician_designation": clinician_designation,

        "created_at": datetime.now(timezone.utc),
        "updated_at": datetime.now(timezone.utc),
    }


def create_recovery_history_document(
    user_id,
    session_id,
    therapy_type,
    date_time,
    duration_minutes,
    progress_before,
    progress_after,
):
    return {
        "user_id": user_id,
        "session_id": session_id,
        "therapy_type": therapy_type,
        "date_time": date_time,
        "duration_minutes": duration_minutes,
        "progress_before": progress_before,
        "progress_after": progress_after,
        "created_at": datetime.now(timezone.utc),
    }