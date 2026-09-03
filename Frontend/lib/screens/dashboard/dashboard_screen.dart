// ============================================================
// RecoverX — Recovery Dashboard Screen
// HOME tab — shows recovery score, metrics, summary, and actions.
// Data flows: UI → DashboardProvider → ProgressService → ApiClient → Backend
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../models/recovery_progress.dart';
import '../../models/wearable_status.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/telemetry_provider.dart';
import '../../widgets/common/rx_error_widget.dart';
import '../../widgets/common/rx_loading_widget.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_status_badge.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/recovery_score_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/quick_actions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onTabSwitch,
  });

  /// Called when a Quick Action button taps a tab.
  final void Function(int index) onTabSwitch;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after the first frame so the provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wearableStatus = context.watch<TelemetryProvider>().wearableStatus;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.retry,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Header ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spaceMD,
                        AppConstants.spaceMD,
                        AppConstants.spaceMD,
                        0,
                      ),
                      child: DashboardHeader(
                        userId: provider.currentUserId,
                        wearableStatus: wearableStatus,
                        onRefresh: provider.retry,
                        onStatusTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.telemetry);
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.spaceLG),
                  ),

                  // ── Body: loading / error / content ──────────────
                  SliverToBoxAdapter(
                    child: _buildBody(context, provider),
                  ),

                  // Bottom padding for nav bar
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

  Widget _buildBody(BuildContext context, DashboardProvider provider) {
    switch (provider.state) {
      case DashboardState.idle:
      case DashboardState.loading:
        return const SizedBox(
          height: 400,
          child: RxLoadingWidget(message: 'Loading recovery data…'),
        );

      case DashboardState.error:
        return SizedBox(
          height: 400,
          child: RxErrorWidget(
            message: provider.errorMessage ??
                'Could not load recovery data.',
            onRetry: provider.retry,
            icon: Icons.cloud_off_rounded,
          ),
        );

      case DashboardState.success:
        final progress = provider.progress!;
        return _DashboardContent(
          progress: progress,
          onTabSwitch: widget.onTabSwitch,
        );
    }
  }
}

// ============================================================
// Dashboard Content (success state)
// ============================================================

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.progress,
    required this.onTabSwitch,
  });

  final RecoveryProgress progress;
  final void Function(int) onTabSwitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0 ── RECOVERX LIVE WEARABLE MONITORING CARD ───────────
          const _RecoverXLiveWearableCard(),

          const SizedBox(height: AppConstants.spaceLG),

          // 1 ── Recovery Score Card ─────────────────────────────
          RecoveryScoreCard(progress: progress),

          const SizedBox(height: AppConstants.spaceLG),

          // 2 ── Progress Status / Safety Section ───────────────
          _SafetyStatusSection(
            progressStatus: progress.progressStatus,
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // 3 ── Recovery Summary ────────────────────────────────
          if (progress.summary != null && progress.summary!.isNotEmpty)
            _SummarySection(summary: progress.summary!),

          if (progress.summary != null && progress.summary!.isNotEmpty)
            const SizedBox(height: AppConstants.spaceLG),

          // 4 ── Physiological Metrics ───────────────────────────
          _MetricsSection(progress: progress),

          const SizedBox(height: AppConstants.spaceLG),

          // 5 ── Quick Actions ───────────────────────────────────
          QuickActions(onTabSwitch: onTabSwitch),
        ],
      ),
    );
  }
}

// ============================================================
// Safety Status Section
// ============================================================

class _SafetyStatusSection extends StatelessWidget {
  const _SafetyStatusSection({required this.progressStatus});

  final String progressStatus;

  @override
  Widget build(BuildContext context) {
    final (bg, icon, badgeType) = _resolveStyle(progressStatus);
    return RxCard(
      color: bg,
      showBorder: false,
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Row(
        children: [
          Icon(icon, color: _resolveIconColor(badgeType), size: 22),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress Status',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progressStatus.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _resolveIconColor(badgeType),
                  ),
                ),
              ],
            ),
          ),
          RxStatusBadge(
            label: _shortLabel(progressStatus),
            type: badgeType,
          ),
        ],
      ),
    );
  }

  (Color, IconData, RxBadgeType) _resolveStyle(String status) {
    final upper = status.toUpperCase();
    if (upper.contains('TRACK') || upper.contains('GOOD') || upper.contains('STABLE')) {
      return (AppColors.successSurface, Icons.check_circle_outline_rounded, RxBadgeType.success);
    }
    if (upper.contains('CAUTION') || upper.contains('SLOW') || upper.contains('ATTENTION')) {
      return (AppColors.warningSurface, Icons.warning_amber_rounded, RxBadgeType.warning);
    }
    if (upper.contains('HOLD') || upper.contains('STOP') || upper.contains('DANGER')) {
      return (AppColors.errorSurface, Icons.error_outline_rounded, RxBadgeType.error);
    }
    return (AppColors.primarySurface, Icons.info_outline_rounded, RxBadgeType.info);
  }

  Color _resolveIconColor(RxBadgeType type) => switch (type) {
        RxBadgeType.success => AppColors.success,
        RxBadgeType.warning => AppColors.warning,
        RxBadgeType.error => AppColors.error,
        _ => AppColors.primary,
      };

  String _shortLabel(String raw) {
    final upper = raw.toUpperCase();
    if (upper.contains('TRACK')) return 'On Track';
    if (upper.contains('CAUTION')) return 'Caution';
    if (upper.contains('HOLD')) return 'Hold';
    return raw.replaceAll('_', ' ');
  }
}

