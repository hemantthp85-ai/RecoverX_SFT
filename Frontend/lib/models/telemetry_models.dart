// ============================================================
// RecoverX — Telemetry Models
// Contains request & response models for live sensor telemetry.
// Matches FastAPI POST /api/sensors/telemetry schema.
// ============================================================

/// 1. Request payload sent to backend from wearable/app.
class TelemetryData {
  const TelemetryData({
    required this.deviceId,
    required this.timestamp,
    this.temperatureC,
    this.maxIr,
    this.maxRed,
    this.fingerDetected,
    this.therapyRequested,
    this.therapyStatus,
    this.therapyDirection,
    this.heartRateBpm,
    this.spo2Percent,
    this.pressureRaw,
    this.forceEstimateN,
    this.accelXG,
    this.accelYG,
    this.accelZG,
    this.gyroXDps,
    this.gyroYDps,
    this.gyroZDps,
  });

  final String deviceId;
  final String timestamp;
  final double? temperatureC;

  // MAX30102 & Local Wearable States
  final int? maxIr;
  final int? maxRed;
  final bool? fingerDetected;
  final bool? therapyRequested;
  final String? therapyStatus;
  final String? therapyDirection;

  // Legacy / Optional Sensor Fields
  final double? heartRateBpm;
  final double? spo2Percent;
  final double? pressureRaw;
  final double? forceEstimateN;
  final double? accelXG;
  final double? accelYG;
  final double? accelZG;
  final double? gyroXDps;
  final double? gyroYDps;
  final double? gyroZDps;

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'timestamp': timestamp,
        if (temperatureC != null) 'temperature_c': temperatureC,
        if (maxIr != null) 'max_ir': maxIr,
        if (maxRed != null) 'max_red': maxRed,
        if (fingerDetected != null) 'finger_detected': fingerDetected,
        if (therapyRequested != null) 'therapy_requested': therapyRequested,
        if (therapyStatus != null) 'therapy_status': therapyStatus,
        if (therapyDirection != null) 'therapy_direction': therapyDirection,
        if (heartRateBpm != null) 'heart_rate_bpm': heartRateBpm,
        if (spo2Percent != null) 'spo2_percent': spo2Percent,
        if (pressureRaw != null) 'pressure_raw': pressureRaw,
        if (forceEstimateN != null) 'force_estimate_n': forceEstimateN,
        if (accelXG != null) 'accel_x_g': accelXG,
        if (accelYG != null) 'accel_y_g': accelYG,
        if (accelZG != null) 'accel_z_g': accelZG,
        if (gyroXDps != null) 'gyro_x_dps': gyroXDps,
        if (gyroYDps != null) 'gyro_y_dps': gyroYDps,
        if (gyroZDps != null) 'gyro_z_dps': gyroZDps,
      };

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      deviceId: (json['device_id'] as String?) ?? (json['deviceId'] as String?) ?? 'RecoverX_Wearable',
      timestamp: (json['timestamp']?.toString()) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      temperatureC: _parseDouble(json['temperature_c'] ?? json['temperature'] ?? json['temperatureC']),
      maxIr: _parseInt(json['max_ir'] ?? json['maxIr'] ?? json['ir']),
      maxRed: _parseInt(json['max_red'] ?? json['maxRed'] ?? json['red']),
      fingerDetected: _parseBool(json['finger_detected'] ?? json['fingerDetected']),
      therapyRequested: _parseBool(json['therapy_requested'] ?? json['therapyRequested']),
      therapyStatus: (json['therapy_status'] ?? json['therapyStatus'])?.toString(),
      therapyDirection: (json['therapy_direction'] ?? json['therapyDirection'])?.toString(),
      heartRateBpm: _parseDouble(json['heart_rate_bpm']),
      spo2Percent: _parseDouble(json['spo2_percent']),
      pressureRaw: _parseDouble(json['pressure_raw']),
      forceEstimateN: _parseDouble(json['force_estimate_n']),
      accelXG: _parseDouble(json['accel_x_g']),
      accelYG: _parseDouble(json['accel_y_g']),
      accelZG: _parseDouble(json['accel_z_g']),
      gyroXDps: _parseDouble(json['gyro_x_dps']),
      gyroYDps: _parseDouble(json['gyro_y_dps']),
      gyroZDps: _parseDouble(json['gyro_z_dps']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final s = value.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    if (value is num) return value != 0;
    return null;
  }
}

