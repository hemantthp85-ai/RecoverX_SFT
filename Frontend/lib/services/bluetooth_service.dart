// ============================================================
// RecoverX — Bluetooth Service (BLE Integration)
// Scans, connects & receives live telemetry from ESP32-C3 Wearable.
// Service UUID: 19b10000-e8f2-537e-4f6c-d104768a1214
// Telemetry Characteristic: 19b10001-e8f2-537e-4f6c-d104768a1214
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';
import '../models/telemetry_models.dart';
import '../models/wearable_status.dart';

typedef TelemetryCallback = void Function(TelemetryData telemetry);

class BluetoothService {
  BluetoothService({
    this.onTelemetryReceived,
    this.onStatusChanged,
  });

  final TelemetryCallback? onTelemetryReceived;
  final void Function(WearableConnectionStatus status)? onStatusChanged;

  // ── UUID Constants ────────────────────────────────────────────
  static const String targetDeviceName = 'RecoverX_Wearable';
  static final fbp.Guid targetServiceUuid = fbp.Guid('19b10000-e8f2-537e-4f6c-d104768a1214');
  static final fbp.Guid targetCharacteristicUuid = fbp.Guid('19b10001-e8f2-537e-4f6c-d104768a1214');

  // ── Internal State ────────────────────────────────────────────
  WearableConnectionStatus _status = WearableConnectionStatus.disconnected;
  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _telemetryCharacteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _isScanningSubscription;
  StreamSubscription? _valueSubscription;
  StreamSubscription? _connectionStateSubscription;
  String? _connectedDeviceName;
  bool _isConnecting = false;

  // ── Public Getters ────────────────────────────────────────────
  WearableConnectionStatus get status => _status;
  String? get connectedDeviceName => _connectedDeviceName ?? _connectedDevice?.platformName;
  bool get isConnected => _status.isConnected;

  // ─────────────────────────────────────────────────────────────
  // Public Actions
  // ─────────────────────────────────────────────────────────────

