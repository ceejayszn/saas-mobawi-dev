import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/kiosk_services.dart';
import '../../models/kiosk_models.dart';

class HiredPersonnelScreen extends StatefulWidget {
  const HiredPersonnelScreen({super.key});

  @override
  State<HiredPersonnelScreen> createState() => _HiredPersonnelScreenState();
}

class _HiredPersonnelScreenState extends State<HiredPersonnelScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnalysisService>().loadPersonnel();
      context.read<AnalysisService>().loadPersonnelJobs();
    });
  }

  void _showAddPersonnelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Text('Add Personnel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Job Role (e.g. Chef, Cleaner)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty && roleController.text.isNotEmpty) {
                context.read<AnalysisService>().addPersonnel(
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  roleController.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddJobDialog(BuildContext context, HiredPersonnel staff) {
    final titleController = TextEditingController();
    final amtController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Job to ${staff.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Job/Task Title (e.g. Kitchen Cleaning)'),
            ),
            TextField(
              controller: amtController,
              decoration: const InputDecoration(labelText: 'Payment Amount (KES)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (e.g. 2 weeks, 1 day)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            onPressed: () {
              if (titleController.text.isNotEmpty && amtController.text.isNotEmpty && durationController.text.isNotEmpty) {
                context.read<AnalysisService>().addPersonnelJob(
                  staff.id!,
                  titleController.text.trim(),
                  double.parse(amtController.text),
                  durationController.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _settleJob(BuildContext context, PersonnelJob job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settle Job Payment'),
        content: Text('How would you like to pay KES ${job.amount.toStringAsFixed(0)} for "${job.jobTitle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.phone_android, size: 16),
            label: const Text('M-Pesa'),
            onPressed: () {
              context.read<AnalysisService>().settlePersonnelJob(job.id!, 'mpesa');
              Navigator.pop(ctx);
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.payments, size: 16),
            label: const Text('Cash'),
            onPressed: () {
              context.read<AnalysisService>().settlePersonnelJob(job.id!, 'cash');
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Hired Personnel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add Personnel',
            onPressed: () => _showAddPersonnelDialog(context),
          ),
        ],
      ),
      body: Consumer<AnalysisService>(
        builder: (context, svc, child) {
          if (svc.personnel.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No hired personnel yet.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                    onPressed: () => _showAddPersonnelDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Personnel'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: svc.personnel.length,
            itemBuilder: (context, idx) {
              final staff = svc.personnel[idx];
              final jobs = svc.personnelJobs.where((j) => j.personnelId == staff.id).toList();

              int hash = 0;
              for (int i = 0; i < staff.name.length; i++) hash = staff.name.codeUnitAt(i) + ((hash << 5) - hash);
              final List<Color> colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink, Colors.amber, Colors.indigo];
              final color = colors[hash.abs() % colors.length];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color.withOpacity(0.12),
                                child: Text(staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'P', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staff.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${staff.role} • ${staff.phone}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (val) {
                              if (val == 'add_job') {
                                _showAddJobDialog(context, staff);
                              } else if (val == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Remove Personnel?'),
                                    content: Text('Are you sure you want to remove ${staff.name}? All associated jobs and records will be deleted.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                        onPressed: () {
                                          svc.deletePersonnel(staff.id!);
                                          Navigator.pop(c);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: 'add_job', child: ListTile(leading: Icon(Icons.work), title: Text('Assign Job/Pay'))),
                              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Remove Staff'))),
                            ],
                          ),
                        ],
                      ),
                      if (jobs.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 4),
                        const Text('Assigned Tasks & Payments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...jobs.map((job) {
                          final isSettled = job.status == 'settled';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.jobTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('KES ${job.amount.toStringAsFixed(0)} • Duration: ${job.duration}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSettled ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isSettled ? 'SETTLED' : 'UNSETTLED',
                                        style: TextStyle(
                                          color: isSettled ? Colors.green.shade800 : Colors.red.shade800,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (!isSettled) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                        tooltip: 'Settle Payment',
                                        onPressed: () => _settleJob(context, job),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
