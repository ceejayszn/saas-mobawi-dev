import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../data/models/staff_member.dart';
import '../../providers/staff_provider.dart';

class StaffDetailScreen extends StatefulWidget {
  final String staffId;
  const StaffDetailScreen({super.key, required this.staffId});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StaffMember? _staff;
  List<StaffShift> _shifts = [];
  List<StaffTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<StaffProvider>();
    final all = provider.staff;
    final found = all.where((s) => s.id == widget.staffId).toList();
    if (found.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final staff = found.first;
    final shifts = await provider.getShifts(widget.staffId);
    final transactions = await provider.getTransactions(widget.staffId);

    if (mounted) {
      setState(() {
        _staff = staff;
        _shifts = shifts;
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    final staff = _staff!;
    Color statusColor;
    switch (staff.status) {
      case StaffStatus.onDuty: statusColor = AppColors.success; break;
      case StaffStatus.onHoliday: statusColor = AppColors.orange; break;
      case StaffStatus.offDuty: statusColor = AppColors.error; break;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      body: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Back button row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _pickImage(staff),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showEditDialog(staff),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _deleteStaff(staff),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar
                GestureDetector(
                  onTap: () => _pickImage(staff),
                  child: _buildAvatar(staff, 42),
                ),
                const SizedBox(height: 12),

                // Name + role
                Text(
                  staff.name,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(staff.role, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        staff.statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                if (staff.phone != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_rounded, color: Colors.white54, size: 14),
                      const SizedBox(width: 6),
                      Text(staff.phone!, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Stat cards row
                Row(
                  children: [
                    _headerStat('KES/hr', staff.hourlyWage.toStringAsFixed(0), Icons.speed_rounded),
                    _headerStat('Hours', staff.totalHoursWorked.toStringAsFixed(1), Icons.timer_rounded),
                    _headerStat('Earned', 'KES ${staff.totalWagesEarned.toStringAsFixed(0)}', Icons.monetization_on_rounded),
                    _headerStat('Payable', 'KES ${staff.netPayable.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded),
                  ],
                ),
              ],
            ),
          ),

          // Last modified info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  'Last modified: ${_formatDate(staff.lastModified)}',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showAddTransactionDialog(staff),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: AppColors.primaryGreen, size: 14),
                        SizedBox(width: 4),
                        Text('Add Transaction', style: TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Shifts'),
                Tab(text: 'Transactions'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(staff, isDark),
                _buildShiftsTab(isDark),
                _buildTransactionsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
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
        backgroundColor: Colors.white.withValues(alpha: 0.2),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: Text(
        staff.initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: radius * 0.6),
      ),
    );
  }

  Widget _buildOverviewTab(StaffMember staff, bool isDark) {
    final typeColors = {
      StaffTransactionType.salary: AppColors.success,
      StaffTransactionType.advance: AppColors.warning,
      StaffTransactionType.allowance: AppColors.info,
      StaffTransactionType.bonus: AppColors.purple,
      StaffTransactionType.deduction: AppColors.error,
      StaffTransactionType.expense: AppColors.orange,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial summary grid
          _sectionTitle('Financial Summary'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _financeStat('Wages Earned', 'KES ${staff.totalWagesEarned.toStringAsFixed(0)}', AppColors.success, isDark),
              _financeStat('Salary Paid', 'KES ${staff.totalSalaryPaid.toStringAsFixed(0)}', AppColors.info, isDark),
              _financeStat('Total Advances', 'KES ${staff.totalAdvances.toStringAsFixed(0)}', AppColors.warning, isDark),
              _financeStat('Net Payable', 'KES ${staff.netPayable.toStringAsFixed(0)}', AppColors.primaryGreen, isDark),
            ],
          ),
          const SizedBox(height: 20),

          // Transaction type breakdown
          if (_transactions.isNotEmpty) ...[
            _sectionTitle('Transaction Breakdown'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Column(
                children: StaffTransactionType.values.map((type) {
                  final total = _transactions
                      .where((t) => t.type == type)
                      .fold<double>(0, (sum, t) => sum + t.amount);
                  if (total == 0) return const SizedBox.shrink();
                  final color = typeColors[type] ?? AppColors.textSecondary;
                  return _transactionTypeTile(type.typeLabel, 'KES ${total.toStringAsFixed(0)}', color, isDark);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _financeStat(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _transactionTypeTile(String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildShiftsTab(bool isDark) {
    if (_shifts.isEmpty) {
      return _emptyTab('No shifts recorded', 'Shifts will appear here when staff clock in.', Icons.schedule_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shifts.length,
      itemBuilder: (context, index) {
        final shift = _shifts[_shifts.length - 1 - index]; // Newest first
        final isOpen = shift.endTime == null;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isOpen ? Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.successLight : AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOpen ? Icons.login_rounded : Icons.schedule_rounded,
                  color: isOpen ? AppColors.success : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.date,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'In: ${_formatTime(shift.startTime)}  ${shift.endTime != null ? '· Out: ${_formatTime(shift.endTime!)}' : ''}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isOpen)
                    const Text('Active', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w800))
                  else if (shift.hoursWorked != null)
                    Text(
                      '${shift.hoursWorked!.toStringAsFixed(1)}h',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab(bool isDark) {
    if (_transactions.isEmpty) {
      return _emptyTab('No transactions yet', 'Record salary, advances, and other payments here.', Icons.receipt_long_rounded);
    }

    final typeColors = {
      StaffTransactionType.salary: AppColors.success,
      StaffTransactionType.advance: AppColors.warning,
      StaffTransactionType.allowance: AppColors.info,
      StaffTransactionType.bonus: AppColors.purple,
      StaffTransactionType.deduction: AppColors.error,
      StaffTransactionType.expense: AppColors.orange,
    };

    final sorted = List<StaffTransaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final tx = sorted[index];
        final color = typeColors[tx.type] ?? AppColors.textSecondary;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.typeLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(_formatDate(tx.date), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    if (tx.notes != null && tx.notes!.isNotEmpty)
                      Text(tx.notes!, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                'KES ${tx.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: tx.type == StaffTransactionType.deduction ? AppColors.error : color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyTab(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800));
  }

  Future<void> _pickImage(StaffMember staff) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null && mounted) {
      staff.imagePath = file.path;
      staff.lastModified = DateTime.now();
      await context.read<StaffProvider>().updateStaff(staff);
      await _loadData();
    }
  }

  void _showAddTransactionDialog(StaffMember staff) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    StaffTransactionType selectedType = StaffTransactionType.salary;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: StaffTransactionType.values.map((t) {
                    final selected = selectedType == t;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedType = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.typeLabel,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount (KES)',
                    prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppColors.primaryGreen, size: 20),
                    filled: true,
                    fillColor: AppColors.scaffoldBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    hintText: 'Notes (optional)',
                    prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.primaryGreen, size: 20),
                    filled: true,
                    fillColor: AppColors.scaffoldBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text);
                if (amt != null && amt > 0) {
                  final tx = StaffTransaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    staffId: staff.id,
                    type: selectedType,
                    amount: amt,
                    date: DateTime.now(),
                    notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                  );
                  await context.read<StaffProvider>().addTransaction(tx);
                  if (context.mounted) Navigator.pop(ctx);
                  await _loadData();
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
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: wageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hourly Wage (KES)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                staff.name = nameCtrl.text.trim();
                staff.role = roleCtrl.text.trim();
                staff.phone = phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null;
                staff.hourlyWage = double.tryParse(wageCtrl.text) ?? staff.hourlyWage;
                staff.lastModified = DateTime.now();
                await context.read<StaffProvider>().updateStaff(staff);
                if (context.mounted) Navigator.of(ctx).pop();
                await _loadData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStaff(StaffMember staff) async {
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
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<StaffProvider>().deleteStaff(staff.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
