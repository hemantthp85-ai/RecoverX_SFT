// ============================================================
// RecoverX — Recovery Progress Screen
// Displays detailed recovery progress, physiological metrics & journey score.
// Data flow: UI → ProgressProvider → ProgressService → ApiClient → GET /progress/{user_id}
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/recovery_progress.dart';
import '../../models/physiological_metric.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_empty_widget.dart';
import '../../widgets/common/rx_error_widget.dart';
import '../../widgets/common/rx_loading_widget.dart';
import '../../widgets/common/rx_status_badge.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().fetchProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.refresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spaceMD,
                        AppConstants.spaceMD,
                        AppConstants.spaceMD,
                        0,
                      ),
                      child: _ProgressHeader(onRefresh: provider.refresh),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.spaceLG),
                  ),

                  // 2. Body State Content
                  SliverToBoxAdapter(
                    child: _buildBodyContent(context, provider),
                  ),

                  // Bottom Spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.spaceXXL),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, ProgressProvider provider) {
    switch (provider.state) {
      case ProgressState.idle:
      case ProgressState.loading:
        return const SizedBox(
          height: 400,
          child: RxLoadingWidget(message: 'Loading recovery progress...'),
        );

      case ProgressState.error:
        return SizedBox(
          height: 400,
          child: RxErrorWidget(
            message: provider.errorMessage ?? 'Could not load recovery progress.',
            onRetry: provider.refresh,
            icon: Icons.cloud_off_rounded,
          ),
        );

      case ProgressState.success:
        if (!provider.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
            child: RxCard(
              padding: EdgeInsets.all(AppConstants.spaceXL),
              child: RxEmptyWidget(
                title: 'No Progress Data',
                subtitle: 'No recovery progress record found for your account.',
                icon: Icons.timeline_outlined,
              ),
            ),
          );
        }
        return _ProgressViewContent(progress: provider.progress!);
    }
  }
}

