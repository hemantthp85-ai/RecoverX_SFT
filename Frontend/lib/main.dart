// ============================================================
// RecoverX — Entry Point
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';
import 'providers/user_session.dart';
import 'providers/dashboard_provider.dart';
import 'providers/telemetry_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/therapy_provider.dart';
import 'providers/reports_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise user session from SharedPreferences.
  await UserSession.instance.init();

  // Lock to portrait orientation for the wearable companion app.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const RecoverXApp());
}

class RecoverXApp extends StatelessWidget {
  const RecoverXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // UserSession is a singleton — ChangeNotifierProvider wraps it.
        ChangeNotifierProvider<UserSession>.value(value: UserSession.instance),

        // DashboardProvider — scoped to the app so data survives tab switches.
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(),
        ),

        // TelemetryProvider — manages state for live telemetry
        ChangeNotifierProvider<TelemetryProvider>(
          create: (_) => TelemetryProvider(),
        ),

        // ProgressProvider — manages state for recovery progress
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(),
        ),

        // TherapyProvider — manages state for therapy recommendations & sessions
        ChangeNotifierProvider<TherapyProvider>(
          create: (_) => TherapyProvider(),
        ),

        // ReportsProvider — manages state for recovery reports & history
        ChangeNotifierProvider<ReportsProvider>(
          create: (_) => ReportsProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
