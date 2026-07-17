import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _timeRange = 'Today';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _mockAttendance = [
    {'name': 'John Doe', 'id': 'MEM-101', 'checkIn': '08:15 AM', 'checkOut': '09:45 AM', 'date': 'Today'},
    {'name': 'Alice Johnson', 'id': 'MEM-303', 'checkIn': '10:00 AM', 'checkOut': '11:15 AM', 'date': 'Today'},
    {'name': 'Jane Smith', 'id': 'MEM-202', 'checkIn': '07:30 AM', 'checkOut': '09:00 AM', 'date': 'Yesterday'},
    {'name': 'Mike Miller', 'id': 'MEM-404', 'checkIn': '06:00 PM', 'checkOut': '07:30 PM', 'date': 'This Week'},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final filteredLogs = _mockAttendance.where((log) {
      final matchesRange = _timeRange == 'All' || log['date'] == _timeRange;
      final matchesSearch = log['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            log['id'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesRange && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by Member Name or ID',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _timeRange,
                  items: ['Today', 'Yesterday', 'This Week', 'All']
                      .map((range) => DropdownMenuItem(value: range, child: Text(range)))
                      .toList(),
                  onChanged: (val) => setState(() => _timeRange = val!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Logs (${filteredLogs.length})', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = filteredLogs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.login)),
                      title: Text(log['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${log['id']} | Date: ${log['date']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('In: ${log['checkIn']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text('Out: ${log['checkOut'] ?? 'Active'}', style: TextStyle(color: log['checkOut'] != null ? Colors.blue : Colors.red)),
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
    );
  }
}
