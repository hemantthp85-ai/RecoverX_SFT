// ============================================================
// RecoverX — App Shell
// Main scaffold with bottom navigation bar.
// Tab 0 = Dashboard (real screen, built in Part 2)
// Tabs 1-4 = Placeholder (will be built in subsequent parts)
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/progress/progress_screen.dart';
import '../../screens/therapy/therapy_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Destinations
  static const _destinations = [
    _NavDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    _NavDestination(
      label: 'Recovery',
      icon: Icons.healing_outlined,
      activeIcon: Icons.healing_rounded,
    ),
    _NavDestination(
      label: 'Therapy',
      icon: Icons.self_improvement_outlined,
      activeIcon: Icons.self_improvement_rounded,
    ),
    _NavDestination(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
    ),
    _NavDestination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    // Build screens lazily — Tab 0: Dashboard, Tab 1: Progress, Tab 2: Therapy, Tab 3: Reports.
    final screens = [
      DashboardScreen(onTabSwitch: _switchTab),
      const ProgressScreen(),
      const TherapyScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _switchTab,
          backgroundColor: Colors.transparent,
          elevation: 0,
          destinations: _destinations
              .map(
                (d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
