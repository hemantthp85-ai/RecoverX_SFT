// ============================================================
// RecoverX — Telemetry Service
// Handles sending sensor telemetry to FastAPI backend.
// Endpoint: POST /api/sensors/telemetry?user_id={user_id}
// ============================================================

import '../core/constants/api_endpoints.dart';
import '../core/utils/result.dart';
import '../models/telemetry_models.dart';
import '../services/api_client.dart';

class TelemetryService {
  const TelemetryService(this._client);

  final ApiClient _client;

  /// Submits telemetry to `POST /api/sensors/telemetry?user_id=user_id`
  /// Returns a typed `Result<TelemetryResponse>` — never throws.
  Future<Result<TelemetryResponse>> submitTelemetry({
    required String userId,
    required TelemetryData telemetryData,
  }) async {
    final endpoint = ApiEndpoints.sensorTelemetry(userId);

    final result = await _client.post(
      endpoint,
      body: telemetryData.toJson(),
    );

    return result.when(
      success: (data) {
        try {
          final response = TelemetryResponse.fromJson(data, rawInput: telemetryData);
          return ResultSuccess(response);
        } catch (e) {
          return ResultFailure(
            Exception('Failed to parse telemetry response: $e'),
          );
        }
      },
      failure: (error) => ResultFailure(error),
    );
  }
}
