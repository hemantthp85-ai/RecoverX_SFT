// ============================================================
// RecoverX — UserSession
// A thin abstraction for the current user's identity.
// Authentication/login will populate this later; for now the
// dashboard and all other screens read from here instead of
// hardcoding a user_id anywhere.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class UserSession extends ChangeNotifier {
  UserSession._();

  static final UserSession _instance = UserSession._();
  static UserSession get instance => _instance;

  // ── Internal state ────────────────────────────────────────────
  String? _userId;
  String? _userEmail;
  String? _authToken;

  // ── Public getters ────────────────────────────────────────────
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get authToken => _authToken;

  bool get isAuthenticated => _userId != null && _userId!.isNotEmpty;

  // ── Initialise from SharedPreferences ─────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(AppConstants.keyUserId);
    _userEmail = prefs.getString(AppConstants.keyUserEmail);
    _authToken = prefs.getString(AppConstants.keyAuthToken);
    notifyListeners();
  }

  // ── Persist a session after login/register ────────────────────
  Future<void> setSession({
    required String userId,
    required String email,
    String? authToken,
  }) async {
    _userId = userId;
    _userEmail = email;
    _authToken = authToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, userId);
    await prefs.setString(AppConstants.keyUserEmail, email);
    if (authToken != null) {
      await prefs.setString(AppConstants.keyAuthToken, authToken);
    }
    notifyListeners();
  }

  // ── Clear session on logout ───────────────────────────────────
  Future<void> clearSession() async {
    _userId = null;
    _userEmail = null;
    _authToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyAuthToken);
    notifyListeners();
  }

  /// Returns the current user ID, or a fallback ID for development use.
  /// The fallback is only used when no real session exists yet.
  String get effectiveUserId => _userId ?? _kDevFallbackUserId;

  /// Development fallback user ID.
  /// IMPORTANT: This is ONLY used when no real user session exists.
  /// This value is isolated here — not scattered through the codebase.
  static const String _kDevFallbackUserId = 'test_user_001';
}
