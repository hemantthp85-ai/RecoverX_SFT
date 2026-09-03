// ============================================================
// RecoverX — App Routes
// All named route constants and route generator.
// ============================================================

import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/telemetry/telemetry_screen.dart';
import '../../screens/progress/progress_screen.dart';
import '../../screens/therapy/therapy_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/auth/login_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String shell = '/shell';
  static const String telemetry = '/telemetry';
  static const String progress = '/progress';
  static const String therapy = '/therapy';
  static const String reports = '/reports';
  static const String login = '/login';

  // ── Reserved (not yet built) ─────────────────────────────────
  // static const String login = '/login';
  // static const String register = '/register';
  // static const String dashboard = '/dashboard';
  // static const String profile = '/profile';

  // ── Route Generator ───────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());
      case shell:
        return _fade(const AppShell());
      case telemetry:
        return _fade(const TelemetryScreen());
      case progress:
        return _fade(const ProgressScreen());
      case therapy:
        return _fade(const TherapyScreen());
      case reports:
        return _fade(const ReportsScreen());
      case login:
        return _fade(const LoginScreen());
      default:
        return _fade(_notFound(settings.name));
    }
  }

  // ── Transition Helpers ────────────────────────────────────────
  static PageRoute<T> _fade<T>(Widget page) =>
      PageRouteBuilder<T>(
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  static Widget _notFound(String? name) => Scaffold(
        body: Center(
          child: Text('No route defined for: $name'),
        ),
      );
}
