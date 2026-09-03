// ============================================================
// RecoverX — Dashboard Header widget
// Shows greeting, user ID (from session), and wearable status.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/wearable_status.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userId,
    required this.wearableStatus,
    required this.onRefresh,
    this.onStatusTap,
  });

  final String userId;
  final WearableConnectionStatus wearableStatus;
  final VoidCallback onRefresh;
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Brand + greeting ────────────────────────────────────
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
                      Icons.monitor_heart_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSM),
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Recovery Dashboard',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // ── Wearable status chip ────────────────────────────────
        GestureDetector(
          onTap: onStatusTap,
          child: _WearableChip(status: wearableStatus),
        ),

        const SizedBox(width: AppConstants.spaceSM),

        // ── Refresh button ──────────────────────────────────────
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.textSecondary,
          iconSize: 22,
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
          ),
        ),
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
