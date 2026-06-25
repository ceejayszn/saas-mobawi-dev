import 'package:flutter/material.dart';
import '../../widgets/custom_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0; // 0: Today, 1: This Week, 2: This Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: const [
            Icon(Icons.bolt, color: Colors.orange),
            SizedBox(width: 8),
            Text('Boss Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$value selected')));
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Godmode',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings, color: Colors.red),
                    title: Text('Godmode'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Pick Date',
                  child: ListTile(
                    leading: Icon(Icons.calendar_month, color: Colors.teal),
                    title: Text('Pick Date (Calendar)'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Share',
                  child: ListTile(
                    leading: Icon(Icons.share, color: Colors.black54),
                    title: Text('Share Text Report'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Export CSV',
                  child: ListTile(
                    leading: Icon(Icons.table_chart, color: Colors.green),
                    title: Text('Export CSV (Excel)'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Backup',
                  child: ListTile(
                    leading: Icon(Icons.download, color: Colors.blue),
                    title: Text('Backup Database (Encrypted)'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Restore',
                  child: ListTile(
                    leading: Icon(Icons.upload_file, color: Colors.orange),
                    title: Text('Restore Database (from Euton Data)'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tabs
            Row(
              children: [
                _buildTab('Today', 0, Icons.calendar_today),
                _buildTab('This Week', 1, Icons.date_range),
                _buildTab('This Month', 2, Icons.calendar_view_month),
              ],
            ),
            const SizedBox(height: 24),
            // Big Green Card
            Container(
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
                      Text('NET PROFIT / LOSS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'KES 0',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Gross Revenue', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text('KES 0', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Total Costs', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text('KES 0', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
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

  Widget _buildTab(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor) {
    return AppCard(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
