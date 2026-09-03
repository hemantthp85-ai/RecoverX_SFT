// ============================================================
// RecoverX — Wearable Connection Status Enum
// Abstraction for BLE wearable connection state.
// Used across BluetoothService, TelemetryProvider & UI widgets.
// ============================================================

enum WearableConnectionStatus {
  unknown,
  disconnected,
  scanning,
  connecting,
  connected,
  discoveringServices,
  subscribing,
  receiving,
  error,
}

extension WearableConnectionStatusX on WearableConnectionStatus {
  String get label => switch (this) {
        WearableConnectionStatus.unknown => 'Unavailable',
        WearableConnectionStatus.disconnected => 'Disconnected',
        WearableConnectionStatus.scanning => 'Scanning…',
        WearableConnectionStatus.connecting => 'Connecting…',
        WearableConnectionStatus.connected => 'Connected',
        WearableConnectionStatus.discoveringServices => 'Discovering Services…',
        WearableConnectionStatus.subscribing => 'Subscribing…',
        WearableConnectionStatus.receiving => 'Receiving Telemetry',
        WearableConnectionStatus.error => 'Connection Error',
      };

  bool get isConnected =>
      this == WearableConnectionStatus.connected ||
      this == WearableConnectionStatus.discoveringServices ||
      this == WearableConnectionStatus.subscribing ||
      this == WearableConnectionStatus.receiving;
}