// ============================================================
// Progress Header
// ============================================================

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSM),
                  const Text(
                    'Recovery Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your recovery journey',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.textSecondary,
          iconSize: 22,
          tooltip: 'Refresh Progress',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Main View Content
// ============================================================

class _ProgressViewContent extends StatelessWidget {
  const _ProgressViewContent({required this.progress});

  final RecoveryProgress progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Recovery Score & 3. Stage & 4. Status Card
          _ScoreOverviewCard(progress: progress),

          const SizedBox(height: AppConstants.spaceLG),

          // 5. Recovery Journey Progress Bar Card
          _RecoveryJourneyCard(score: progress.recoveryScore),

          const SizedBox(height: AppConstants.spaceLG),

          // 7. Clinical Summary Card
          if (progress.summary != null && progress.summary!.isNotEmpty) ...[
            _ClinicalSummaryCard(summary: progress.summary!),
            const SizedBox(height: AppConstants.spaceLG),
          ],

          // 6. Physiological Metrics Section
          _PhysiologicalMetricsSection(progress: progress),

          // 8. Last Updated Timestamp
          if (progress.updatedAt != null && progress.updatedAt!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceLG),
            _LastUpdatedChip(timestampRaw: progress.updatedAt!),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Score Overview Card (Score + Stage + Status)
// ============================================================

class _ScoreOverviewCard extends StatelessWidget {
  const _ScoreOverviewCard({required this.progress});

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
      child: Column(
        children: [
          Row(
            children: [
              // Circular Score Indicator
              _ScoreRingWidget(score: score, fraction: fraction),

              const SizedBox(width: AppConstants.spaceLG),

              // Recovery Stage & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RECOVERY SCORE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${score.toStringAsFixed(0)} / 100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    const Text(
                      'RECOVERY STAGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _StageBadge(stage: progress.recoveryStage),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceMD),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: AppConstants.spaceSM),

          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Status',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _StatusBadge(status: progress.progressStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingWidget extends StatelessWidget {
  const _ScoreRingWidget({required this.score, required this.fraction});

  final double score;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(90, 90),
            painter: _RingPainter(fraction: fraction),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const Text(
                'SCORE',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
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
    const strokeWidth = 7.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

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

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.stage});

  final String stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        stage.replaceAll('_', ' '),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================
// Recovery Journey Card
// ============================================================

class _RecoveryJourneyCard extends StatelessWidget {
  const _RecoveryJourneyCard({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final percentage = (score.clamp(0.0, 100.0)).toStringAsFixed(0);

    return RxCard(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Recovery Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            child: LinearProgressIndicator(
              value: score.clamp(0.0, 100.0) / 100.0,
              minHeight: 10,
              backgroundColor: AppColors.primarySurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Clinical Summary Card
// ============================================================

class _ClinicalSummaryCard extends StatelessWidget {
  const _ClinicalSummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recovery Summary',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSM),
        RxAccentCard(
          accentColor: AppColors.secondary,
          padding: const EdgeInsets.all(AppConstants.spaceMD),
          child: Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Physiological Metrics Section
// ============================================================

class _PhysiologicalMetricsSection extends StatelessWidget {
  const _PhysiologicalMetricsSection({required this.progress});

  final RecoveryProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Physiological Progress',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMD),
        _MetricRowCard(
          title: 'Temperature',
          metric: progress.temperature,
          icon: Icons.thermostat_rounded,
          iconColor: const Color(0xFFE53935),
        ),
        const SizedBox(height: AppConstants.spaceSM),
        _MetricRowCard(
          title: 'Swelling',
          metric: progress.swelling,
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF0A84B4),
        ),
        const SizedBox(height: AppConstants.spaceSM),
        _MetricRowCard(
          title: 'Joint Mobility',
          metric: progress.jointMobility,
          icon: Icons.rotate_90_degrees_ccw_rounded,
          iconColor: const Color(0xFF7B61FF),
        ),
        const SizedBox(height: AppConstants.spaceSM),
        _MetricRowCard(
          title: 'Blood Flow',
          metric: progress.bloodFlow,
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFF06292),
        ),
      ],
    );
  }
}

class _MetricRowCard extends StatelessWidget {
  const _MetricRowCard({
    required this.title,
    required this.metric,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final PhysiologicalMetric metric;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppConstants.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          metric.value != null ? metric.value!.toStringAsFixed(1) : '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (metric.unit != null) ...[
                          const SizedBox(width: 3),
                          Text(
                            metric.unit!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (metric.status != null)
                RxStatusBadge(
                  label: metric.status!.replaceAll('_', ' '),
                  type: badgeType,
                  dot: true,
                ),
            ],
          ),
          if (metric.interpretation != null && metric.interpretation!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceSM),
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceSM),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      metric.interpretation!,
                      style: const TextStyle(
                        fontSize: 11,
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

  RxBadgeType _badgeTypeFor(String? status) {
    if (status == null) return RxBadgeType.neutral;
    final upper = status.toUpperCase();
    if (upper.contains('NORMAL') || upper.contains('OPTIMAL') || upper.contains('GOOD')) {
      return RxBadgeType.success;
    }
    if (upper.contains('MILD') || upper.contains('LIMITED') || upper.contains('CAUTION')) {
      return RxBadgeType.warning;
    }
    if (upper.contains('HIGH') || upper.contains('CRITICAL') || upper.contains('SEVERE')) {
      return RxBadgeType.error;
    }
    return RxBadgeType.info;
  }
}

// ============================================================
// Last Updated Chip
// ============================================================

class _LastUpdatedChip extends StatelessWidget {
  const _LastUpdatedChip({required this.timestampRaw});

  final String timestampRaw;

  @override
  Widget build(BuildContext context) {
    final formatted = _formatTimestamp(timestampRaw);
    return Center(
      child: Text(
        'Last Updated: $formatted',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
