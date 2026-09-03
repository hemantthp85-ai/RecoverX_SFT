// ============================================================
// RecoverX — Recovery Therapy Screen
// Displays therapy recommendations and handles starting recovery sessions.
// Endpoints: POST /recovery/recommendation & POST /recovery/session/start
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/therapy_models.dart';
import '../../providers/therapy_provider.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_empty_widget.dart';
import '../../widgets/common/rx_error_widget.dart';
import '../../widgets/common/rx_gradient_button.dart';
import '../../widgets/common/rx_loading_widget.dart';
import '../../widgets/common/rx_status_badge.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TherapyProvider>().fetchRecommendation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TherapyProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.fetchRecommendation,
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
                      child: _TherapyHeader(
                        onRefresh: provider.fetchRecommendation,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.spaceLG),
                  ),

                  // 2. Body Content
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

  Widget _buildBodyContent(BuildContext context, TherapyProvider provider) {
    if (provider.isLoadingRecommendation) {
      return const SizedBox(
        height: 400,
        child: RxLoadingWidget(
          message: 'Requesting therapy recommendation...',
        ),
      );
    }

    if (provider.state == TherapyState.recommendationError && !provider.hasRecommendation) {
      return SizedBox(
        height: 400,
        child: RxErrorWidget(
          message: provider.errorMessage ?? 'Failed to request therapy recommendation.',
          onRetry: provider.fetchRecommendation,
          icon: Icons.healing_outlined,
        ),
      );
    }

    if (!provider.hasRecommendation) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
        child: RxCard(
          padding: const EdgeInsets.all(AppConstants.spaceXL),
          child: Column(
            children: [
              const RxEmptyWidget(
                title: 'No Therapy Recommendation',
                subtitle:
                    'Request a personalized therapy recommendation based on your current recovery status.',
                icon: Icons.self_improvement_rounded,
              ),
              const SizedBox(height: AppConstants.spaceLG),
              RxGradientButton(
                label: 'Get Recommendation',
                icon: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
                onPressed: provider.fetchRecommendation,
              ),
            ],
          ),
        ),
      );
    }

    return _TherapyViewContent(
      recommendation: provider.recommendation!,
      sessionData: provider.sessionData,
      isStartingSession: provider.isStartingSession,
      onStartSession: provider.startSession,
      errorMessage: provider.state == TherapyState.sessionError ? provider.errorMessage : null,
    );
  }
}

// ============================================================
// Header Widget
// ============================================================

class _TherapyHeader extends StatelessWidget {
  const _TherapyHeader({required this.onRefresh});

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
                      Icons.self_improvement_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSM),
                  const Text(
                    'Recovery Therapy',
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
                'Personalized recovery guidance',
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
          tooltip: 'Refresh Recommendation',
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

class _TherapyViewContent extends StatelessWidget {
  const _TherapyViewContent({
    required this.recommendation,
    this.sessionData,
    required this.isStartingSession,
    required this.onStartSession,
    this.errorMessage,
  });

  final TherapyRecommendation recommendation;
  final TherapySession? sessionData;
  final bool isStartingSession;
  final VoidCallback onStartSession;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Recommendation Hero Card
          _RecommendationCard(recommendation: recommendation),

          const SizedBox(height: AppConstants.spaceLG),

          // 2. Clinical Rationale & Expected Benefits
          _RationaleAndBenefitsCard(recommendation: recommendation),

          const SizedBox(height: AppConstants.spaceLG),

          // Session Error Banner if any
          if (errorMessage != null) ...[
            RxErrorWidget(
              message: errorMessage!,
              compact: true,
              onRetry: onStartSession,
            ),
            const SizedBox(height: AppConstants.spaceMD),
          ],

          // 3. Start Session CTA / Active Session Display
          if (sessionData == null) ...[
            RxGradientButton(
              label: isStartingSession ? 'Starting Session...' : 'START SESSION',
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              isLoading: isStartingSession,
              onPressed: isStartingSession ? null : onStartSession,
            ),
          ] else ...[
            _SessionStatusCard(session: sessionData!),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Recommendation Hero Card
// ============================================================

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final TherapyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECOMMENDED THERAPY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              RxStatusBadge(
                label: recommendation.status.replaceAll('_', ' '),
                type: RxBadgeType.success,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForTherapy(recommendation.therapyType),
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.therapyType.replaceAll('_', ' '),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${recommendation.durationMinutes} min • ${recommendation.recommendedSchedule}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForTherapy(String type) {
    final upper = type.toUpperCase();
    if (upper.contains('VIBRATION')) return Icons.vibration_rounded;
    if (upper.contains('COLD') || upper.contains('ICE')) return Icons.ac_unit_rounded;
    if (upper.contains('HEAT') || upper.contains('WARM')) return Icons.local_fire_department_rounded;
    if (upper.contains('TENS') || upper.contains('ELECTRO')) return Icons.flash_on_rounded;
    return Icons.self_improvement_rounded;
  }
}

// ============================================================
// Clinical Rationale & Expected Benefits
// ============================================================

class _RationaleAndBenefitsCard extends StatelessWidget {
  const _RationaleAndBenefitsCard({required this.recommendation});

  final TherapyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return RxCard(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical Rationale',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            recommendation.clinicalRationale,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (recommendation.expectedBenefits.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceMD),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppConstants.spaceSM),
            const Text(
              'Expected Benefits:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            ...recommendation.expectedBenefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Session Status Card
// ============================================================

class _SessionStatusCard extends StatelessWidget {
  const _SessionStatusCard({required this.session});

  final TherapySession session;

  @override
  Widget build(BuildContext context) {
    return RxAccentCard(
      accentColor: AppColors.primary,
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: AppConstants.spaceSM),
              const Text(
                'Active Session Status',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              RxStatusBadge(
                label: session.status,
                type: RxBadgeType.info,
                dot: true,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppConstants.spaceSM),

          _SessionInfoRow(label: 'Session ID', value: session.sessionId),
          _SessionInfoRow(label: 'Recommendation ID', value: session.recommendationId),
          _SessionInfoRow(label: 'User ID', value: session.userId),
          _SessionInfoRow(label: 'Therapy Type', value: session.therapyType),
          _SessionInfoRow(label: 'Duration', value: '${session.durationMinutes} minutes'),
          _SessionInfoRow(label: 'Status', value: session.status),
          if (session.startedAt != null)
            _SessionInfoRow(label: 'Started At', value: _formatTime(session.startedAt!)),
        ],
      ),
    );
  }

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _SessionInfoRow extends StatelessWidget {
  const _SessionInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
