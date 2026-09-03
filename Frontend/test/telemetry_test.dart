import 'package:flutter_test/flutter_test.dart';
import 'package:recoverx/models/telemetry_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelemetryData & Serialization Unit Tests', () {
    test('TelemetryData converts to JSON with exact field names expected by FastAPI', () {
      const data = TelemetryData(
        deviceId: 'ESP32_RecoverX_01',
        timestamp: '2026-08-29T18:00:00.000Z',
        temperatureC: 36.8,
        heartRateBpm: 75.0,
        spo2Percent: 99.0,
        pressureRaw: 512.0,
        forceEstimateN: 15.2,
        accelXG: 0.1,
        accelYG: 0.9,
        accelZG: 0.2,
        gyroXDps: 0.5,
        gyroYDps: 0.3,
        gyroZDps: 0.1,
      );

      final json = data.toJson();

      expect(json['device_id'], equals('ESP32_RecoverX_01'));
      expect(json['timestamp'], equals('2026-08-29T18:00:00.000Z'));
      expect(json['temperature_c'], equals(36.8));
      expect(json['heart_rate_bpm'], equals(75.0));
      expect(json['spo2_percent'], equals(99.0));
      expect(json['pressure_raw'], equals(512.0));
      expect(json['force_estimate_n'], equals(15.2));
      expect(json['accel_x_g'], equals(0.1));
      expect(json['accel_y_g'], equals(0.9));
      expect(json['accel_z_g'], equals(0.2));
      expect(json['gyro_x_dps'], equals(0.5));
      expect(json['gyro_y_dps'], equals(0.3));
      expect(json['gyro_z_dps'], equals(0.1));
    });

    test('TelemetryData.fromJson parses JSON payload from ESP32 correctly', () {
      final json = {
        'device_id': 'ESP32_Custom_ID',
        'timestamp': '2026-08-29T18:05:00.000Z',
        'temperature_c': 37.1,
        'heart_rate_bpm': 80.0,
        'spo2_percent': 98.5,
      };

      final data = TelemetryData.fromJson(json);

      expect(data.deviceId, equals('ESP32_Custom_ID'));
      expect(data.timestamp, equals('2026-08-29T18:05:00.000Z'));
      expect(data.temperatureC, equals(37.1));
      expect(data.heartRateBpm, equals(80.0));
      expect(data.spo2Percent, equals(98.5));
    });
  });
}
