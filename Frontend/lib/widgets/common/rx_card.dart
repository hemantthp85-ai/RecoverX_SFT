// ============================================================
// RecoverX — Rx Card
// Branded card container used throughout the app.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class RxCard extends StatelessWidget {
  const RxCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
    this.elevation = 0,
    this.showBorder = true,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double elevation;
  final bool showBorder;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppConstants.radiusLG);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primarySurface,
        highlightColor: AppColors.primarySurface.withValues(alpha: 0.5),
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? AppColors.surface) : null,
            gradient: gradient,
            borderRadius: radius,
            border: showBorder
                ? Border.all(color: AppColors.border, width: 1)
                : null,
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: elevation * 4,
                      offset: Offset(0, elevation),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: padding ??
                const EdgeInsets.all(AppConstants.spaceMD),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Card with a left-side coloured accent border.
class RxAccentCard extends StatelessWidget {
  const RxAccentCard({
    super.key,
    required this.child,
    this.accentColor = AppColors.primary,
    this.padding,
  });

  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusLG),
                    bottomLeft: Radius.circular(AppConstants.radiusLG),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(AppConstants.spaceMD),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
