// ============================================================
// RecoverX — App Constants
// Central location for all application-wide constants.
// ============================================================

class AppConstants {
  AppConstants._();

  // ── App Identity ────────────────────────────────────────────
  static const String appName = 'RecoverX';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Wearable Recovery System';

  // ── API ─────────────────────────────────────────────────────
  /// Base URL for the RecoverX FastAPI backend.
  /// Laptop IP address for physical Android phone testing.
  static const String apiBaseUrl = 'http://10.255.14.3:8000';

  /// HTTP request timeout duration.
  static const Duration httpTimeout = Duration(seconds: 15);

  // ── Storage Keys ─────────────────────────────────────────────
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyOnboardingDone = 'onboarding_done';

  // ── Spacing ───────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border Radius ─────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // ── Icon Sizes ────────────────────────────────────────────────
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // ── Animation Durations ───────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
}
