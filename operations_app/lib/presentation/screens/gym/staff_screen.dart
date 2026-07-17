import 'package:flutter/material.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final List<Map<String, dynamic>> _staffList = [
    {'name': 'Coach Carter', 'role': 'Lead Trainer', 'status': 'On Duty', 'shifts': '08:00 AM - 04:00 PM'},
    {'name': 'Sarah Connor', 'role': 'Receptionist', 'status': 'On Duty', 'shifts': '07:00 AM - 03:00 PM'},
    {'name': 'Marcus Aurelius', 'role': 'Manager', 'status': 'Off Duty', 'shifts': 'Flexible'},
  ];

  void _toggleDutyStatus(int index) {
    setState(() {
      final currentStatus = _staffList[index]['status'];
      _staffList[index]['status'] = currentStatus == 'On Duty' ? 'Off Duty' : 'On Duty';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff & Attendance Management')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registered Staff & Shift Status', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _staffList.length,
                itemBuilder: (context, index) {
                  final staff = _staffList[index];
                  final isOnDuty = staff['status'] == 'On Duty';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOnDuty ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                        child: Icon(Icons.person, color: isOnDuty ? Colors.green : Colors.grey),
                      ),
                      title: Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Role: ${staff['role']} | Shift: ${staff['shifts']}'),
                      trailing: ElevatedButton(
                        onPressed: () => _toggleDutyStatus(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOnDuty ? Colors.green : colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isOnDuty ? 'Clock Out' : 'Clock In'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
