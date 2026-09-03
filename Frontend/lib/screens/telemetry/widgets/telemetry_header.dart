// ============================================================
// RecoverX — Telemetry Header Widget
// Header for Live Telemetry screen showing title, subtitle & wearable chip.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/wearable_status.dart';

class TelemetryHeader extends StatelessWidget {
  const TelemetryHeader({
    super.key,
    required this.wearableStatus,
    required this.onConnect,
    required this.onDisconnect,
    this.onSendSample,
  });

  final WearableConnectionStatus wearableStatus;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback? onSendSample;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sensors_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSM),
                  const Text(
                    'Live Telemetry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Wearable sensor monitoring',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Wearable Chip (Tap toggles connect/disconnect)
        GestureDetector(
          onTap: wearableStatus.isConnected ? onDisconnect : onConnect,
          child: _WearableChip(status: wearableStatus),
        ),

        const SizedBox(width: AppConstants.spaceSM),

        // BLE Action Button (Connect / Disconnect / Loading)
        if (wearableStatus.isConnected) ...[
          IconButton(
            onPressed: onDisconnect,
            icon: const Icon(Icons.bluetooth_disabled_rounded),
            color: AppColors.error,
            iconSize: 20,
            tooltip: 'Disconnect Wearable',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.errorSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
            ),
          ),
        ] else if (wearableStatus == WearableConnectionStatus.scanning ||
            wearableStatus == WearableConnectionStatus.connecting ||
            wearableStatus == WearableConnectionStatus.discoveringServices ||
            wearableStatus == WearableConnectionStatus.subscribing) ...[
          const SizedBox(
            width: 36,
            height: 36,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: onConnect,
            icon: const Icon(Icons.bluetooth_searching_rounded),
            color: AppColors.primary,
            iconSize: 20,
            tooltip: 'Scan & Connect Wearable',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primarySurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WearableChip extends StatelessWidget {
  const _WearableChip({required this.status});

  final WearableConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = switch (status) {
      WearableConnectionStatus.connected ||
      WearableConnectionStatus.receiving => (
          AppColors.success,
          AppColors.successSurface,
          Icons.bluetooth_connected_rounded,
        ),
      WearableConnectionStatus.scanning ||
      WearableConnectionStatus.connecting ||
      WearableConnectionStatus.discoveringServices ||
      WearableConnectionStatus.subscribing => (
          AppColors.warning,
          AppColors.warningSurface,
          Icons.bluetooth_searching_rounded,
        ),
      WearableConnectionStatus.disconnected ||
      WearableConnectionStatus.error => (
          AppColors.textTertiary,
          AppColors.surfaceElevated,
          Icons.bluetooth_disabled_rounded,
        ),
      WearableConnectionStatus.unknown => (
          AppColors.textTertiary,
          AppColors.surfaceElevated,
          Icons.bluetooth_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

