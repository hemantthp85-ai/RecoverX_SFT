// ============================================================
// RecoverX — Reports Provider
// Manages state for Reports & Recovery History screen.
// Data flow: UI → ReportsProvider → ReportService → ApiClient → Backend GET /reports/
// ============================================================

import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/report_models.dart';
import '../services/api_client.dart';
import '../services/report_service.dart';
import 'user_session.dart';

enum ReportsState { idle, loading, success, error }

class ReportsProvider extends ChangeNotifier {
  ReportsProvider({
    ReportService? reportService,
    UserSession? userSession,
  })  : _service = reportService ?? ReportService(ApiClient()),
        _session = userSession ?? UserSession.instance;

  final ReportService _service;
  final UserSession _session;

  // ── State ─────────────────────────────────────────────────────
  ReportsState _state = ReportsState.idle;
  RecoveryReport? _latestReport;
  List<RecoveryHistoryItem> _historyItems = [];
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────
  ReportsState get state => _state;
  RecoveryReport? get latestReport => _latestReport;
  List<RecoveryHistoryItem> get historyItems => _historyItems;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ReportsState.loading;
  bool get hasLatestReport => _latestReport != null;
  bool get hasHistory => _historyItems.isNotEmpty;
  bool get hasError => _state == ReportsState.error;

  String get currentUserId => _session.effectiveUserId;

  // ── Actions ───────────────────────────────────────────────────

  /// Fetch latest report & history concurrently from backend.
  Future<void> fetchReports() async {
    _setState(ReportsState.loading);

    final userId = _session.effectiveUserId;

    final reportFuture = _service.getLatestReport(userId);
    final historyFuture = _service.getReportHistory(userId);

    final results = await Future.wait([reportFuture, historyFuture]);

    final reportResult = results[0] as Result<RecoveryReport>;
    final historyResult = results[1] as Result<List<RecoveryHistoryItem>>;

    bool hasAnySuccess = false;

    switch (reportResult) {
      case ResultSuccess<RecoveryReport>(:final data):
        _latestReport = data;
        hasAnySuccess = true;
      case ResultFailure<RecoveryReport>(:final error):
        _errorMessage = _friendlyMessage(error);
    }

    switch (historyResult) {
      case ResultSuccess<List<RecoveryHistoryItem>>(:final data):
        _historyItems = data;
        hasAnySuccess = true;
      case ResultFailure<List<RecoveryHistoryItem>>():
        // If history fails but report succeeds (or vice versa), handle gracefully
        break;
    }

    if (hasAnySuccess) {
      _setState(ReportsState.success);
    } else {
      _setState(ReportsState.error);
    }
  }

  /// Refresh latest report and history.
  Future<void> refresh() => fetchReports();

  // ── Private Helpers ───────────────────────────────────────────
  void _setState(ReportsState newState) {
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
    if (raw.contains('404') || raw.contains('not found')) {
      return 'No recovery reports found for this account.';
    }
    return 'Failed to load recovery reports. Please try again.';
  }
}
