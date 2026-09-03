// ============================================================
// RecoverX — Report & History Models
// Represents the latest recovery report and historical analytics records.
// Matches endpoints: GET /reports/{user_id} & GET /reports/{user_id}/history
// ============================================================

import 'physiological_metric.dart';

class RecoveryReport {
  const RecoveryReport({
    required this.userId,
    this.recoveryScore,
    this.recoveryStage,
    this.progressStatus,
    this.summary,
    this.safetyStatus,
    this.therapyRecommendation,
    this.createdAt,
    this.temperature,
    this.swelling,
    this.jointMobility,
    this.bloodFlow,
  });

  final String userId;
  final double? recoveryScore;
  final String? recoveryStage;
  final String? progressStatus;
  final String? summary;
  final String? safetyStatus;
  final String? therapyRecommendation;
  final String? createdAt;

  final PhysiologicalMetric? temperature;
  final PhysiologicalMetric? swelling;
  final PhysiologicalMetric? jointMobility;
  final PhysiologicalMetric? bloodFlow;

  factory RecoveryReport.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? metrics;
    if (json['physiological_metrics'] is Map<String, dynamic>) {
      metrics = json['physiological_metrics'] as Map<String, dynamic>;
    } else if (json['metrics'] is Map<String, dynamic>) {
      metrics = json['metrics'] as Map<String, dynamic>;
    }

    return RecoveryReport(
      userId: (json['user_id'] as String?) ?? '',
      recoveryScore: (json['recovery_score'] as num?)?.toDouble() ??
          (json['score'] as num?)?.toDouble(),
      recoveryStage: (json['recovery_stage'] as String?) ?? json['stage'] as String?,
      progressStatus: (json['progress_status'] as String?) ?? json['status'] as String?,
      summary: json['summary'] as String?,
      safetyStatus: (json['safety_status'] as String?) ?? json['safety'] as String?,
      therapyRecommendation: (json['therapy_recommendation'] as String?) ??
          json['recommendation'] as String?,
      createdAt: (json['created_at'] as String?) ??
          (json['updated_at'] as String?) ??
          json['timestamp'] as String?,
      temperature: metrics?['temperature'] != null && metrics!['temperature'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['temperature'] as Map<String, dynamic>)
          : (json['temperature'] is Map<String, dynamic>
              ? PhysiologicalMetric.fromJson(json['temperature'] as Map<String, dynamic>)
              : null),
      swelling: metrics?['swelling'] != null && metrics!['swelling'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['swelling'] as Map<String, dynamic>)
          : (json['swelling'] is Map<String, dynamic>
              ? PhysiologicalMetric.fromJson(json['swelling'] as Map<String, dynamic>)
              : null),
      jointMobility: metrics?['joint_mobility'] != null && metrics!['joint_mobility'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['joint_mobility'] as Map<String, dynamic>)
          : (json['joint_mobility'] is Map<String, dynamic>
              ? PhysiologicalMetric.fromJson(json['joint_mobility'] as Map<String, dynamic>)
              : null),
      bloodFlow: metrics?['blood_flow'] != null && metrics!['blood_flow'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['blood_flow'] as Map<String, dynamic>)
          : (json['blood_flow'] is Map<String, dynamic>
              ? PhysiologicalMetric.fromJson(json['blood_flow'] as Map<String, dynamic>)
              : null),
    );
  }
}

class RecoveryHistoryItem {
  const RecoveryHistoryItem({
    this.id,
    required this.userId,
    this.recoveryScore,
    this.recoveryStage,
    this.progressStatus,
    this.summary,
    this.createdAt,
    this.temperature,
    this.swelling,
    this.jointMobility,
    this.bloodFlow,
  });

  final String? id;
  final String userId;
  final double? recoveryScore;
  final String? recoveryStage;
  final String? progressStatus;
  final String? summary;
  final String? createdAt;

  final PhysiologicalMetric? temperature;
  final PhysiologicalMetric? swelling;
  final PhysiologicalMetric? jointMobility;
  final PhysiologicalMetric? bloodFlow;

  factory RecoveryHistoryItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? metrics;
    if (json['physiological_metrics'] is Map<String, dynamic>) {
      metrics = json['physiological_metrics'] as Map<String, dynamic>;
    } else if (json['metrics'] is Map<String, dynamic>) {
      metrics = json['metrics'] as Map<String, dynamic>;
    }

    return RecoveryHistoryItem(
      id: (json['_id'] ?? json['id'] ?? json['report_id'])?.toString(),
      userId: (json['user_id'] as String?) ?? '',
      recoveryScore: (json['recovery_score'] as num?)?.toDouble() ??
          (json['score'] as num?)?.toDouble(),
      recoveryStage: (json['recovery_stage'] as String?) ?? json['stage'] as String?,
      progressStatus: (json['progress_status'] as String?) ?? json['status'] as String?,
      summary: json['summary'] as String?,
      createdAt: (json['created_at'] as String?) ??
          (json['updated_at'] as String?) ??
          json['timestamp'] as String?,
      temperature: metrics?['temperature'] != null && metrics!['temperature'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['temperature'] as Map<String, dynamic>)
          : null,
      swelling: metrics?['swelling'] != null && metrics!['swelling'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['swelling'] as Map<String, dynamic>)
          : null,
      jointMobility: metrics?['joint_mobility'] != null && metrics!['joint_mobility'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['joint_mobility'] as Map<String, dynamic>)
          : null,
      bloodFlow: metrics?['blood_flow'] != null && metrics!['blood_flow'] is Map<String, dynamic>
          ? PhysiologicalMetric.fromJson(metrics['blood_flow'] as Map<String, dynamic>)
          : null,
    );
  }
}