// ============================================================
// Summary Section
// ============================================================

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Clinical Summary'),
        const SizedBox(height: AppConstants.spaceSM),
        RxAccentCard(
          accentColor: AppColors.secondary,
          padding: const EdgeInsets.all(AppConstants.spaceMD),
          child: Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Metrics Section
// ============================================================

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.progress});

  final RecoveryProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Physiological Metrics'),
        const SizedBox(height: AppConstants.spaceMD),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.spaceSM,
          mainAxisSpacing: AppConstants.spaceSM,
          childAspectRatio: 0.95,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MetricCard(
              label: 'Temperature',
              metric: progress.temperature,
              icon: Icons.thermostat_rounded,
              iconColor: const Color(0xFFE53935),
            ),
            MetricCard(
              label: 'Swelling',
              metric: progress.swelling,
              icon: Icons.water_drop_rounded,
              iconColor: const Color(0xFF0A84B4),
            ),
            MetricCard(
              label: 'Joint Mobility',
              metric: progress.jointMobility,
              icon: Icons.rotate_90_degrees_ccw_rounded,
              iconColor: const Color(0xFF7B61FF),
            ),
            MetricCard(
              label: 'Blood Flow',
              metric: progress.bloodFlow,
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFF06292),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shared section title ──────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ============================================================
// Live RecoverX Wearable Telemetry Card
// ============================================================

class _RecoverXLiveWearableCard extends StatelessWidget {
  const _RecoverXLiveWearableCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<TelemetryProvider>(
      builder: (context, provider, _) {
        final raw = provider.latestTelemetry ?? provider.response?.rawTelemetry;
        final status = provider.wearableStatus;
        final tempC = raw?.temperatureC != null ? '${raw!.temperatureC!.toStringAsFixed(1)} °C' : '-- °C';
        final maxIr = raw?.maxIr != null ? raw!.maxIr.toString() : '--';
        final maxRed = raw?.maxRed != null ? raw!.maxRed.toString() : '--';
        final finger = raw?.fingerDetected == true
            ? 'DETECTED'
            : (raw?.fingerDetected == false ? 'NOT DETECTED' : '--');
        final therapy = raw?.therapyStatus ?? 'OFF';
        final direction = raw?.therapyDirection ?? 'NORMAL';
        final deviceName = raw?.deviceId.isNotEmpty == true ? raw!.deviceId : 'RecoverX_Wearable';

        return RxCard(
          padding: const EdgeInsets.all(AppConstants.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: AppConstants.spaceSM),
                      const Text(
                        'RECOVERX',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.telemetry);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.isConnected ? AppColors.successSurface : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                            size: 12,
                            color: status.isConnected ? AppColors.success : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status.isConnected ? 'CONNECTED' : 'DISCONNECTED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: status.isConnected ? AppColors.success : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMD),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceSM),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Column(
                  children: [
                    _dataRow('BLE', status.isConnected ? 'CONNECTED ($deviceName)' : 'DISCONNECTED'),
                    const Divider(height: 12, color: AppColors.border),
                    _dataRow('Temperature', tempC),
                    const Divider(height: 12, color: AppColors.border),
                    _dataRow('MAX IR', maxIr),
                    const Divider(height: 12, color: AppColors.border),
                    _dataRow('MAX RED', maxRed),
                    const Divider(height: 12, color: AppColors.border),
                    _dataRow('Finger', finger,
                        valueColor: raw?.fingerDetected == true ? AppColors.success : null),
                    const Divider(height: 12, color: AppColors.border),
                    _dataRow('Therapy', therapy,
                        valueColor: therapy == 'ON' ? AppColors.success : null),
                    const Divider(height: 12, color: AppColors.border),
                    _dataRow('Direction', direction,
                        valueColor: direction == 'HEAT'
                            ? const Color(0xFFE53935)
                            : (direction == 'COOL' ? const Color(0xFF00ACC1) : null)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dataRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