  /// Requests Bluetooth & Location permissions (Android/iOS).
  Future<bool> requestPermissions() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    if (Platform.isAndroid) {
      // Request Bluetooth & Location permissions
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      debugPrint('[BLE] Permission statuses: $statuses');

      // Android 12+ requires bluetoothScan & bluetoothConnect.
      // Android 11 & lower requires locationWhenInUse.
      final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      final locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;

      if ((scanGranted && connectGranted) || locationGranted) {
        return true;
      }

      // Fallback: check already-granted statuses
      final isScan = await Permission.bluetoothScan.isGranted;
      final isConnect = await Permission.bluetoothConnect.isGranted;
      final isLoc = await Permission.locationWhenInUse.isGranted;
      if ((isScan && isConnect) || isLoc) {
        return true;
      }

      return false;
    }
    return true;
  }

  /// Starts BLE scanning and connects automatically when RecoverX_Wearable is found.
  Future<void> startScanAndConnect() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      _setStatus(WearableConnectionStatus.error);
      debugPrint('[BLE] Desktop platforms are not primary BLE targets. Android recommended.');
      return;
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      _setStatus(WearableConnectionStatus.error);
      debugPrint('[BLE] Bluetooth permissions denied.');
      return;
    }

    // Check adapter state
    final adapterState = await fbp.FlutterBluePlus.adapterState.first;
    if (adapterState != fbp.BluetoothAdapterState.on) {
      _setStatus(WearableConnectionStatus.error);
      debugPrint('[BLE] Bluetooth adapter is turned off: $adapterState');
      return;
    }

    await disconnect(); // Clean up existing connections
    _isConnecting = false;
    _setStatus(WearableConnectionStatus.scanning);
    debugPrint('[BLE] BLE scan started');

    // Monitor scanning state to prevent getting stuck in scanning indefinitely
    _isScanningSubscription = fbp.FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning && _status == WearableConnectionStatus.scanning && !_isConnecting) {
        debugPrint('[BLE] BLE scan timed out without discovering $targetDeviceName');
        _setStatus(WearableConnectionStatus.disconnected);
      }
    });

    try {
      // Listen to scan results BEFORE calling startScan
      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen(
        (results) async {
          for (fbp.ScanResult r in results) {
            final platformName = r.device.platformName.trim();
            final advName = r.advertisementData.advName.trim();
            final serviceUuids = r.advertisementData.serviceUuids;

            final matchesName = platformName == targetDeviceName ||
                advName == targetDeviceName ||
                platformName.toLowerCase() == targetDeviceName.toLowerCase() ||
                advName.toLowerCase() == targetDeviceName.toLowerCase() ||
                platformName.toLowerCase().contains('recoverx') ||
                advName.toLowerCase().contains('recoverx');

            final matchesUuid = serviceUuids.contains(targetServiceUuid) ||
                serviceUuids.any((u) => u.str128.toLowerCase() == targetServiceUuid.str128.toLowerCase());

            if (matchesName || matchesUuid) {
              if (_isConnecting) return;
              _isConnecting = true;
              debugPrint('[BLE] Device found: ${r.device.remoteId} (name: "$platformName", advName: "$advName")');
              await fbp.FlutterBluePlus.stopScan();
              await _connectToDevice(r.device);
              break;
            }
          }
        },
        onError: (e) {
          debugPrint('[BLE] Scan error: $e');
          _setStatus(WearableConnectionStatus.error);
        },
      );

      // Start scan without restrictive hardware service filters so Android finds the device reliably
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('[BLE] Start scan failed: $e');
      _setStatus(WearableConnectionStatus.error);
    }
  }

  /// Connects to a discovered ESP32 device, discovers services, & subscribes to notifications.
  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    _connectedDevice = device;
    _connectedDeviceName = device.platformName.isNotEmpty ? device.platformName : targetDeviceName;
    _setStatus(WearableConnectionStatus.connecting);
    debugPrint('[BLE] Connecting');

    // Listen to connection state changes
    _connectionStateSubscription = device.connectionState.listen((state) {
      if (state == fbp.BluetoothConnectionState.disconnected) {
        debugPrint('[BLE] Device disconnected.');
        _handleDisconnect();
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 12), autoConnect: false);
      _setStatus(WearableConnectionStatus.connected);
      debugPrint('[BLE] Connected');

      // Request larger MTU on Android so JSON telemetry packets are not fragmented/truncated
      if (!kIsWeb && Platform.isAndroid) {
        try {
          await device.requestMtu(512);
          debugPrint('[BLE] MTU negotiated (512)');
        } catch (e) {
          debugPrint('[BLE] Request MTU notice: $e');
        }
      }

      // Discover Services
      _setStatus(WearableConnectionStatus.discoveringServices);
      List<fbp.BluetoothService> services = await device.discoverServices();
      debugPrint('[BLE] Services discovered');

      fbp.BluetoothService? targetService;
      for (var s in services) {
        if (s.uuid == targetServiceUuid ||
            s.uuid.str128.toLowerCase() == targetServiceUuid.str128.toLowerCase()) {
          targetService = s;
          break;
        }
      }

      if (targetService == null) {
        debugPrint('[BLE] ERROR: RecoverX service NOT found on device!');
        _setStatus(WearableConnectionStatus.error);
        return;
      }
      debugPrint('[BLE] RecoverX service found');

      // Discover Telemetry Characteristic
      _setStatus(WearableConnectionStatus.subscribing);
      for (fbp.BluetoothCharacteristic c in targetService.characteristics) {
        if (c.uuid == targetCharacteristicUuid ||
            c.uuid.str128.toLowerCase() == targetCharacteristicUuid.str128.toLowerCase()) {
          _telemetryCharacteristic = c;
          break;
        }
      }

      if (_telemetryCharacteristic == null) {
        debugPrint('[BLE] ERROR: Telemetry characteristic NOT found!');
        _setStatus(WearableConnectionStatus.error);
        return;
      }
      debugPrint('[BLE] Telemetry characteristic found');

      // Enable Notifications
      await _telemetryCharacteristic!.setNotifyValue(true);
      debugPrint('[BLE] Notifications enabled');

      // Listen to live telemetry notifications
      _valueSubscription = _telemetryCharacteristic!.onValueReceived.listen(
        (value) {
          if (value.isNotEmpty) {
            _setStatus(WearableConnectionStatus.receiving);
            _processRawBytes(value);
          }
        },
        onError: (e) {
          debugPrint('[BLE] Notification stream error: $e');
        },
      );

      _setStatus(WearableConnectionStatus.receiving);
    } catch (e) {
      debugPrint('[BLE] Connection error: $e');
      _setStatus(WearableConnectionStatus.error);
    }
  }

  /// Decodes UTF-8 JSON payload from bytes & parses into TelemetryData.
  void _processRawBytes(List<int> bytes) {
    try {
      final jsonString = utf8.decode(bytes);
      debugPrint('[BLE] Telemetry received: $jsonString');

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final telemetry = TelemetryData.fromJson(decoded);
        debugPrint('[BLE] JSON parsed: temp=${telemetry.temperatureC}, ir=${telemetry.maxIr}, red=${telemetry.maxRed}, finger=${telemetry.fingerDetected}, therapy=${telemetry.therapyStatus}, direction=${telemetry.therapyDirection}');
        onTelemetryReceived?.call(telemetry);
        debugPrint('[BLE] UI updated');
      }
    } catch (e) {
      debugPrint('[BLE Parse Error] Failed to decode telemetry JSON: $e');
    }
  }

  /// Disconnects active BLE connection and stops streams.
  Future<void> disconnect() async {
    await _scanSubscription?.cancel();
    await _isScanningSubscription?.cancel();
    await _valueSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    _scanSubscription = null;
    _isScanningSubscription = null;
    _valueSubscription = null;
    _connectionStateSubscription = null;
    _isConnecting = false;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }
    _telemetryCharacteristic = null;
    _setStatus(WearableConnectionStatus.disconnected);
  }

  void _handleDisconnect() {
    _valueSubscription?.cancel();
    _telemetryCharacteristic = null;
    _isConnecting = false;
    _setStatus(WearableConnectionStatus.disconnected);
  }

  void _setStatus(WearableConnectionStatus newStatus) {
    _status = newStatus;
    onStatusChanged?.call(newStatus);
  }

  void dispose() {
    disconnect();
  }
}