/// 3. Processed Temperature Data
class TemperatureData {
  const TemperatureData({
    this.valueC,
    this.status,
    this.unit = '°C',
  });

  final double? valueC;
  final String? status;
  final String? unit;

  factory TemperatureData.fromJson(Map<String, dynamic> json) {
    return TemperatureData(
      valueC: (json['value_c'] ?? json['value']) != null
          ? ((json['value_c'] ?? json['value']) as num).toDouble()
          : null,
      status: json['status'] as String?,
      unit: (json['unit'] as String?) ?? '°C',
    );
  }
}

/// 4. Processed Movement Data
class MovementData {
  const MovementData({
    this.accelMagnitudeG,
    this.movementState,
    this.status,
  });

  final double? accelMagnitudeG;
  final String? movementState;
  final String? status;

  factory MovementData.fromJson(Map<String, dynamic> json) {
    return MovementData(
      accelMagnitudeG: (json['accel_magnitude_g'] ?? json['magnitude']) != null
          ? ((json['accel_magnitude_g'] ?? json['magnitude']) as num).toDouble()
          : null,
      movementState: (json['movement_state'] ?? json['state']) as String?,
      status: json['status'] as String?,
    );
  }
}

/// 5. Processed Heart Rate Data
class HeartRateData {
  const HeartRateData({
    this.valueBpm,
    this.status,
    this.unit = 'BPM',
  });

  final double? valueBpm;
  final String? status;
  final String? unit;

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      valueBpm: (json['value_bpm'] ?? json['value']) != null
          ? ((json['value_bpm'] ?? json['value']) as num).toDouble()
          : null,
      status: json['status'] as String?,
      unit: (json['unit'] as String?) ?? 'BPM',
    );
  }
}

/// 6. Processed SpO2 Data
class SpO2Data {
  const SpO2Data({
    this.valuePercent,
    this.status,
    this.unit = '%',
  });

  final double? valuePercent;
  final String? status;
  final String? unit;

  factory SpO2Data.fromJson(Map<String, dynamic> json) {
    return SpO2Data(
      valuePercent: (json['value_percent'] ?? json['value']) != null
          ? ((json['value_percent'] ?? json['value']) as num).toDouble()
          : null,
      status: json['status'] as String?,
      unit: (json['unit'] as String?) ?? '%',
    );
  }
}

/// 7. Processed Pressure Data
class PressureData {
  const PressureData({
    this.pressureRaw,
    this.forceEstimateN,
    this.status,
  });

  final double? pressureRaw;
  final double? forceEstimateN;
  final String? status;

  factory PressureData.fromJson(Map<String, dynamic> json) {
    return PressureData(
      pressureRaw: (json['pressure_raw'] ?? json['pressure']) != null
          ? ((json['pressure_raw'] ?? json['pressure']) as num).toDouble()
          : null,
      forceEstimateN: (json['force_estimate_n'] ?? json['force']) != null
          ? ((json['force_estimate_n'] ?? json['force']) as num).toDouble()
          : null,
      status: json['status'] as String?,
    );
  }
}

/// 2. Processed Telemetry Container
class ProcessedTelemetry {
  const ProcessedTelemetry({
    this.temperature,
    this.movement,
    this.heartRate,
    this.spo2,
    this.pressure,
  });

  final TemperatureData? temperature;
  final MovementData? movement;
  final HeartRateData? heartRate;
  final SpO2Data? spo2;
  final PressureData? pressure;

