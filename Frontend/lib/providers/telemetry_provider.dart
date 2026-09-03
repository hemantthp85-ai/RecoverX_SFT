// ============================================================
// RecoverX — Telemetry Provider
// Manages state for live telemetry & BLE wearable connection.
// States: idle, sending, success, error, unavailable.
// Decouples ~500ms live BLE UI updates from ~2s throttled backend API persistence.
// ============================================================

import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/telemetry_models.dart';
import '../models/wearable_status.dart';
import '../services/api_client.dart';
import '../services/bluetooth_service.dart';
import '../services/telemetry_service.dart';
import 'user_session.dart';

enum TelemetryState {
  /// Initial state before any submission attempt
  idle,

  /// Currently sending telemetry to backend
  sending,

  /// Received valid telemetry analysis from backend
  success,

  /// Error occurred during API call or processing
  error,

  /// Backend or sensor stream is unavailable / no telemetry data received
  unavailable,
}

class TelemetryProvider extends ChangeNotifier {
  TelemetryProvider({
    TelemetryService? telemetryService,
    UserSession? userSession,
    BluetoothService? bluetoothService,
  })  : _service = telemetryService ?? TelemetryService(ApiClient()),
        _session = userSession ?? UserSession.instance {
    _bluetoothService = bluetoothService ??
        BluetoothService(
          onTelemetryReceived: _handleBleTelemetry,
          onStatusChanged: _handleBleStatusChanged,
        );
    _wearableStatus = _bluetoothService.status;
  }

  final TelemetryService _service;
  final UserSession _session;
  late final BluetoothService _bluetoothService;

  // ── Internal State ────────────────────────────────────────────
  TelemetryState _state = TelemetryState.idle;
  TelemetryResponse? _response;
  TelemetryData? _lastSentData;
  TelemetryData? _latestTelemetry;
  String? _errorMessage;
  WearableConnectionStatus _wearableStatus = WearableConnectionStatus.disconnected;

  // Throttling & persistence state
  DateTime? _lastApiSubmitTime;
  bool _isSubmittingApi = false;

  // ── Public Getters ────────────────────────────────────────────
  TelemetryState get state => _state;
  TelemetryResponse? get response => _response;
  TelemetryData? get lastSentData => _lastSentData;
  TelemetryData? get latestTelemetry => _latestTelemetry;
  String? get errorMessage => _errorMessage;
  WearableConnectionStatus get wearableStatus => _wearableStatus;
  bool get isConnected => _bluetoothService.isConnected;

  bool get isSending => _state == TelemetryState.sending;
  bool get hasData => _response != null || _latestTelemetry != null;
  bool get hasError => _state == TelemetryState.error;
  bool get isUnavailable =>
      _state == TelemetryState.unavailable ||
      (_state == TelemetryState.idle && _response == null && _latestTelemetry == null);

  String get currentUserId => _session.effectiveUserId;

  // ── BLE Connection Actions ───────────────────────────────────

  /// Starts BLE scanning and connects automatically when RecoverX_Wearable is found.
  Future<void> connectWearable() async {
    await _bluetoothService.startScanAndConnect();
  }

  /// Disconnects active BLE connection and stops streams.
  Future<void> disconnectWearable() async {
    await _bluetoothService.disconnect();
  }

  bool _isDisposed = false;

  // ── BLE Callbacks ─────────────────────────────────────────────

  void _handleBleTelemetry(TelemetryData data) {
    if (_isDisposed) return;
    _latestTelemetry = data;
    notifyListeners();

    // Asynchronously trigger throttled persistence using the newest available telemetry sample
    _triggerThrottledApiSubmit();
  }

  void _triggerThrottledApiSubmit() {
    final now = DateTime.now();
    if (_isSubmittingApi) return;
    if (_lastApiSubmitTime != null &&
        now.difference(_lastApiSubmitTime!) < const Duration(seconds: 2)) {
      return;
    }

    final dataToSubmit = _latestTelemetry;
    if (dataToSubmit == null) return;

    _isSubmittingApi = true;
    _lastApiSubmitTime = now;

    _service
        .submitTelemetry(
      userId: _session.effectiveUserId,
      telemetryData: dataToSubmit,
    )
        .then((result) {
      if (_isDisposed) return;
      _isSubmittingApi = false;
      switch (result) {
        case ResultSuccess<TelemetryResponse>(:final data):
          _response = data;
          _lastSentData = dataToSubmit;
          _state = TelemetryState.success;
          notifyListeners();
        case ResultFailure<TelemetryResponse>(:final error):
          debugPrint('[TelemetryProvider] Background submission error (non-fatal): $error');
      }
    }).catchError((e) {
      if (_isDisposed) return;
      _isSubmittingApi = false;
      debugPrint('[TelemetryProvider] Background submission exception (non-fatal): $e');
    });
  }

  void _handleBleStatusChanged(WearableConnectionStatus status) {
    if (_isDisposed) return;
    _wearableStatus = status;
    notifyListeners();
  }

  // ── Backend API Actions ───────────────────────────────────────

  /// Manual telemetry submission trigger.
  Future<void> sendTelemetry(TelemetryData data) async {
    _lastSentData = data;
    _setState(TelemetryState.sending);

    final result = await _service.submitTelemetry(
      userId: _session.effectiveUserId,
      telemetryData: data,
    );

    switch (result) {
      case ResultSuccess<TelemetryResponse>(:final data):
        _response = data;
        _setState(TelemetryState.success);
      case ResultFailure<TelemetryResponse>(:final error):
        _errorMessage = _friendlyMessage(error);
        _setState(TelemetryState.error);
    }
  }

  /// Reset provider to unavailable state
  void reset() {
    _response = null;
    _lastSentData = null;
    _latestTelemetry = null;
    _errorMessage = null;
    _setState(TelemetryState.unavailable);
  }

  // ── Private Helpers ───────────────────────────────────────────
  void _setState(TelemetryState newState) {
    _state = newState;
    notifyListeners();
  }

  String _friendlyMessage(Exception error) {
    final raw = error.toString();
    if (raw.contains('Unable to reach') || raw.contains('SocketException') || raw.contains('NetworkException')) {
      return 'Cannot connect to RecoverX server.\nEnsure backend is running.';
    }
    if (raw.contains('timed out') || raw.contains('TimeoutException')) {
      return 'Telemetry submission timed out. Please try again.';
    }
    if (raw.contains('500') || raw.contains('ServerException')) {
      return 'Backend error processing telemetry. Check server logs.';
    }
    return 'Failed to send telemetry. Please check server connection.';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bluetoothService.dispose();
    super.dispose();
  }
}
