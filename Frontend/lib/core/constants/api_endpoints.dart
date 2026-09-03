// ============================================================
// RecoverX — API Endpoints
// All backend route paths are declared here.
// Do NOT hardcode paths anywhere else in the codebase.
// ============================================================

class ApiEndpoints {
  ApiEndpoints._();

  // ── Health ───────────────────────────────────────────────────
  static const String root = '/';
  static const String health = '/health';

  // ── Auth ─────────────────────────────────────────────────────
  static const String register = '/auth/register';

  // ── Progress ─────────────────────────────────────────────────
  static const String progressCreate = '/progress/';

  /// GET /progress/{user_id}
  static String progressGet(String userId) => '/progress/$userId';

  // ── Recovery ─────────────────────────────────────────────────
  static const String recoveryRecommendation = '/recovery/recommendation';
  static const String recoverySessionStart = '/recovery/session/start';

  // ── Reports ──────────────────────────────────────────────────
  /// GET /reports/{user_id}
  static String reports(String userId) => '/reports/$userId';

  /// GET /reports/{user_id}/history
  static String reportHistory(String userId) => '/reports/$userId/history';

  // ── Sensors ──────────────────────────────────────────────────
  /// POST /api/sensors/telemetry?user_id={user_id}
  static String sensorTelemetry(String userId) =>
      '/api/sensors/telemetry?user_id=$userId';
}
