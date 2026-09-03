// ============================================================
// RecoverX — Therapy & Session Models
// Matches FastAPI OpenAPI schemas for:
// - #/components/schemas/TherapyRecommendation
// - #/components/schemas/TherapySession
// ============================================================

class TherapyRecommendation {
  const TherapyRecommendation({
    required this.recommendationId,
    required this.userId,
    required this.therapyType,
    required this.durationMinutes,
    required this.recommendedSchedule,
    required this.clinicalRationale,
    required this.expectedBenefits,
    this.status = 'RECOMMENDED',
    required this.createdAt,
  });

  final String recommendationId;
  final String userId;
  final String therapyType;
  final int durationMinutes;
  final String recommendedSchedule;
  final String clinicalRationale;
  final List<String> expectedBenefits;
  final String status;
  final String createdAt;

  factory TherapyRecommendation.fromJson(Map<String, dynamic> json) {
    final rawBenefits = json['expected_benefits'];
    List<String> benefitsList = [];
    if (rawBenefits is List) {
      benefitsList = rawBenefits.map((e) => e.toString()).toList();
    }

    return TherapyRecommendation(
      recommendationId: (json['recommendation_id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      therapyType: (json['therapy_type'] as String?) ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      recommendedSchedule: (json['recommended_schedule'] as String?) ?? '',
      clinicalRationale: (json['clinical_rationale'] as String?) ?? '',
      expectedBenefits: benefitsList,
      status: (json['status'] as String?) ?? 'RECOMMENDED',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'recommendation_id': recommendationId,
        'user_id': userId,
        'therapy_type': therapyType,
        'duration_minutes': durationMinutes,
        'recommended_schedule': recommendedSchedule,
        'clinical_rationale': clinicalRationale,
        'expected_benefits': expectedBenefits,
        'status': status,
        'created_at': createdAt,
      };
}

class TherapySession {
  const TherapySession({
    required this.sessionId,
    required this.recommendationId,
    required this.userId,
    required this.therapyType,
    required this.durationMinutes,
    this.status = 'PENDING',
    this.startedAt,
    this.endedAt,
    this.stopReason,
  });

  final String sessionId;
  final String recommendationId;
  final String userId;
  final String therapyType;
  final int durationMinutes;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final String? stopReason;

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      sessionId: (json['session_id'] as String?) ?? '',
      recommendationId: (json['recommendation_id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      therapyType: (json['therapy_type'] as String?) ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'PENDING',
      startedAt: json['started_at'] as String?,
      endedAt: json['ended_at'] as String?,
      stopReason: json['stop_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'recommendation_id': recommendationId,
        'user_id': userId,
        'therapy_type': therapyType,
        'duration_minutes': durationMinutes,
        'status': status,
        if (startedAt != null) 'started_at': startedAt,
        if (endedAt != null) 'ended_at': endedAt,
        if (stopReason != null) 'stop_reason': stopReason,
      };
}
