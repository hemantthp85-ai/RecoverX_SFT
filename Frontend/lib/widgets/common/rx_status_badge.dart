// ============================================================
// RecoverX — Status Badge
// A small branded chip for displaying statuses (Active, Warning…)
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

enum RxBadgeType { success, warning, error, info, neutral }

class RxStatusBadge extends StatelessWidget {
  const RxStatusBadge({
    super.key,
    required this.label,
    this.type = RxBadgeType.neutral,
    this.dot = true,
  });

  final String label;
  final RxBadgeType type;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg) _colors() => switch (type) {
        RxBadgeType.success => (AppColors.successSurface, AppColors.success),
        RxBadgeType.warning => (AppColors.warningSurface, AppColors.warning),
        RxBadgeType.error => (AppColors.errorSurface, AppColors.error),
        RxBadgeType.info => (AppColors.primarySurface, AppColors.primary),
        RxBadgeType.neutral =>
          (AppColors.surfaceElevated, AppColors.textSecondary),
      };
}
