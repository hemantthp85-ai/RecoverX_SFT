// ============================================================
// RecoverX — Health Service
// Wraps the /health and / endpoints to check backend status.
// ============================================================

import '../core/utils/result.dart';
import '../core/constants/api_endpoints.dart';
import 'api_client.dart';

class HealthService {
  const HealthService(this._client);
  final ApiClient _client;

  /// Ping the backend root endpoint.
  Future<Result<Map<String, dynamic>>> ping() =>
      _client.get(ApiEndpoints.root);

  /// Check backend health status.
  Future<Result<Map<String, dynamic>>> checkHealth() =>
      _client.get(ApiEndpoints.health);

  /// Returns true if the backend is reachable.
  Future<bool> isBackendReachable() async {
    final result = await checkHealth();
    return result.isSuccess;
  }
}
