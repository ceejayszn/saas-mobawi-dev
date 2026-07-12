import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../data/models/staff_member.dart';
import '../providers/staff_provider.dart';
import 'staff/staff_detail_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadStaff();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProvider, _) {
          if (staffProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final allStaff = staffProvider.staff;
          final filtered = _searchQuery.isEmpty
              ? allStaff
              : allStaff.where((s) =>
                  s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  s.role.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search staff...',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textHint),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Summary row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSummaryCard('Total', allStaff.length.toString(), Icons.people_rounded, AppColors.info, isDark),
                    const SizedBox(width: 8),
                    _buildSummaryCard('On Duty', staffProvider.onDutyCount.toString(), Icons.check_circle_rounded, AppColors.success, isDark),
                    const SizedBox(width: 8),
                    _buildSummaryCard('Holiday', staffProvider.onHolidayCount.toString(), Icons.beach_access_rounded, AppColors.orange, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Staff list
              Expanded(
                child: allStaff.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildStaffCard(filtered[index], isDark, context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffMember staff, bool isDark, BuildContext context) {
    Color statusColor;
    switch (staff.status) {
      case StaffStatus.onDuty:
        statusColor = AppColors.success;
        break;
      case StaffStatus.onHoliday:
        statusColor = AppColors.orange;
        break;
      case StaffStatus.offDuty:
        statusColor = AppColors.error;
        break;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: staff.id)),
        );
        if (context.mounted) {
          context.read<StaffProvider>().loadStaff();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(staff, 24),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(staff.role, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded, size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${staff.totalHoursWorked.toStringAsFixed(1)}h',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.monetization_on_rounded, size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        'KES ${staff.totalWagesEarned.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                staff.statusLabel,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),

            // Actions menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) => _handleAction(v, staff),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'duty',
                  child: Row(children: [
                    Icon(
                      staff.status == StaffStatus.onDuty ? Icons.logout_rounded : Icons.login_rounded,
                      size: 18,
                      color: staff.status == StaffStatus.onDuty ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Text(staff.status == StaffStatus.onDuty ? 'Clock Out' : 'Clock In'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'holiday',
                  child: Row(children: [
                    Icon(Icons.beach_access_rounded, size: 18, color: AppColors.orange),
                    const SizedBox(width: 10),
                    Text(staff.status == StaffStatus.onHoliday ? 'Return from Holiday' : 'Mark on Holiday'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_rounded, size: 18, color: AppColors.info),
                    SizedBox(width: 10),
                    Text('Edit Details'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(StaffMember staff, double radius) {
    if (staff.imagePath != null && staff.imagePath!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(staff.imagePath!),
        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
      child: Text(
        staff.initials,
        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 20),
          const Text('No staff members yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first staff member.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, StaffMember staff) async {
    final provider = context.read<StaffProvider>();
    switch (action) {
      case 'duty':
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: staff.status == StaffStatus.onDuty ? 'Select Clock Out Time' : 'Select Clock In Time',
        );
        if (time != null) {
          final now = DateTime.now();
          final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
          
          if (staff.status == StaffStatus.onDuty) {
            // Need a custom clockOut with time
            // We'll update StaffProvider to take time
            await provider.clockOut(staff, time: dt);
          } else {
            await provider.clockIn(staff, time: dt);
          }
        }
        break;
      case 'holiday':
        await provider.markHoliday(staff);
        break;
      case 'edit':
        await _showEditDialog(staff);
        break;
      case 'delete':
        final staffProvider = context.read<StaffProvider>();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Staff Member'),
            content: Text('Remove ${staff.name} from the team? This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await staffProvider.deleteStaff(staff.id);
        }
        break;
    }
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final wageCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Staff Member', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar picker
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (file != null) {
                      setDialogState(() => imagePath = file.path);
                    }
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: imagePath != null
                        ? ClipOval(child: Image.asset(imagePath!, fit: BoxFit.cover))
                        : const Icon(Icons.add_a_photo_rounded, color: AppColors.primaryGreen, size: 30),
                  ),
                ),
                const SizedBox(height: 16),
                _dialogField(nameCtrl, 'Full Name', Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _dialogField(roleCtrl, 'Role (Waiter, Cashier, Cook...)', Icons.work_outline_rounded),
                const SizedBox(height: 12),
                _dialogField(phoneCtrl, 'Phone Number', Icons.phone_outlined, type: TextInputType.phone),
                const SizedBox(height: 12),
                _dialogField(wageCtrl, 'Hourly Wage (KES)', Icons.monetization_on_outlined, type: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && roleCtrl.text.isNotEmpty) {
                  final member = StaffMember(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    role: roleCtrl.text.trim(),
                    status: StaffStatus.offDuty,
                    phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                    imagePath: imagePath,
                    lastModified: DateTime.now(),
                    hourlyWage: double.tryParse(wageCtrl.text) ?? 0.0,
                  );
                  context.read<StaffProvider>().addStaff(member);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(StaffMember staff) async {
    final nameCtrl = TextEditingController(text: staff.name);
    final roleCtrl = TextEditingController(text: staff.role);
    final wageCtrl = TextEditingController(text: staff.hourlyWage.toStringAsFixed(0));
    final phoneCtrl = TextEditingController(text: staff.phone ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Staff Member', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Full Name', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _dialogField(roleCtrl, 'Role', Icons.work_outline_rounded),
              const SizedBox(height: 12),
              _dialogField(phoneCtrl, 'Phone Number', Icons.phone_outlined, type: TextInputType.phone),
              const SizedBox(height: 12),
              _dialogField(wageCtrl, 'Hourly Wage (KES)', Icons.monetization_on_outlined, type: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                staff.name = nameCtrl.text.trim();
                staff.role = roleCtrl.text.trim();
                staff.phone = phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null;
                staff.hourlyWage = double.tryParse(wageCtrl.text) ?? staff.hourlyWage;
                staff.lastModified = DateTime.now();
                context.read<StaffProvider>().updateStaff(staff);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.scaffoldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
