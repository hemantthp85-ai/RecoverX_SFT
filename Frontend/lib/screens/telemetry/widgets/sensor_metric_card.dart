// ============================================================
// RecoverX — Sensor Metric Card Widget
// Displays a individual telemetry metric with icon, title, value, unit & status.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/common/rx_status_badge.dart';

class SensorMetricCard extends StatelessWidget {
  const SensorMetricCard({
    super.key,
    required this.title,
    this.valueDisplay,
    this.unit,
    this.status,
    required this.icon,
    required this.accentColor,
    this.subtitle,
  });

  final String title;
  final String? valueDisplay;
  final String? unit;
  final String? status;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final badgeType = _resolveBadgeType(status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Icon & Status Row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const Spacer(),
              if (status != null && status!.isNotEmpty)
                RxStatusBadge(
                  label: status!.replaceAll('_', ' '),
                  type: badgeType,
                  dot: true,
                ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Value & Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  valueDisplay ?? '--',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null && unit!.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  RxBadgeType _resolveBadgeType(String? status) {
    if (status == null) return RxBadgeType.neutral;
    final upper = status.toUpperCase();
    if (upper.contains('SAFE') || upper.contains('NORMAL') || upper.contains('GOOD') || upper.contains('LOW') || upper.contains('STABLE')) {
      return RxBadgeType.success;
    }
    if (upper.contains('CHECK') || upper.contains('MEDIUM') || upper.contains('ELEVATED') || upper.contains('ATTENTION') || upper.contains('WARNING')) {
      return RxBadgeType.warning;
    }
    if (upper.contains('HIGH') || upper.contains('CRITICAL') || upper.contains('DANGER')) {
      return RxBadgeType.error;
    }
    return RxBadgeType.info;
  }
}
