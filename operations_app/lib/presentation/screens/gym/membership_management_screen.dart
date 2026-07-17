import 'package:flutter/material.dart';

class MembershipManagementScreen extends StatefulWidget {
  const MembershipManagementScreen({super.key});

  @override
  State<MembershipManagementScreen> createState() => _MembershipManagementScreenState();
}

class _MembershipManagementScreenState extends State<MembershipManagementScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _selectedMember;

  // Mock Members
  final List<Map<String, dynamic>> _members = [
    {
      'id': 'MEM-101',
      'name': 'John Doe',
      'plan': 'Monthly Basic',
      'status': 'ACTIVE',
      'expiryDate': '2026-08-10',
    },
    {
      'id': 'MEM-202',
      'name': 'Jane Smith',
      'plan': 'Monthly Premium',
      'status': 'FROZEN',
      'expiryDate': '2026-09-15',
    },
  ];

  void _searchMember() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _selectedMember = _members.firstWhere(
        (m) => m['id'].toString().toLowerCase().contains(query) ||
               m['name'].toString().toLowerCase().contains(query),
        orElse: () => {},
      );
      if (_selectedMember!.isEmpty) {
        _selectedMember = null;
      }
    });
  }

  void _actionDialog(String action) {
    if (_selectedMember == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Membership'),
        content: Text('Are you sure you want to $action the membership for ${_selectedMember!['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (action == 'Freeze') {
                  _selectedMember!['status'] = 'FROZEN';
                } else if (action == 'Resume' || action == 'Renew') {
                  _selectedMember!['status'] = 'ACTIVE';
                } else if (action == 'Cancel') {
                  _selectedMember!['status'] = 'CANCELLED';
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Membership ${action}d successfully for ${_selectedMember!['name']}')),
              );
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Member to Manage', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Member ID or Name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchMember(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _searchMember,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_selectedMember != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedMember!['name'], style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Member ID: ${_selectedMember!['id']}', style: const TextStyle(fontSize: 16)),
                      Text('Current Plan: ${_selectedMember!['plan']}', style: const TextStyle(fontSize: 16)),
                      Text('Status: ${_selectedMember!['status']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Expiry Date: ${_selectedMember!['expiryDate']}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _actionDialog('Renew'),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Renew Plan'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _actionDialog('Upgrade'),
                            icon: const Icon(Icons.trending_up),
                            label: const Text('Upgrade Plan'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _actionDialog('Freeze'),
                            icon: const Icon(Icons.ac_unit),
                            label: const Text('Freeze Plan'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _actionDialog('Resume'),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Resume Plan'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _actionDialog('Cancel'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel Plan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('Search and select a member to manage their subscription.'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
