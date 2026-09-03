// ============================================================
// RecoverX — Recovery Score Card widget
// Displays the primary score, stage, and status prominently.
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/recovery_progress.dart';

class RecoveryScoreCard extends StatelessWidget {
  const RecoveryScoreCard({super.key, required this.progress});

  final RecoveryProgress progress;

  @override
  Widget build(BuildContext context) {
    final score = progress.recoveryScore.clamp(0.0, 100.0);
    final fraction = score / 100.0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A84B4), Color(0xFF006A96)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Row(
        children: [
          // ── Score ring ──────────────────────────────────────────
          _ScoreRing(fraction: fraction, score: score),

          const SizedBox(width: AppConstants.spaceLG),

          // ── Labels ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recovery Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                _StageBadge(stage: progress.recoveryStage),
                const SizedBox(height: AppConstants.spaceMD),
                _ProgressStatusRow(status: progress.progressStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score Ring ────────────────────────────────────────────────
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.fraction, required this.score});

  final double fraction;
  final double score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring painter
          CustomPaint(
            size: const Size(96, 96),
            painter: _RingPainter(fraction: fraction),
          ),
          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullSweep * fraction,
        false,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

// ── Stage Badge ───────────────────────────────────────────────
class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.stage});

  final String stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        _formatLabel(stage),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatLabel(String raw) =>
      raw.replaceAll('_', ' ');
}

// ── Progress Status Row ───────────────────────────────────────
class _ProgressStatusRow extends StatelessWidget {
  const _ProgressStatusRow({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconFor(status);
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _formatLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  (IconData, Color) _iconFor(String status) {
    final upper = status.toUpperCase();
    if (upper.contains('TRACK') || upper.contains('GOOD') || upper.contains('STABLE')) {
      return (Icons.check_circle_rounded, Colors.greenAccent.shade200);
    }
    if (upper.contains('CAUTION') || upper.contains('SLOW') || upper.contains('ATTENTION')) {
      return (Icons.warning_amber_rounded, Colors.amberAccent);
    }
    if (upper.contains('HOLD') || upper.contains('STOP')) {
      return (Icons.pause_circle_rounded, Colors.redAccent.shade100);
    }
    return (Icons.trending_flat_rounded, Colors.white70);
  }

  String _formatLabel(String raw) => raw.replaceAll('_', ' ');
}
