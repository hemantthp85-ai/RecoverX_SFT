// ============================================================
// RecoverX — Dashboard Provider
// Manages state for the Recovery Dashboard screen.
// Exposes: loading / error / success states.
// Uses ChangeNotifier so Provider can rebuild the UI.
// ============================================================

import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/recovery_progress.dart';
import '../models/wearable_status.dart';
import '../services/api_client.dart';
import '../services/progress_service.dart';
import '../providers/user_session.dart';

/// UI state enum — dashboard always has one of these.
enum DashboardState { idle, loading, success, error }

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    ProgressService? progressService,
    UserSession? userSession,
  })  : _service = progressService ?? ProgressService(ApiClient()),
        _session = userSession ?? UserSession.instance;

  final ProgressService _service;
  final UserSession _session;

  // ── State ─────────────────────────────────────────────────────
  DashboardState _state = DashboardState.idle;
  RecoveryProgress? _progress;
  String? _errorMessage;

  // Wearable connection — placeholder until BLE is integrated.
  final WearableConnectionStatus _wearableStatus =
      WearableConnectionStatus.disconnected;

  // ── Getters ───────────────────────────────────────────────────
  DashboardState get state => _state;
  RecoveryProgress? get progress => _progress;
  String? get errorMessage => _errorMessage;
  WearableConnectionStatus get wearableStatus => _wearableStatus;

  bool get isLoading => _state == DashboardState.loading;
  bool get hasData => _state == DashboardState.success && _progress != null;
  bool get hasError => _state == DashboardState.error;

  String get currentUserId => _session.effectiveUserId;

  // ── Actions ───────────────────────────────────────────────────

  /// Load or refresh dashboard data.
  Future<void> loadDashboard() async {
    _setState(DashboardState.loading);

    final result = await _service.getProgress(_session.effectiveUserId);

    switch (result) {
      case ResultSuccess<RecoveryProgress>(:final data):
        _progress = data;
        _setState(DashboardState.success);
      case ResultFailure<RecoveryProgress>(:final error):
        _errorMessage = _friendlyMessage(error);
        _setState(DashboardState.error);
    }
  }

  /// Retry after an error.
  Future<void> retry() => loadDashboard();

  // ── Private helpers ───────────────────────────────────────────
  void _setState(DashboardState newState) {
    _state = newState;
    notifyListeners();
  }

  String _friendlyMessage(Exception error) {
    final raw = error.toString();
    if (raw.contains('Unable to reach') || raw.contains('SocketException')) {
      return 'Cannot connect to the backend.\nMake sure the RecoverX server is running.';
    }
    if (raw.contains('timed out') || raw.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (raw.contains('401') || raw.contains('Unauthorised')) {
      return 'Session expired. Please log in again.';
    }
    if (raw.contains('404') || raw.contains('not found')) {
      return 'No recovery data found for this user.';
    }
    return 'Something went wrong. Please try again.';
  }
}
