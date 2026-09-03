// ============================================================
// RecoverX — Live Telemetry Screen
// Screen displaying live sensor telemetry, safety analysis & recovery recommendations.
// Data flow: ESP32 BLE -> BluetoothService -> TelemetryProvider -> UI
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/telemetry_models.dart';
import '../../models/wearable_status.dart';
import '../../providers/telemetry_provider.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_empty_widget.dart';
import '../../widgets/common/rx_error_widget.dart';
import '../../widgets/common/rx_gradient_button.dart';
import '../../widgets/common/rx_loading_widget.dart';
import 'widgets/recovery_state_card.dart';
import 'widgets/safety_status_card.dart';
import 'widgets/sensor_metric_card.dart';
import 'widgets/telemetry_header.dart';

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  /// Transmit a standard test telemetry payload to backend.
  /// Prepares the architecture so actual BLE sensor data can feed in directly.
  void _sendSampleTelemetry(BuildContext context) {
    final samplePayload = TelemetryData(
      deviceId: 'RecoverX_Wearable',
      timestamp: DateTime.now().toUtc().toIso8601String(),
      temperatureC: 29.4,
      maxIr: 45231,
      maxRed: 38210,
      fingerDetected: true,
      therapyRequested: false,
      therapyStatus: 'OFF',
      therapyDirection: 'NORMAL',
    );

    context.read<TelemetryProvider>().sendTelemetry(samplePayload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TelemetryProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceMD,
                      AppConstants.spaceMD,
                      AppConstants.spaceMD,
                      0,
                    ),
                    child: TelemetryHeader(
                      wearableStatus: provider.wearableStatus,
                      onConnect: provider.connectWearable,
                      onDisconnect: provider.disconnectWearable,
                      onSendSample: () => _sendSampleTelemetry(context),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppConstants.spaceLG),
                ),

                // Body State Content
                SliverToBoxAdapter(
                  child: _buildBodyContent(context, provider),
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppConstants.spaceXXL),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, TelemetryProvider provider) {
    switch (provider.state) {
      case TelemetryState.sending:
        return const SizedBox(
          height: 400,
          child: RxLoadingWidget(
            message: 'Transmitting telemetry to backend...',
          ),
        );

      case TelemetryState.error:
        return SizedBox(
          height: 400,
          child: RxErrorWidget(
            message: provider.errorMessage ?? 'Failed to transmit telemetry.',
            onRetry: provider.lastSentData != null
                ? () => provider.sendTelemetry(provider.lastSentData!)
                : () => _sendSampleTelemetry(context),
            icon: Icons.sensors_off_rounded,
          ),
        );

      case TelemetryState.idle:
      case TelemetryState.unavailable:
        if (!provider.hasData) {
          final status = provider.wearableStatus;
          String title = 'No Telemetry Available';
          String subtitle =
              'No live telemetry data has been received. Connect to your RecoverX_Wearable device to receive live sensor stream.';
          IconData icon = Icons.sensors_outlined;

          if (status == WearableConnectionStatus.scanning) {
            title = 'Scanning for Wearable...';
            subtitle =
                'Searching for RecoverX_Wearable via Bluetooth LE. Make sure the ESP32-C3 is powered on and advertising.';
            icon = Icons.bluetooth_searching_rounded;
          } else if (status == WearableConnectionStatus.connecting ||
              status == WearableConnectionStatus.discoveringServices ||
              status == WearableConnectionStatus.subscribing) {
            title = 'Connecting to Wearable...';
            subtitle =
                'Negotiating BLE connection, discovering services, and subscribing to telemetry notifications...';
            icon = Icons.bluetooth_connected_rounded;
          } else if (status.isConnected) {
            title = 'Connected — Awaiting Data...';
            subtitle =
                'BLE connection established. Waiting for first sensor packet from ESP32-C3...';
            icon = Icons.hourglass_top_rounded;
          } else if (status == WearableConnectionStatus.error) {
            title = 'Bluetooth Connection Notice';
            subtitle =
                'Could not connect to RecoverX_Wearable. Ensure Bluetooth & Location (GPS) are toggled ON and retry scan.';
            icon = Icons.error_outline_rounded;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
            child: RxCard(
              padding: const EdgeInsets.all(AppConstants.spaceXL),
              child: Column(
                children: [
                  RxEmptyWidget(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                  ),
                  const SizedBox(height: AppConstants.spaceLG),
                  RxGradientButton(
                    label: status.isConnected
                        ? 'Disconnect Wearable'
                        : (status == WearableConnectionStatus.scanning
                            ? 'Scanning in Progress...'
                            : 'Scan & Connect Wearable'),
                    icon: Icon(
                      status.isConnected
                          ? Icons.bluetooth_disabled_rounded
                          : Icons.bluetooth_searching_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: status.isConnected
                        ? provider.disconnectWearable
                        : (status == WearableConnectionStatus.scanning
                            ? null
                            : provider.connectWearable),
                  ),
                ],
              ),
            ),
          );
        }
        return _TelemetryViewContent(
          response: provider.response,
          latestTelemetry: provider.latestTelemetry,
        );

      case TelemetryState.success:
        return _TelemetryViewContent(
          response: provider.response,
          latestTelemetry: provider.latestTelemetry,
        );
    }
  }
}

