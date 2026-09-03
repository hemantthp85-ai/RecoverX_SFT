// ============================================================
// RecoverX — Safety Status Card Widget
// Displays prominent safety status and flags from backend safety evaluation.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/telemetry_models.dart';
import '../../../widgets/common/rx_card.dart';
import '../../../widgets/common/rx_status_badge.dart';

class SafetyStatusCard extends StatelessWidget {
  const SafetyStatusCard({super.key, this.safety});

  final SafetyAnalysis? safety;

  @override
  Widget build(BuildContext context) {
    final statusText = (safety?.status ?? 'UNKNOWN').replaceAll('_', ' ');
    final isSafe = safety?.overallSafe ?? (safety?.status?.toUpperCase() == 'SAFE');
    final (bg, icon, iconColor, badgeType) = _resolveStyle(safety);

    return RxCard(
      color: bg,
      showBorder: false,
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: AppConstants.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Safety Evaluation',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              RxStatusBadge(
                label: isSafe ? 'SAFE' : 'CHECK REQUIRED',
                type: badgeType,
                dot: true,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppConstants.spaceSM),

          // Safety Flags / Details
          if (safety?.flags != null && safety!.flags.isNotEmpty) ...[
            const Text(
              'Safety Flags Detected:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            ...safety!.flags.map(
              (flag) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 5, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        flag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(
              isSafe ? 'No safety flags detected.' : 'Safety status pending evaluation.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  (Color, IconData, Color, RxBadgeType) _resolveStyle(SafetyAnalysis? safety) {
    if (safety == null) {
      return (
        AppColors.primarySurface,
        Icons.shield_outlined,
        AppColors.primary,
        RxBadgeType.info,
      );
    }
    final isSafe = safety.overallSafe ?? (safety.status?.toUpperCase() == 'SAFE');
    if (isSafe) {
      return (
        AppColors.successSurface,
        Icons.verified_user_rounded,
        AppColors.success,
        RxBadgeType.success,
      );
    } else {
      return (
        AppColors.warningSurface,
        Icons.gpp_maybe_rounded,
        AppColors.warning,
        RxBadgeType.warning,
      );
    }
  }
}
