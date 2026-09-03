// ============================================================
// RecoverX — Placeholder Screen
// Used temporarily for tabs that have not been built yet.
// This screen is ISOLATED — easily swapped for the real screen.
// It contains NO mock data.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.label,
    required this.icon,
    this.description,
  });

  final String label;
  final IconData icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(label),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon container ────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Title ─────────────────────────────────────────────────
              Text(
                label,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spaceSM),

              if (description != null)
                Text(
                  description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: AppConstants.spaceXL),

              // ── Coming soon chip ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMD,
                  vertical: AppConstants.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Coming in next part',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
