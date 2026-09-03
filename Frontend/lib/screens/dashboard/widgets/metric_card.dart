// ============================================================
// RecoverX — Metric Card widget
// Displays a single PhysiologicalMetric (temp/swelling/etc).
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/physiological_metric.dart';
import '../../../widgets/common/rx_status_badge.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.metric,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final PhysiologicalMetric metric;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final badgeType = _badgeTypeFor(metric.status);

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
        children: [
          // ── Icon row ────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 18),
              ),
              const Spacer(),
              if (metric.status != null)
                RxStatusBadge(
                  label: metric.status!.replaceAll('_', ' '),
                  type: badgeType,
                  dot: true,
                ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceMD),

          // ── Value ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metric.value != null
                    ? metric.value!.toStringAsFixed(1)
                    : '--',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              if (metric.unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    metric.unit!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppConstants.spaceXS),

          // ── Label ───────────────────────────────────────────────
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          // ── Interpretation ──────────────────────────────────────
          if (metric.interpretation != null &&
              metric.interpretation!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceXS),
            Text(
              metric.interpretation!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  RxBadgeType _badgeTypeFor(String? status) {
    if (status == null) return RxBadgeType.neutral;
    final upper = status.toUpperCase();
    if (upper.contains('NORMAL') || upper.contains('GOOD') || upper.contains('SAFE')) {
      return RxBadgeType.success;
    }
    if (upper.contains('ELEVATED') || upper.contains('CAUTION') || upper.contains('MILD')) {
      return RxBadgeType.warning;
    }
    if (upper.contains('HIGH') || upper.contains('CRITICAL') || upper.contains('DANGER')) {
      return RxBadgeType.error;
    }
    return RxBadgeType.info;
  }
}
