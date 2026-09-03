// ============================================================
// RecoverX — Recovery State Card Widget
// Displays recovery state, recommendation, clinical reason & therapy permission.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/telemetry_models.dart';
import '../../../widgets/common/rx_card.dart';
import '../../../widgets/common/rx_status_badge.dart';

class RecoveryStateCard extends StatelessWidget {
  const RecoveryStateCard({super.key, this.recovery});

  final RecoveryAnalysis? recovery;

  @override
  Widget build(BuildContext context) {
    final stateText = (recovery?.recoveryState ?? 'UNKNOWN').replaceAll('_', ' ');
    final recommendation = recovery?.recommendation ?? 'No active recommendation';
    final reason = recovery?.reason;
    final isAllowed = recovery?.therapyAllowed ?? false;

    return RxAccentCard(
      accentColor: AppColors.secondary,
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.healing_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSM),
              const Text(
                'Recovery Evaluation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              RxStatusBadge(
                label: isAllowed ? 'Therapy Allowed' : 'Therapy Restricted',
                type: isAllowed ? RxBadgeType.success : RxBadgeType.warning,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Recovery State & Recommendation Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recovery State',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stateText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommendation',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceMD),
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceSM),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppConstants.spaceXS),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
