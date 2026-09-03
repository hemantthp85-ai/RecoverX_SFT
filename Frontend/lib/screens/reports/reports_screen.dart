// ============================================================
// RecoverX — Reports & Recovery History Screen
// Screen displaying latest recovery report and historical analytics timeline.
// Endpoints: GET /reports/{user_id} & GET /reports/{user_id}/history
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/report_models.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_empty_widget.dart';
import '../../widgets/common/rx_error_widget.dart';
import '../../widgets/common/rx_loading_widget.dart';
import '../../widgets/common/rx_status_badge.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ReportsProvider>(
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
                      child: _ReportsHeader(onRefresh: provider.refresh),
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

  Widget _buildBodyContent(BuildContext context, ReportsProvider provider) {
    if (provider.isLoading) {
      return const SizedBox(
        height: 400,
        child: RxLoadingWidget(message: 'Loading recovery reports & history...'),
      );
    }

    if (provider.hasError && !provider.hasLatestReport && !provider.hasHistory) {
      return SizedBox(
        height: 400,
        child: RxErrorWidget(
          message: provider.errorMessage ?? 'Failed to load recovery reports.',
          onRetry: provider.refresh,
          icon: Icons.analytics_outlined,
        ),
      );
    }

    return _ReportsViewContent(
      latestReport: provider.latestReport,
      historyItems: provider.historyItems,
    );
  }
}

// ============================================================
// Header Widget
// ============================================================

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader({required this.onRefresh});

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
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSM),
                  const Text(
                    'Recovery Reports',
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
                'Your recovery history and insights',
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
          tooltip: 'Refresh Reports',
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

class _ReportsViewContent extends StatelessWidget {
  const _ReportsViewContent({
    this.latestReport,
    required this.historyItems,
  });

  final RecoveryReport? latestReport;
  final List<RecoveryHistoryItem> historyItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Latest Report Section
          if (latestReport != null) ...[
            const Text(
              'Latest Recovery Report',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSM),
            _LatestReportCard(report: latestReport!),
            const SizedBox(height: AppConstants.spaceLG),
          ],

          // 2. Recovery History Timeline Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recovery History',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              if (historyItems.isNotEmpty)
                Text(
                  '${historyItems.length} records',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // 3. Recovery History List / Empty State
          if (historyItems.isEmpty) ...[
            const RxCard(
              padding: EdgeInsets.all(AppConstants.spaceXL),
              child: RxEmptyWidget(
                title: 'No Recovery History',
                subtitle:
                    'Historical recovery records will appear here as your recovery progresses over time.',
                icon: Icons.history_rounded,
              ),
            ),
          ] else ...[
            ListView.separated(
              itemCount: historyItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: AppConstants.spaceSM),
              itemBuilder: (context, index) {
                return _HistoryItemCard(
                  item: historyItems[index],
                  index: index,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Latest Report Card
// ============================================================

class _LatestReportCard extends StatelessWidget {
  const _LatestReportCard({required this.report});

  final RecoveryReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LATEST STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (report.progressStatus != null)
                    RxStatusBadge(
                      label: report.progressStatus!.replaceAll('_', ' '),
                      type: _resolveBadgeType(report.progressStatus),
                    ),
                ],
              ),
              if (report.recoveryScore != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      '${report.recoveryScore!.toStringAsFixed(0)} / 100',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (report.recoveryStage != null) ...[
            const SizedBox(height: AppConstants.spaceMD),
            Row(
              children: [
                const Icon(Icons.shield_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  'Stage: ${report.recoveryStage!.replaceAll('_', ' ')}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],

          if (report.summary != null && report.summary!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceMD),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppConstants.spaceSM),
            Text(
              report.summary!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          if (report.createdAt != null && report.createdAt!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceMD),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Reported: ${_formatDate(report.createdAt!)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  RxBadgeType _resolveBadgeType(String? status) {
    if (status == null) return RxBadgeType.neutral;
    final upper = status.toUpperCase();
    if (upper.contains('TRACK') || upper.contains('STABLE') || upper.contains('GOOD')) {
      return RxBadgeType.success;
    }
    if (upper.contains('CAUTION') || upper.contains('ATTENTION')) {
      return RxBadgeType.warning;
    }
    return RxBadgeType.info;
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

// ============================================================
// History Item Card
// ============================================================

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.item,
    required this.index,
  });

  final RecoveryHistoryItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final dateStr = item.createdAt != null ? _formatDate(item.createdAt!) : 'Record #${index + 1}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_note_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (item.progressStatus != null)
                RxStatusBadge(
                  label: item.progressStatus!.replaceAll('_', ' '),
                  type: RxBadgeType.info,
                ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceSM),

          Row(
            children: [
              if (item.recoveryScore != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Score',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${item.recoveryScore!.toStringAsFixed(0)} / 100',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (item.recoveryStage != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stage',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item.recoveryStage!.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          if (item.summary != null && item.summary!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceSM),
            Text(
              item.summary!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