class _TelemetryViewContent extends StatelessWidget {
  const _TelemetryViewContent({
    this.response,
    this.latestTelemetry,
  });

  final TelemetryResponse? response;
  final TelemetryData? latestTelemetry;

  @override
  Widget build(BuildContext context) {
    final processed = response?.data;
    final safety = response?.safety;
    final recovery = response?.recovery;
    final raw = latestTelemetry ?? response?.rawTelemetry;

    // Temperature display
    final tempValue = latestTelemetry?.temperatureC != null
        ? latestTelemetry!.temperatureC!.toStringAsFixed(1)
        : (processed?.temperature?.valueC != null
            ? processed!.temperature!.valueC!.toStringAsFixed(1)
            : (raw?.temperatureC != null ? raw!.temperatureC!.toStringAsFixed(1) : null));

    // Pressure display
    final pressValue = latestTelemetry?.pressureRaw != null
        ? latestTelemetry!.pressureRaw!.toStringAsFixed(0)
        : (processed?.pressure?.pressureRaw != null
            ? processed!.pressure!.pressureRaw!.toStringAsFixed(0)
            : (raw?.pressureRaw != null ? raw!.pressureRaw!.toStringAsFixed(0) : null));

    // Force display
    final forceValue = latestTelemetry?.forceEstimateN != null
        ? latestTelemetry!.forceEstimateN!.toStringAsFixed(1)
        : (processed?.pressure?.forceEstimateN != null
            ? processed!.pressure!.forceEstimateN!.toStringAsFixed(1)
            : (raw?.forceEstimateN != null ? raw!.forceEstimateN!.toStringAsFixed(1) : null));

    // Wearable and MAX30102 values
    final irValue = raw?.maxIr?.toString() ?? '--';
    final redValue = raw?.maxRed?.toString() ?? '--';
    final fingerDetected = raw?.fingerDetected;
    final fingerStatusText = fingerDetected == null
        ? '--'
        : (fingerDetected ? 'DETECTED' : 'NOT DETECTED');
    final therapyStatusText = raw?.therapyStatus ?? 'OFF';
    final therapyDirectionText = raw?.therapyDirection ?? 'NORMAL';
    final deviceIdText = raw?.deviceId.isNotEmpty == true ? raw!.deviceId : 'RecoverX_Wearable';

    final wearableStatus = context.watch<TelemetryProvider>().wearableStatus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── RECOVERX LIVE WEARABLE MONITORING CARD ────────────
          RxCard(
            padding: const EdgeInsets.all(AppConstants.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSM),
                        const Text(
                          'RECOVERX LIVE WEARABLE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: wearableStatus.isConnected
                            ? AppColors.successSurface
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Text(
                        wearableStatus.isConnected ? 'CONNECTED' : 'DISCONNECTED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: wearableStatus.isConnected
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMD),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppConstants.spaceMD),

                // Live values list
                _buildLiveRow('BLE Device', deviceIdText, icon: Icons.bluetooth_rounded),
                const SizedBox(height: AppConstants.spaceSM),
                _buildLiveRow('Temperature', tempValue != null ? '$tempValue °C' : '-- °C',
                    icon: Icons.thermostat_rounded,
                    valueColor: tempValue != null ? AppColors.primary : null),
                const SizedBox(height: AppConstants.spaceSM),
                _buildLiveRow('MAX IR', irValue, icon: Icons.sensors_rounded),
                const SizedBox(height: AppConstants.spaceSM),
                _buildLiveRow('MAX RED', redValue, icon: Icons.bloodtype_rounded),
                const SizedBox(height: AppConstants.spaceSM),
                _buildLiveRow('Finger', fingerStatusText,
                    icon: Icons.fingerprint_rounded,
                    valueColor: fingerDetected == true
                        ? AppColors.success
                        : (fingerDetected == false ? AppColors.warning : null)),
                const SizedBox(height: AppConstants.spaceSM),
                _buildLiveRow('Therapy', therapyStatusText,
                    icon: Icons.healing_rounded,
                    valueColor: therapyStatusText == 'ON'
                        ? AppColors.success
                        : AppColors.textSecondary),
                const SizedBox(height: AppConstants.spaceSM),
                _buildLiveRow('Direction', therapyDirectionText,
                    icon: Icons.swap_vert_rounded,
                    valueColor: therapyDirectionText == 'HEAT'
                        ? const Color(0xFFE53935)
                        : (therapyDirectionText == 'COOL'
                            ? const Color(0xFF00ACC1)
                            : AppColors.textSecondary)),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // 1. Safety Evaluation Section
          if (safety != null) SafetyStatusCard(safety: safety),

          if (safety != null) const SizedBox(height: AppConstants.spaceLG),

          // 2. Recovery Analysis Section
          if (recovery != null) RecoveryStateCard(recovery: recovery),

          if (recovery != null) const SizedBox(height: AppConstants.spaceLG),

          // 3. Sensor Metrics Grid Title
          const Text(
            'Sensor Telemetry Metrics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // 4. Sensor Cards Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.spaceSM,
            mainAxisSpacing: AppConstants.spaceSM,
            childAspectRatio: 0.95,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Temperature
              SensorMetricCard(
                title: 'Temperature',
                valueDisplay: tempValue,
                unit: processed?.temperature?.unit ?? '°C',
                status: processed?.temperature?.status ?? safety?.temperature,
                icon: Icons.thermostat_rounded,
                accentColor: const Color(0xFFE53935),
              ),

              // MAX30102 IR
              SensorMetricCard(
                title: 'MAX30102 IR',
                valueDisplay: irValue,
                unit: 'raw',
                status: irValue != '--' ? 'ACTIVE' : null,
                icon: Icons.sensors_rounded,
                accentColor: const Color(0xFF7B61FF),
                subtitle: 'Infrared PPG',
              ),

              // MAX30102 RED
              SensorMetricCard(
                title: 'MAX30102 RED',
                valueDisplay: redValue,
                unit: 'raw',
                status: redValue != '--' ? 'ACTIVE' : null,
                icon: Icons.bloodtype_rounded,
                accentColor: const Color(0xFFE91E63),
                subtitle: 'Red PPG',
              ),

              // Finger Detection
              SensorMetricCard(
                title: 'Finger Detected',
                valueDisplay: fingerStatusText,
                unit: '',
                status: fingerDetected == true ? 'OK' : 'WAITING',
                icon: Icons.fingerprint_rounded,
                accentColor: fingerDetected == true ? const Color(0xFF43A047) : const Color(0xFFFB8C00),
                subtitle: 'PPG Contact',
              ),

              // Therapy Status
              SensorMetricCard(
                title: 'Therapy Status',
                valueDisplay: therapyStatusText,
                unit: '',
                status: therapyStatusText == 'ON' ? 'RUNNING' : 'STANDBY',
                icon: Icons.healing_rounded,
                accentColor: therapyStatusText == 'ON' ? const Color(0xFF00ACC1) : const Color(0xFF9E9E9E),
                subtitle: 'Peltier State',
              ),

              // Therapy Direction
              SensorMetricCard(
                title: 'Direction',
                valueDisplay: therapyDirectionText,
                unit: '',
                status: therapyDirectionText,
                icon: Icons.swap_vert_rounded,
                accentColor: therapyDirectionText == 'HEAT'
                    ? const Color(0xFFE53935)
                    : (therapyDirectionText == 'COOL'
                        ? const Color(0xFF00ACC1)
                        : const Color(0xFF43A047)),
                subtitle: 'Thermal Mode',
              ),

              // Pressure (if present)
              SensorMetricCard(
                title: 'Pressure',
                valueDisplay: pressValue,
                unit: 'raw',
                status: processed?.pressure?.status,
                icon: Icons.compress_rounded,
                accentColor: const Color(0xFF0A84B4),
              ),

              // Force Estimate (if present)
              SensorMetricCard(
                title: 'Force',
                valueDisplay: forceValue,
                unit: 'N',
                status: null,
                icon: Icons.fitness_center_rounded,
                accentColor: const Color(0xFFFB8C00),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRow(String label, String value,
      {required IconData icon, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: AppConstants.spaceSM),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

