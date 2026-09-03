// ============================================================
// RecoverX — Profile Screen
// Complete User Profile, Athlete Parameters, Wearable Settings,
// and Application Configuration.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../models/wearable_status.dart';
import '../../providers/progress_provider.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/user_session.dart';
import '../../services/bluetooth_service.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_gradient_button.dart';
import '../../widgets/common/rx_status_badge.dart';
import 'widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final loaded = await UserProfile.loadFromPrefs();
    if (mounted) {
      setState(() {
        _profile = loaded;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile(UserProfile updated) async {
    setState(() => _profile = updated);
    await updated.saveToPrefs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditModal() {
    if (_profile == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileDialog(
        profile: _profile!,
        onSave: _saveProfile,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to log out of RecoverX?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserSession.instance.clearSession();
      await _loadProfile(); // Refresh profile values
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session cleared successfully.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final profile = _profile ?? UserProfile.defaultProfile();
    final session = context.watch<UserSession>();
    final telemetry = context.watch<TelemetryProvider>();
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Profile & Settings',
          style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _showEditModal,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section A: User Header Card ─────────────────────────
            _buildUserHeaderCard(profile, session),
            const SizedBox(height: AppConstants.spaceMD),

            // ── Section B: Personal Information Card ────────────────
            _buildPersonalInfoCard(profile, session),
            const SizedBox(height: AppConstants.spaceMD),

            // ── Section C: Athlete & Recovery Info Card ─────────────
            _buildAthleteInfoCard(profile, progress),
            const SizedBox(height: AppConstants.spaceMD),

            // ── Section D: RecoverX Wearable Section ────────────────
            _buildWearableCard(telemetry),
            const SizedBox(height: AppConstants.spaceMD),

            // ── Section E: App Settings & System Controls ───────────
            _buildAppSettingsCard(profile),
            const SizedBox(height: AppConstants.spaceLG),

            // App details footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppConstants.spaceLG),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header Card ───────────────────────────────────────────────────
  Widget _buildUserHeaderCard(UserProfile profile, UserSession session) {
    final displayName = profile.fullName.isNotEmpty ? profile.fullName : 'Alex Morgan';
    final email = session.userEmail ?? profile.email;
    final userId = session.effectiveUserId;

    return RxAccentCard(
      accentColor: AppColors.primary,
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'ID: $userId',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),
          RxGradientButton(
            label: 'Edit Profile',
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
            onPressed: _showEditModal,
          ),
        ],
      ),
    );
  }

  // ── Personal Info Card ────────────────────────────────────────────
  Widget _buildPersonalInfoCard(UserProfile profile, UserSession session) {
    return RxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Personal Information',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppConstants.spaceMD),
          _buildInfoRow(Icons.person_rounded, 'Full Name', profile.fullName),
          const Divider(color: AppColors.divider),
          _buildInfoRow(Icons.email_outlined, 'Email', session.userEmail ?? profile.email),
          const Divider(color: AppColors.divider),
          _buildInfoRow(Icons.phone_outlined, 'Phone', profile.phone),
          const Divider(color: AppColors.divider),
          Row(
            children: [
              Expanded(child: _buildInfoRow(Icons.cake_outlined, 'Age', profile.age)),
              Expanded(child: _buildInfoRow(Icons.wc_outlined, 'Gender', profile.gender)),
            ],
          ),
          const Divider(color: AppColors.divider),
          Row(
            children: [
              Expanded(child: _buildInfoRow(Icons.height_outlined, 'Height', profile.height)),
              Expanded(child: _buildInfoRow(Icons.fitness_center_outlined, 'Weight', profile.weight)),
            ],
          ),
          const Divider(color: AppColors.divider),
          _buildInfoRow(Icons.contact_phone_outlined, 'Emergency Contact', profile.emergencyContact),
        ],
      ),
    );
  }

  // ── Athlete Info Card ─────────────────────────────────────────────
  Widget _buildAthleteInfoCard(UserProfile profile, ProgressProvider progress) {
    final statusText = progress.progress?.summary ?? 'Optimal Recovery Readiness';

    return RxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Athlete & Recovery Profile',
            icon: Icons.sports_gymnastics_rounded,
          ),
          const SizedBox(height: AppConstants.spaceMD),
          _buildInfoRow(Icons.directions_run_outlined, 'Primary Sport', profile.sport),
          const Divider(color: AppColors.divider),
          _buildInfoRow(Icons.military_tech_outlined, 'Training Level', profile.trainingLevel),
          const Divider(color: AppColors.divider),
          _buildInfoRow(Icons.track_changes_outlined, 'Recovery Goal', profile.recoveryGoal),
          const Divider(color: AppColors.divider),
          _buildInfoRow(Icons.health_and_safety_outlined, 'Current Recovery Status', statusText),
        ],
      ),
    );
  }

  // ── Wearable Card ─────────────────────────────────────────────────
  Widget _buildWearableCard(TelemetryProvider telemetry) {
    final status = telemetry.wearableStatus;
    final isConnected = telemetry.isConnected;
    final deviceName = BluetoothService.targetDeviceName;

    RxBadgeType badgeType;
    switch (status) {
      case WearableConnectionStatus.connected:
      case WearableConnectionStatus.receiving:
        badgeType = RxBadgeType.success;
        break;
      case WearableConnectionStatus.scanning:
      case WearableConnectionStatus.connecting:
      case WearableConnectionStatus.discoveringServices:
      case WearableConnectionStatus.subscribing:
        badgeType = RxBadgeType.warning;
        break;
      case WearableConnectionStatus.error:
        badgeType = RxBadgeType.error;
        break;
      case WearableConnectionStatus.disconnected:
      case WearableConnectionStatus.unknown:
        badgeType = RxBadgeType.neutral;
        break;
    }

    return RxAccentCard(
      accentColor: isConnected ? AppColors.success : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(
                title: 'RecoverX Wearable',
                icon: Icons.watch_outlined,
              ),
              RxStatusBadge(
                label: status.label,
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.successSurface : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                      ),
                      child: Icon(
                        Icons.bluetooth_connected_rounded,
                        color: isConnected ? AppColors.success : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceName,
                            style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ESP32-C3 Smart Wearable Sensor',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSM),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppConstants.spaceSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Service UUID', style: AppTextStyles.caption),
                    Text(
                      '19B10000-E8F2-537E...',
                      style: AppTextStyles.caption.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isConnected ? AppColors.error : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                  ),
                  onPressed: () {
                    if (isConnected) {
                      telemetry.disconnectWearable();
                    } else {
                      telemetry.connectWearable();
                    }
                  },
                  icon: Icon(
                    isConnected ? Icons.bluetooth_disabled_rounded : Icons.bluetooth_searching_rounded,
                    color: isConnected ? AppColors.error : AppColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    isConnected ? 'Disconnect Device' : 'Scan & Connect',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isConnected ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── App Settings Card ─────────────────────────────────────────────
  Widget _buildAppSettingsCard(UserProfile profile) {
    return RxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'App Settings & Preferences',
            icon: Icons.settings_outlined,
          ),
          const SizedBox(height: AppConstants.spaceMD),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
            value: profile.notificationsEnabled,
            onChanged: (val) {
              _saveProfile(profile.copyWith(notificationsEnabled: val));
            },
            title: Text('Push Notifications', style: AppTextStyles.bodyMedium),
            subtitle: Text('Receive daily recovery and therapy alerts', style: AppTextStyles.caption),
            secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
          ),
          const Divider(color: AppColors.divider),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
            value: profile.useMetricUnits,
            onChanged: (val) {
              _saveProfile(profile.copyWith(useMetricUnits: val));
            },
            title: Text('Units Preference', style: AppTextStyles.bodyMedium),
            subtitle: Text(
              profile.useMetricUnits ? 'Metric (kg, cm)' : 'Imperial (lbs, in)',
              style: AppTextStyles.caption,
            ),
            secondary: const Icon(Icons.square_foot_outlined, color: AppColors.primary),
          ),
          const Divider(color: AppColors.divider),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
            value: profile.dataSyncEnabled,
            onChanged: (val) {
              _saveProfile(profile.copyWith(dataSyncEnabled: val));
            },
            title: Text('Telemetry Data Sync', style: AppTextStyles.bodyMedium),
            subtitle: Text('Cloud synchronization for historical reports', style: AppTextStyles.caption),
            secondary: const Icon(Icons.sync_rounded, color: AppColors.primary),
          ),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppConstants.spaceSM),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
              label: Text(
                'Sign Out Session',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppConstants.spaceSM),
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppConstants.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
