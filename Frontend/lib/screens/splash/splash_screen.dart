import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/user_session.dart';
import '../../services/health_service.dart';
import '../../services/api_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String _statusText = 'Starting up…';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    // Small delay to show the splash cleanly
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _statusText = 'Connecting to backend…');

    final healthService = HealthService(ApiClient());
    final reachable = await healthService.isBackendReachable();

    if (!mounted) return;

    if (reachable) {
      setState(() => _statusText = 'Ready');
      await Future.delayed(const Duration(milliseconds: 400));
    } else {
      setState(() {
        _statusText = 'Backend unreachable — running in offline mode';
        _hasError = true;
      });
      await Future.delayed(const Duration(milliseconds: 1800));
    }

    if (!mounted) return;

    // ── Auth check: go to dashboard if already logged in ──────────
    final session = UserSession.instance;
    if (session.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Center(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo Mark ───────────────────────────────────────
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.monitor_heart_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceLG),

                      // ── Brand Name ──────────────────────────────────────
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXS),

                      Text(
                        AppConstants.appTagline,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXXL),

                      // ── Progress ────────────────────────────────────────
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _hasError
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceMD),

                      Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: _hasError
                              ? AppColors.warning
                              : AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
