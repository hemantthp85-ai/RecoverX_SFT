// ============================================================
// RecoverX — Progress Provider
// Manages state for the Recovery Progress screen.
// Data flow: UI → ProgressProvider → ProgressService → ApiClient → GET /progress/{user_id}
// ============================================================

import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/recovery_progress.dart';
import '../services/api_client.dart';
import '../services/progress_service.dart';
import 'user_session.dart';

enum ProgressState { idle, loading, success, error }

class ProgressProvider extends ChangeNotifier {
  ProgressProvider({
    ProgressService? progressService,
    UserSession? userSession,
  })  : _service = progressService ?? ProgressService(ApiClient()),
        _session = userSession ?? UserSession.instance;

  final ProgressService _service;
  final UserSession _session;

  // ── State ─────────────────────────────────────────────────────
  ProgressState _state = ProgressState.idle;
  RecoveryProgress? _progress;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────
  ProgressState get state => _state;
  RecoveryProgress? get progress => _progress;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ProgressState.loading;
  bool get hasData => _state == ProgressState.success && _progress != null;
  bool get hasError => _state == ProgressState.error;

  String get currentUserId => _session.effectiveUserId;

  // ── Actions ───────────────────────────────────────────────────

  /// Fetch recovery progress data from backend.
  Future<void> fetchProgress() async {
    _setState(ProgressState.loading);

    final result = await _service.getProgress(_session.effectiveUserId);

    switch (result) {
      case ResultSuccess<RecoveryProgress>(:final data):
        _progress = data;
        _setState(ProgressState.success);
      case ResultFailure<RecoveryProgress>(:final error):
        _errorMessage = _friendlyMessage(error);
        _setState(ProgressState.error);
    }
  }

  /// Refresh progress data.
  Future<void> refresh() => fetchProgress();

  // ── Private Helpers ───────────────────────────────────────────
  void _setState(ProgressState newState) {
    _state = newState;
    notifyListeners();
  }

  String _friendlyMessage(Exception error) {
    final raw = error.toString();
    if (raw.contains('Unable to reach') || raw.contains('SocketException') || raw.contains('NetworkException')) {
      return 'Cannot connect to RecoverX server.\nPlease make sure the server is running.';
    }
    if (raw.contains('timed out') || raw.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (raw.contains('404') || raw.contains('not found')) {
      return 'No recovery progress data found for this user.';
    }
    return 'Failed to load recovery progress. Please try again.';
  }
}
