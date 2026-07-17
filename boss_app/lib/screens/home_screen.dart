import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _adminName = 'Boss';

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 4, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_greeting()}, $_adminName',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Natty Gym Boss',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Live Gym Metrics'),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _buildStatCard('\$1,240', "Today's Revenue", Icons.trending_up, AppColors.success, AppColors.successLight),
                      _buildStatCard('156', 'Today\'s Attendance', Icons.people_outline, AppColors.info, AppColors.infoLight),
                      _buildStatCard('42', 'People Currently Inside', Icons.login, AppColors.orange, AppColors.orangeLight),
                      _buildStatCard('4', 'New Members Today', Icons.person_add, AppColors.purple, AppColors.purpleLight),
                      _buildStatCard('12', 'Expired Memberships', Icons.warning_amber, AppColors.error, AppColors.errorLight),
                      _buildStatCard('\$250', 'Pending Payments', Icons.payment, Colors.teal, Colors.teal[50]!),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('Quick Panels'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildActionCard('Analytics & Reports', Icons.bar_chart, AppColors.success, () => widget.onNavigate?.call(1))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildActionCard('System Health', Icons.monitor_heart, AppColors.info, () => widget.onNavigate?.call(3))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildActionCard('Staff Performance', Icons.badge_outlined, AppColors.purple, () => widget.onNavigate?.call(2))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildActionCard('Settings', Icons.settings, AppColors.textSecondary, () => widget.onNavigate?.call(4))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('Live Analytics (Peak Hours)'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Attendance Intensity', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHourBar('06:00', 0.8),
                              _buildHourBar('09:00', 0.4),
                              _buildHourBar('12:00', 0.2),
                              _buildHourBar('15:00', 0.5),
                              _buildHourBar('18:00', 1.0), // Peak hour
                              _buildHourBar('21:00', 0.3),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourBar(String label, double fillPercent) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 80,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 80 * fillPercent,
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 14),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
