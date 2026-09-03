// ============================================================
// RecoverX — RecoveryProgress model
// Exact match to #/components/schemas/RecoveryProgressResponse
// Verified against GET /openapi.json from running backend.
// ============================================================

import 'physiological_metric.dart';

class RecoveryProgress {
  const RecoveryProgress({
    required this.userId,
    required this.recoveryScore,
    required this.recoveryStage,
    required this.progressStatus,
    this.summary,
    this.updatedAt,
    required this.temperature,
    required this.swelling,
    required this.jointMobility,
    required this.bloodFlow,
  });

  final String userId;

  /// 0–100 numeric score from the backend.
  final double recoveryScore;

  /// e.g. "SUBACUTE_RECOVERY", "ACUTE", "CHRONIC" — backend decides.
  final String recoveryStage;

  /// e.g. "ON_TRACK", "NEEDS_ATTENTION" — backend decides.
  final String progressStatus;

  /// Optional clinical summary text from the backend.
  final String? summary;

  /// Optional last updated timestamp from backend.
  final String? updatedAt;

  final PhysiologicalMetric temperature;
  final PhysiologicalMetric swelling;
  final PhysiologicalMetric jointMobility;
  final PhysiologicalMetric bloodFlow;

  factory RecoveryProgress.fromJson(Map<String, dynamic> json) {
    // The backend nests all four physiological metrics under 'physiological_metrics'.
    // Verified against live GET /progress/test_user_001 response.
    final metrics = json['physiological_metrics'] as Map<String, dynamic>;

    return RecoveryProgress(
      userId: json['user_id'] as String,
      recoveryScore: (json['recovery_score'] as num).toDouble(),
      recoveryStage: json['recovery_stage'] as String,
      progressStatus: json['progress_status'] as String,
      summary: json['summary'] as String?,
      updatedAt: json['updated_at'] as String?,
      temperature: PhysiologicalMetric.fromJson(
        metrics['temperature'] as Map<String, dynamic>,
      ),
      swelling: PhysiologicalMetric.fromJson(
        metrics['swelling'] as Map<String, dynamic>,
      ),
      jointMobility: PhysiologicalMetric.fromJson(
        metrics['joint_mobility'] as Map<String, dynamic>,
      ),
      bloodFlow: PhysiologicalMetric.fromJson(
        metrics['blood_flow'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  String toString() =>
      'RecoveryProgress(userId: $userId, score: $recoveryScore, '
      'stage: $recoveryStage, status: $progressStatus)';
}
