// ============================================================
// RecoverX — Recovery Service
// Handles therapy recommendations & recovery sessions.
// Endpoints:
// - POST /recovery/recommendation
// - POST /recovery/session/start
// ============================================================

import '../core/constants/api_endpoints.dart';
import '../core/utils/result.dart';
import '../models/therapy_models.dart';
import 'api_client.dart';

class RecoveryService {
  const RecoveryService(this._client);

  final ApiClient _client;

  /// Requests or creates a therapy recommendation via `POST /recovery/recommendation`
  Future<Result<TherapyRecommendation>> requestRecommendation(
      TherapyRecommendation recommendation) async {
    final result = await _client.post(
      ApiEndpoints.recoveryRecommendation,
      body: recommendation.toJson(),
    );

    return result.when(
      success: (data) {
        try {
          final parsed = TherapyRecommendation.fromJson(data);
          return ResultSuccess(parsed);
        } catch (e) {
          return ResultFailure(
            Exception('Failed to parse therapy recommendation: $e'),
          );
        }
      },
      failure: (error) => ResultFailure(error),
    );
  }

  /// Starts a recovery session via `POST /recovery/session/start`
  Future<Result<TherapySession>> startSession(
      TherapySession session) async {
    final result = await _client.post(
      ApiEndpoints.recoverySessionStart,
      body: session.toJson(),
    );

    return result.when(
      success: (data) {
        try {
          final parsed = TherapySession.fromJson(data);
          return ResultSuccess(parsed);
        } catch (e) {
          return ResultFailure(
            Exception('Failed to parse therapy session response: $e'),
          );
        }
      },
      failure: (error) => ResultFailure(error),
    );
  }
}
