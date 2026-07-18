import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';

class SupportScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const SupportScreen({super.key, required this.onNavigate});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<Map<String, String>> _tickets = [
    {
      'id': 'TCK-001',
      'device': 'Windows POS 1',
      'location': 'Delights Juice Shop - Branch A',
      'time': '10:45 AM',
      'issue': 'Printer not connecting via USB.',
      'status': 'Open',
    },
    {
      'id': 'TCK-002',
      'device': 'Android Tablet (Samsung Tab A)',
      'location': 'Natty Gym HQ',
      'time': 'Yesterday',
      'issue': 'Sync fails when checking in more than 50 users rapidly.',
      'status': 'In Progress',
    },
    {
      'id': 'TCK-003',
      'device': 'iPad Pro',
      'location': 'Felixpinski Hotel - Front Desk',
      'time': '2 Days Ago',
      'issue': 'Booking room UI overlaps in portrait mode.',
      'status': 'Resolved',
    },
  ];

  int _selectedTicketIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;
    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    if (_tickets.isEmpty) return const Center(child: Text('No active tickets'));

    final selectedTicket = _tickets[_selectedTicketIndex];

    return Row(
      children: [
        // Inbox List
        Container(
          width: 350,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: borderSideColor)),
            color: theme.scaffoldBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Support Tickets', style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: _tickets.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    final isSelected = index == _selectedTicketIndex;
                    return InkWell(
                      onTap: () => setState(() => _selectedTicketIndex = index),
                      child: Container(
                        color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ticket['id']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(ticket['time']!, style: TextStyle(color: textSecondary, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(ticket['issue']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textPrimary, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(ticket['location']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Ticket Details
        Expanded(
          child: Container(
            color: theme.cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderSideColor))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ticket ${selectedTicket['id']}', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                              const SizedBox(width: 4),
                              Text(selectedTicket['location']!, style: TextStyle(color: textSecondary, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: NexusTheme.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NexusTheme.warning.withValues(alpha: 0.3)),
                        ),
                        child: Text(selectedTicket['status']!, style: const TextStyle(color: NexusTheme.warning, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Diagnostic Information', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderSideColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDiagRow('Device ID / Model', selectedTicket['device']!),
                              const SizedBox(height: 12),
                              _buildDiagRow('Timestamp', selectedTicket['time']!),
                              const SizedBox(height: 12),
                              _buildDiagRow('App Version', 'v1.0.0 (Build 42)'),
                              const SizedBox(height: 12),
                              _buildDiagRow('Network Status', 'Online (Latency: 42ms)'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text('Issue Description', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(selectedTicket['issue']!, style: TextStyle(color: textPrimary, fontSize: 16, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: borderSideColor))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type reply to client device...',
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Send to Device', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(color: NexusTheme.textMuted, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    );
  }
}
