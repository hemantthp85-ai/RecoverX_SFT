// ============================================================
// RecoverX — Progress Service
// Wraps ApiClient for /progress/ endpoints.
// No HTTP logic lives outside this file.
// ============================================================

import '../core/constants/api_endpoints.dart';
import '../core/utils/result.dart';
import '../models/recovery_progress.dart';
import '../services/api_client.dart';

class ProgressService {
  const ProgressService(this._client);
  final ApiClient _client;

  /// GET /progress/{user_id}
  /// Returns a typed Result — never throws.
  Future<Result<RecoveryProgress>> getProgress(String userId) async {
    final result = await _client.get(ApiEndpoints.progressGet(userId));
    return result.when(
      success: (data) {
        try {
          return ResultSuccess(RecoveryProgress.fromJson(data));
        } catch (e) {
          return ResultFailure(
            Exception('Failed to parse progress data: $e'),
          );
        }
      },
      failure: (error) => ResultFailure(error),
    );
  }
}
