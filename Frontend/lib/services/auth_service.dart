// ============================================================
// RecoverX — Auth Service
// Handles all authentication API calls: login and register.
// The Flutter login/register sends form-encoded data for login
// (matching the backend OAuth2PasswordRequestForm) and JSON for register.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/constants/api_endpoints.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static final Uri _base = Uri.parse(AppConstants.apiBaseUrl);

  // ── Login ─────────────────────────────────────────────────────────────────
  /// Calls POST /auth/login (form-encoded, OAuth2 compatible).
  /// Returns the JWT access_token string on success.
  /// Throws an [AuthException] on failure.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = _base.resolve(ApiEndpoints.login);

    // Backend uses OAuth2PasswordRequestForm → must be form-encoded
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'username': email.trim().toLowerCase(),
            'password': password,
            'grant_type': 'password',
          },
        )
        .timeout(AppConstants.httpTimeout);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body['access_token'] as String;
    }

    final detail = body['detail']?.toString() ?? 'Login failed';
    if (response.statusCode == 401) throw AuthException('Incorrect email or password.');
    if (response.statusCode == 422) throw AuthException('Invalid email format.');
    throw AuthException(detail);
  }

  // ── Register ──────────────────────────────────────────────────────────────
  /// Calls POST /auth/register (JSON body).
  /// Returns the new user_id string on success.
  /// Throws an [AuthException] on failure.
  Future<String> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required int age,
    required double heightCm,
    required double weightKg,
    String? gender,
    required String sport,
    String? sportLevel,
    String? position,
    String? dominantSide,
  }) async {
    final uri = _base.resolve(ApiEndpoints.register);

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'full_name': fullName.trim(),
            'email': email.trim().toLowerCase(),
            'password': password,
            'confirm_password': confirmPassword,
            'age': age,
            'height_cm': heightCm,
            'weight_kg': weightKg,
            'gender': gender,
            'sport': sport.trim(),
            'sport_level': sportLevel,
            'position': position,
            'dominant_side': dominantSide,
          }),
        )
        .timeout(AppConstants.httpTimeout);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return body['user_id'] as String;
    }

    final detail = body['detail']?.toString() ?? 'Registration failed';
    if (response.statusCode == 409) throw AuthException('Email already registered.');
    if (response.statusCode == 422) {
      // Pydantic validation error — extract first message
      if (body['detail'] is List) {
        final errors = body['detail'] as List;
        final msg = errors.isNotEmpty
            ? errors.first['msg']?.toString() ?? detail
            : detail;
        throw AuthException(msg);
      }
    }
    throw AuthException(detail);
  }

  void dispose() => _client.close();
}

// ── Auth Exception ────────────────────────────────────────────────────────────
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
