// ============================================================
// RecoverX — Report Service
// Handles fetching latest recovery report & history analytics.
// Endpoints: GET /reports/{user_id} & GET /reports/{user_id}/history
// ============================================================

import '../core/constants/api_endpoints.dart';
import '../core/utils/result.dart';
import '../models/report_models.dart';
import 'api_client.dart';

class ReportService {
  const ReportService(this._client);

  final ApiClient _client;

  /// Fetches latest recovery report via `GET /reports/{user_id}`
  Future<Result<RecoveryReport>> getLatestReport(String userId) async {
    final result = await _client.get(ApiEndpoints.reports(userId));

    return result.when(
      success: (data) {
        try {
          final parsed = RecoveryReport.fromJson(data);
          return ResultSuccess(parsed);
        } catch (e) {
          return ResultFailure(
            Exception('Failed to parse latest recovery report: $e'),
          );
        }
      },
      failure: (error) => ResultFailure(error),
    );
  }

  /// Fetches historical recovery records via `GET /reports/{user_id}/history`
  Future<Result<List<RecoveryHistoryItem>>> getReportHistory(String userId) async {
    final result = await _client.getList(ApiEndpoints.reportHistory(userId));

    return result.when(
      success: (rawList) {
        try {
          final list = rawList
              .whereType<Map<String, dynamic>>()
              .map((json) => RecoveryHistoryItem.fromJson(json))
              .toList();
          return ResultSuccess(list);
        } catch (e) {
          return ResultFailure(
            Exception('Failed to parse recovery history list: $e'),
          );
        }
      },
      failure: (error) => ResultFailure(error),
    );
  }
}
