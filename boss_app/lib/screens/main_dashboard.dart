import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'reports/reports_screen.dart';
import 'staff_screen.dart';
import 'monitoring_screen.dart';
import 'settings/settings_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = AppConstants.navHome;

  late final List<Widget> _screens = [
    HomeScreen(onNavigate: navigateTo),
    const BossReportsScreen(),
    const StaffScreen(),
    const MonitoringScreen(),
    const SettingsScreen(),
  ];

  void navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primaryGreen,
            unselectedItemColor: isDark ? AppColors.darkTextSecondary : Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Staff',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.monitor_heart_outlined),
                activeIcon: Icon(Icons.monitor_heart_rounded),
                label: 'Monitoring',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
