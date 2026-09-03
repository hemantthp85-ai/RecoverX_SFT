import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// RecoverX — App Colors
// The single source of truth for the entire colour palette.
// ============================================================

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────
  /// Primary teal-blue — main interactive colour
  static const Color primary = Color(0xFF0A84B4);

  /// Primary dark variant (pressed states, gradients)
  static const Color primaryDark = Color(0xFF006A96);

  /// Primary light variant (highlights, chips)
  static const Color primaryLight = Color(0xFF4AABCF);

  /// Primary very light (tinted surfaces)
  static const Color primarySurface = Color(0xFFE6F4FA);

  /// Secondary accent — soft cyan glow
  static const Color secondary = Color(0xFF00C6D7);

  /// Secondary surface tint
  static const Color secondarySurface = Color(0xFFE0F8FA);

  // ── Backgrounds ───────────────────────────────────────────────
  /// Page / scaffold background (near-white, cool undertone)
  static const Color background = Color(0xFFF4F7FB);

  /// Surface — cards, panels, dialogs
  static const Color surface = Color(0xFFFFFFFF);

  /// Elevated surface (slightly off-white for depth)
  static const Color surfaceElevated = Color(0xFFEEF2F7);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF90A0B4);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFB0BEC5);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF2EB872);
  static const Color successSurface = Color(0xFFE8FAF0);

  static const Color warning = Color(0xFFF4A827);
  static const Color warningSurface = Color(0xFFFFF6E0);

  static const Color error = Color(0xFFE53935);
  static const Color errorSurface = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF0A84B4);
  static const Color infoSurface = Color(0xFFE6F4FA);

  // ── Structural ────────────────────────────────────────────────
  static const Color border = Color(0xFFDDE3EE);
  static const Color divider = Color(0xFFECEFF4);
  static const Color shadow = Color(0x14000000);

  // ── Special ───────────────────────────────────────────────────
  /// Gradient — primary CTA background
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84B4), Color(0xFF00C6D7)],
  );

  /// Gradient — card accent strip
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4AABCF), Color(0xFF00C6D7)],
  );

  /// Gradient — success states
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2EB872), Color(0xFF56D39A)],
  );
}

// ============================================================
// RecoverX — App Text Styles
// Built on Google Fonts "Inter" for a clean medical UI feel.
// ============================================================

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base =>
      GoogleFonts.inter(color: AppColors.textPrimary);

  // ── Display ──────────────────────────────────────────────────
  static TextStyle get displayLarge =>
      _base.copyWith(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get displayMedium =>
      _base.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle get displaySmall =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3);

  // ── Headline ─────────────────────────────────────────────────
  static TextStyle get headlineLarge =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineMedium =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get headlineSmall =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  // ── Body ──────────────────────────────────────────────────────
  static TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  // ── Label ─────────────────────────────────────────────────────
  static TextStyle get labelLarge =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);

  static TextStyle get labelMedium =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2);

  static TextStyle get labelSmall =>
      _base.copyWith(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.3);

  // ── Caption / Meta ────────────────────────────────────────────
  static TextStyle get caption =>
      _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  // ── Numeric / Metric (monospace feel) ─────────────────────────
  static TextStyle get metricLarge =>
      GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static TextStyle get metricMedium =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static TextStyle get metricSmall =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: [const FontFeature.tabularFigures()],
      );
}
