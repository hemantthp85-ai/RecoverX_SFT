// ============================================================
// RecoverX — Quick Actions widget
// Navigation buttons to other screens (not yet built).
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.onTabSwitch});

  /// Callback to switch the shell's selected tab.
  final void Function(int tabIndex) onTabSwitch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMD),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.trending_up_rounded,
                label: 'Progress',
                color: AppColors.primary,
                onTap: () => onTabSwitch(1), // Recovery tab
              ),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: _ActionButton(
                icon: Icons.self_improvement_rounded,
                label: 'Therapy',
                color: AppColors.secondary,
                onTap: () => onTabSwitch(2), // Therapy tab
              ),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: _ActionButton(
                icon: Icons.sensors_rounded,
                label: 'Live Data',
                color: const Color(0xFF7B61FF),
                onTap: () => Navigator.pushNamed(context, '/telemetry'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceSM,
          vertical: AppConstants.spaceMD,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppConstants.spaceXS),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
