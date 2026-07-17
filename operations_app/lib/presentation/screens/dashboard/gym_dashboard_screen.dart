import 'package:flutter/material.dart';
import '../gym/member_registration_screen.dart';
import '../gym/check_in_out_screen.dart';
import '../gym/membership_management_screen.dart';
import '../gym/payments_screen.dart';
import '../gym/attendance_screen.dart';
import '../gym/products_pos_screen.dart';
import '../gym/staff_screen.dart';
import '../gym/reports_screen.dart';

class GymDashboardScreen extends StatefulWidget {
  const GymDashboardScreen({super.key});

  @override
  State<GymDashboardScreen> createState() => _GymDashboardScreenState();
}

class _GymDashboardScreenState extends State<GymDashboardScreen> {
  int _currentPanelIndex = 0; // 0 is Dashboard Home

  void _navigateToPanel(int index) {
    setState(() {
      _currentPanelIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;


    // List of screens for the POS shell
    final List<Widget> panels = [
      _buildDashboardHome(context),
      const MemberRegistrationScreen(),
      const CheckInOutScreen(),
      const MembershipManagementScreen(),
      const PaymentsScreen(),
      const AttendanceScreen(),
      const ProductsPOSScreen(),
      const StaffScreen(),
      const ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Natty Gym POS'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings panel stub
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings loaded.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Profile panel stub
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          Container(
            width: 260,
            color: colorScheme.surfaceContainerLow,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSidebarItem(icon: Icons.dashboard, title: 'Dashboard', index: 0),
                _buildSidebarItem(icon: Icons.person_add, title: 'Register Member', index: 1),
                _buildSidebarItem(icon: Icons.qr_code_scanner, title: 'Check In/Out', index: 2),
                _buildSidebarItem(icon: Icons.card_membership, title: 'Memberships', index: 3),
                _buildSidebarItem(icon: Icons.payment, title: 'Payments', index: 4),
                _buildSidebarItem(icon: Icons.analytics, title: 'Attendance Logs', index: 5),
                _buildSidebarItem(icon: Icons.storefront, title: 'Products (POS)', index: 6),
                _buildSidebarItem(icon: Icons.badge_outlined, title: 'Staff', index: 7),
                _buildSidebarItem(icon: Icons.bar_chart, title: 'Reports', index: 8),
              ],
            ),
          ),
          // Content Pane
          Expanded(
            child: panels[_currentPanelIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String title, required int index}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _currentPanelIndex == index;

    return ListTile(
      leading: Icon(icon, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      selected: isActive,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: () => _navigateToPanel(index),
    );
  }

  Widget _buildDashboardHome(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Overview', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          // KPI Grid
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard('Members Inside', '42', Icons.people_outline, Colors.blue),
              _buildKpiCard('Today\'s Attendance', '156', Icons.calendar_today, Colors.green),
              _buildKpiCard('Check-ins Today', '162', Icons.login, Colors.orange),
              _buildKpiCard('New Registrations', '4', Icons.person_add_alt_1, Colors.purple),
              _buildKpiCard('Expiring Today', '12', Icons.warning_amber_rounded, Colors.red),
              _buildKpiCard('Today\'s Revenue', '\$1,240', Icons.attach_money, Colors.teal),
            ],
          ),
          const SizedBox(height: 32),
          
          // Quick Actions
          Text('Quick Actions', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickActionButton('Scan QR Code', Icons.qr_code_scanner, () => _navigateToPanel(2)),
              const SizedBox(width: 16),
              _buildQuickActionButton('New Member', Icons.person_add, () => _navigateToPanel(1)),
              const SizedBox(width: 16),
              _buildQuickActionButton('Process Payment', Icons.payment, () => _navigateToPanel(4)),
              const SizedBox(width: 16),
              _buildQuickActionButton('Sell Product', Icons.storefront, () => _navigateToPanel(6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