  factory ProcessedTelemetry.fromJson(Map<String, dynamic> json) {
    return ProcessedTelemetry(
      temperature: json['temperature'] != null && json['temperature'] is Map<String, dynamic>
          ? TemperatureData.fromJson(json['temperature'] as Map<String, dynamic>)
          : null,
      movement: json['movement'] != null && json['movement'] is Map<String, dynamic>
          ? MovementData.fromJson(json['movement'] as Map<String, dynamic>)
          : null,
      heartRate: json['heart_rate'] != null && json['heart_rate'] is Map<String, dynamic>
          ? HeartRateData.fromJson(json['heart_rate'] as Map<String, dynamic>)
          : null,
      spo2: json['spo2'] != null && json['spo2'] is Map<String, dynamic>
          ? SpO2Data.fromJson(json['spo2'] as Map<String, dynamic>)
          : null,
      pressure: json['pressure'] != null && json['pressure'] is Map<String, dynamic>
          ? PressureData.fromJson(json['pressure'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 8. Safety Analysis Model
class SafetyAnalysis {
  const SafetyAnalysis({
    this.overallSafe,
    this.status,
    this.flags = const [],
    this.temperature,
    this.heartRate,
    this.spo2,
    this.movement,
  });

  final bool? overallSafe;
  final String? status;
  final List<String> flags;
  final String? temperature;
  final String? heartRate;
  final String? spo2;
  final String? movement;

  factory SafetyAnalysis.fromJson(Map<String, dynamic> json) {
    final rawFlags = json['flags'];
    List<String> parsedFlags = [];
    if (rawFlags is List) {
      parsedFlags = rawFlags.map((e) => e.toString()).toList();
    }

    return SafetyAnalysis(
      overallSafe: json['overall_safe'] as bool?,
      status: json['status'] as String?,
      flags: parsedFlags,
      temperature: json['temperature'] as String?,
      heartRate: json['heart_rate'] as String?,
      spo2: json['spo2'] as String?,
      movement: json['movement'] as String?,
    );
  }
}

/// 9. Recovery Analysis Model
class RecoveryAnalysis {
  const RecoveryAnalysis({
    this.recoveryState,
    this.recommendation,
    this.reason,
    this.therapyAllowed,
  });

  final String? recoveryState;
  final String? recommendation;
  final String? reason;
  final bool? therapyAllowed;

  factory RecoveryAnalysis.fromJson(Map<String, dynamic> json) {
    return RecoveryAnalysis(
      recoveryState: (json['recovery_state'] ?? json['state']) as String?,
      recommendation: json['recommendation'] as String?,
      reason: json['reason'] as String?,
      therapyAllowed: (json['therapy_allowed'] ?? json['allowed']) as bool?,
    );
  }
}

/// 10. Complete Backend Telemetry Response Model
class TelemetryResponse {
  const TelemetryResponse({
    this.status,
    this.userId,
    this.data,
    this.safety,
    this.recovery,
    this.rawTelemetry,
  });

  final String? status;
  final String? userId;
  final ProcessedTelemetry? data;
  final SafetyAnalysis? safety;
  final RecoveryAnalysis? recovery;
  final TelemetryData? rawTelemetry;

  factory TelemetryResponse.fromJson(Map<String, dynamic> json, {TelemetryData? rawInput}) {
    return TelemetryResponse(
      status: json['status'] as String?,
      userId: json['user_id'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ProcessedTelemetry.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      safety: json['safety'] != null && json['safety'] is Map<String, dynamic>
          ? SafetyAnalysis.fromJson(json['safety'] as Map<String, dynamic>)
          : null,
      recovery: json['recovery'] != null && json['recovery'] is Map<String, dynamic>
          ? RecoveryAnalysis.fromJson(json['recovery'] as Map<String, dynamic>)
          : null,
      rawTelemetry: rawInput,
    );
  }
}
