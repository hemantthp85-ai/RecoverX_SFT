// ============================================================
// RecoverX — Therapy Provider
// Manages state for therapy recommendations & session lifecycle.
// States:
// - idle
// - loadingRecommendation
// - recommendationSuccess
// - recommendationError
// - startingSession
// - sessionSuccess
// - sessionError
// ============================================================

import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/therapy_models.dart';
import '../services/api_client.dart';
import '../services/recovery_service.dart';
import 'user_session.dart';

enum TherapyState {
  idle,
  loadingRecommendation,
  recommendationSuccess,
  recommendationError,
  startingSession,
  sessionSuccess,
  sessionError,
}

class TherapyProvider extends ChangeNotifier {
  TherapyProvider({
    RecoveryService? recoveryService,
    UserSession? userSession,
  })  : _service = recoveryService ?? RecoveryService(ApiClient()),
        _session = userSession ?? UserSession.instance;

  final RecoveryService _service;
  final UserSession _session;

  // ── State ─────────────────────────────────────────────────────
  TherapyState _state = TherapyState.idle;
  TherapyRecommendation? _recommendation;
  TherapySession? _sessionData;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────
  TherapyState get state => _state;
  TherapyRecommendation? get recommendation => _recommendation;
  TherapySession? get sessionData => _sessionData;
  String? get errorMessage => _errorMessage;

  bool get isLoadingRecommendation => _state == TherapyState.loadingRecommendation;
  bool get isStartingSession => _state == TherapyState.startingSession;
  bool get hasRecommendation => _recommendation != null;
  bool get hasActiveSession => _sessionData != null;
  bool get hasError => _state == TherapyState.recommendationError || _state == TherapyState.sessionError;

  String get currentUserId => _session.effectiveUserId;

  // ── Actions ───────────────────────────────────────────────────

  /// Request therapy recommendation from backend.
  Future<void> fetchRecommendation() async {
    _setState(TherapyState.loadingRecommendation);

    final payload = TherapyRecommendation(
      recommendationId: 'REC_${DateTime.now().millisecondsSinceEpoch}',
      userId: _session.effectiveUserId,
      therapyType: 'VIBRATION',
      durationMinutes: 15,
      recommendedSchedule: 'Daily - Post Activity',
      clinicalRationale: 'Targeted vibration therapy to reduce muscle stiffness and promote local blood flow.',
      expectedBenefits: [
        'Enhanced tissue recovery',
        'Reduced muscle soreness',
        'Improved joint flexibility',
      ],
      status: 'RECOMMENDED',
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    final result = await _service.requestRecommendation(payload);

    switch (result) {
      case ResultSuccess<TherapyRecommendation>(:final data):
        _recommendation = data;
        _setState(TherapyState.recommendationSuccess);
      case ResultFailure<TherapyRecommendation>(:final error):
        // Fallback: if server unavailable/error, hold payload as active recommendation if needed or set error
        _errorMessage = _friendlyMessage(error);
        _setState(TherapyState.recommendationError);
    }
  }

  /// Start a recovery session for the current recommendation.
  /// Prevents duplicate submissions.
  Future<void> startSession() async {
    if (isStartingSession) return; // Prevent duplicate requests while loading

    if (_recommendation == null) {
      _errorMessage = 'No active recommendation available to start session.';
      _setState(TherapyState.sessionError);
      return;
    }

    _setState(TherapyState.startingSession);

    final sessionPayload = TherapySession(
      sessionId: 'SES_${DateTime.now().millisecondsSinceEpoch}',
      recommendationId: _recommendation!.recommendationId,
      userId: _session.effectiveUserId,
      therapyType: _recommendation!.therapyType,
      durationMinutes: _recommendation!.durationMinutes,
      status: 'PENDING',
      startedAt: DateTime.now().toUtc().toIso8601String(),
    );

    final result = await _service.startSession(sessionPayload);

    switch (result) {
      case ResultSuccess<TherapySession>(:final data):
        _sessionData = data;
        _setState(TherapyState.sessionSuccess);
      case ResultFailure<TherapySession>(:final error):
        _errorMessage = _friendlyMessage(error);
        _setState(TherapyState.sessionError);
    }
  }

  // ── Private Helpers ───────────────────────────────────────────
  void _setState(TherapyState newState) {
    _state = newState;
    notifyListeners();
  }

  String _friendlyMessage(Exception error) {
    final raw = error.toString();
    if (raw.contains('Unable to reach') || raw.contains('SocketException') || raw.contains('NetworkException')) {
      return 'Cannot connect to RecoverX server.\nPlease verify the backend is running.';
    }
    if (raw.contains('timed out') || raw.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    return 'Failed to complete recovery action. Please try again.';
  }
}
