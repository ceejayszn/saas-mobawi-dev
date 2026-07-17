import 'package:flutter/material.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _foundMember;
  bool _hasSearched = false;

  // Static/Mock Database of Members
  final List<Map<String, dynamic>> _mockMembers = [
    {
      'id': 'MEM-101',
      'name': 'John Doe',
      'status': 'ACTIVE',
      'daysRemaining': 24,
      'lastVisit': 'Yesterday, 5:30 PM',
      'balance': 0.00,
      'photo': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200',
    },
    {
      'id': 'MEM-202',
      'name': 'Jane Smith',
      'status': 'FROZEN',
      'daysRemaining': 45,
      'lastVisit': '5 days ago',
      'balance': 15.00,
      'photo': 'https://images.unsplash.com/photo-1548690312-e3b507d8c110?w=200',
    },
    {
      'id': 'MEM-303',
      'name': 'Bob Johnson',
      'status': 'EXPIRED',
      'daysRemaining': 0,
      'lastVisit': '2 weeks ago',
      'balance': 50.00,
      'photo': '',
    }
  ];

  void _searchMember() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _hasSearched = true;
      _foundMember = _mockMembers.firstWhere(
        (m) => m['id'].toString().toLowerCase().contains(query) ||
               m['name'].toString().toLowerCase().contains(query),
        orElse: () => {},
      );
      if (_foundMember!.isEmpty) {
        _foundMember = null;
      }
    });
  }

  void _checkIn() {
    if (_foundMember == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked In successfully: ${_foundMember!['name']} at ${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _checkOut() {
    if (_foundMember == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked Out successfully: ${_foundMember!['name']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Check In / Out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Barcode / QR or Search Member',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter Member Number, QR Code data, Name or Phone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () {
                          // Simulate scanner trigger
                          _searchController.text = 'MEM-101';
                          _searchMember();
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchMember(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _searchMember,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_hasSearched)
              Expanded(
                child: _foundMember == null
                    ? const Center(
                        child: Text(
                          'No member found matching that search.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
                    : Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: _foundMember!['photo'].toString().isNotEmpty
                                        ? NetworkImage(_foundMember!['photo'])
                                        : null,
                                    child: _foundMember!['photo'].toString().isEmpty
                                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                        : null,
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _foundMember!['name'],
                                          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Member ID: ${_foundMember!['id']}', style: textTheme.titleMedium),
                                        const SizedBox(height: 12),
                                        _buildStatusBadge(_foundMember!['status']),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 40),
                              _buildInfoRow('Days Remaining', '${_foundMember!['daysRemaining']} Days'),
                              _buildInfoRow('Last Visit', _foundMember!['lastVisit']),
                              _buildInfoRow(
                                'Outstanding Balance',
                                '\$${_foundMember!['balance'].toStringAsFixed(2)}',
                                color: _foundMember!['balance'] > 0 ? Colors.red : Colors.green,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _foundMember!['status'] == 'EXPIRED' ? null : _checkIn,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.login),
                                      label: const Text('✔ Check In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _checkOut,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.logout),
                                      label: const Text('Check Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              )
            else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Awaiting member scan/search...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'ACTIVE') color = Colors.green;
    if (status == 'FROZEN') color = Colors.orange;
    if (status == 'EXPIRED') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
