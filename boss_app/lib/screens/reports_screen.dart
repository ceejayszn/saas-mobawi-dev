import 'package:flutter/material.dart';

class BossReportsScreen extends StatefulWidget {
  const BossReportsScreen({super.key});

  @override
  State<BossReportsScreen> createState() => _BossReportsScreenState();
}

class _BossReportsScreenState extends State<BossReportsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.bolt, color: Colors.orange),
            SizedBox(width: 8),
            Text('Boss Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1B5E20)),
            itemBuilder: (context) => [
              _menuItem('Godmode', Icons.admin_panel_settings, Colors.red),
              _menuItem('Pick Date (Calendar)', Icons.calendar_month, Colors.teal),
              _menuItem('Share Text Report', Icons.share, Colors.black54),
              _menuItem('Export CSV (Excel)', Icons.table_chart, Colors.green),
              _menuItem('Backup Database (Encrypted)', Icons.download, Colors.blue),
              _menuItem('Restore Database (from Euton Data)', Icons.upload_file, Colors.orange),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  _buildTab('Today', 0, Icons.calendar_today),
                  _buildTab('This Week', 1, Icons.date_range),
                  _buildTab('This Month', 2, Icons.calendar_view_month),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Big Green Net Profit card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.trending_up, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('NET PROFIT / LOSS',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('KES 0',
                      style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNetStat('Gross Revenue', 'KES 0'),
                      _buildNetStat('Total Costs', 'KES 0'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard('KES 0', 'Gross Revenue', Icons.trending_up, Colors.teal),
                _buildStatCard('KES 0', 'Total Costs', Icons.trending_down, Colors.redAccent),
                _buildStatCard('KES 0', 'M-Pesa Income', Icons.phone_android, Colors.green),
                _buildStatCard('KES 0', 'Cash on Hand', Icons.money, Colors.blue),
                _buildStatCard('KES 0', 'Eat In Revenue', Icons.restaurant, Colors.orange),
                _buildStatCard('KES 0', 'Delivery Revenue', Icons.delivery_dining, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String title, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: title,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 18),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
