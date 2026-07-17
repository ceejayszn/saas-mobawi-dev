import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' show join;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import '../../../data/models/expense.dart';
import '../../providers/report_provider.dart';
import '../../../utils/export_service.dart';
import '../../../data/db/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadForTab(_selectedTab);
    });
  }

  Future<void> _handleMenuSelection(String value) async {
    final report = context.read<ReportProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    if (value == 'Share') {
      final summaryText = '''
Copy App Boss Analytics Summary
Period: ${_selectedTab == 0 ? "Today" : _selectedTab == 1 ? "This Week" : "This Month"}
Gross Revenue: KES ${report.amountSales.toStringAsFixed(0)}
Total Costs: KES ${report.amountExpenses.toStringAsFixed(0)}
Net Profit: KES ${report.netProfit.toStringAsFixed(0)}
Cash on Hand: KES ${report.cashOnHand.toStringAsFixed(0)}
M-Pesa Income: KES ${report.mpesaIncome.toStringAsFixed(0)}
Deliveries: KES ${report.deliveryRevenue.toStringAsFixed(0)}
      ''';
      await Share.share(summaryText, subject: 'Copy App Analytics');
    } else if (value == 'Export CSV') {
      try {
        ExportService.shareCsv(report, _selectedTab == 0 ? "Today" : _selectedTab == 1 ? "This Week" : "This Month");
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } else if (value == 'Share PDF') {
      try {
        ExportService.sharePdf(report, _selectedTab == 0 ? "Today" : _selectedTab == 1 ? "This Week" : "This Month");
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('PDF Export failed: $e')));
      }
    } else if (value == 'Print') {
      try {
        ExportService.printReport(report, _selectedTab == 0 ? "Today" : _selectedTab == 1 ? "This Week" : "This Month");
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Print failed: $e')));
      }
    } else if (value == 'Backup') {
      try {
        ExportService.shareDbFile();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    } else if (value == 'Restore') {
      try {
        final result = await FilePicker.pickFiles(
          type: FileType.any,
        );
        if (result != null && result.files.single.path != null) {
          final chosenPath = result.files.single.path!;
          final dbPath = await getDatabasesPath();
          final targetFile = File(join(dbPath, 'copy_app.db'));
          
          if (!mounted) return;
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Confirm Restore'),
              content: const Text('Are you sure you want to restore? This will overwrite all current local data!'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Restore'),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            final db = await DatabaseHelper.instance.database;
            await db.close();
            
            final chosenFile = File(chosenPath);
            await chosenFile.copy(targetFile.path);
            
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Database restored successfully! Please restart the app.'),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    } else {
      messenger.showSnackBar(SnackBar(content: Text('$value selected')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 34),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: const [
            Text('⚡', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text(
              'Boss Analytics',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: const Color(0xFFFDFDF7),
            surfaceTintColor: Colors.white,
            icon: const Icon(Icons.more_vert, size: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'Godmode',
                child: _MenuRow(icon: Icons.shield, iconColor: Colors.red, label: 'Godmode'),
              ),
              PopupMenuItem<String>(
                value: 'Pick Date',
                child: _MenuRow(icon: Icons.calendar_month, iconColor: Colors.teal, label: 'Pick Date (Calendar)'),
              ),
              PopupMenuItem<String>(
                value: 'Share',
                child: _MenuRow(icon: Icons.share, iconColor: Colors.black54, label: 'Share Text Report'),
              ),
              PopupMenuItem<String>(
                value: 'Share PDF',
                child: _MenuRow(icon: Icons.picture_as_pdf, iconColor: Colors.red, label: 'Share PDF Report'),
              ),
              PopupMenuItem<String>(
                value: 'Print',
                child: _MenuRow(icon: Icons.print, iconColor: Colors.black, label: 'Print Report'),
              ),
              PopupMenuItem<String>(
                value: 'Export CSV',
                child: _MenuRow(icon: Icons.storefront, iconColor: Colors.green, label: 'Export CSV (Excel)'),
              ),
              PopupMenuItem<String>(
                value: 'Backup',
                child: _MenuRow(icon: Icons.download_for_offline_outlined, iconColor: Colors.blue, label: '🔒 Backup Database (Encrypted)'),
              ),
              PopupMenuItem<String>(
                value: 'Restore',
                child: _MenuRow(icon: Icons.restore_page, iconColor: Colors.orange, label: 'Restore Database (from CopyApp Data)'),
              ),
            ],
            onSelected: _handleMenuSelection,
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, report, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SegmentedTabs(
                  selectedTab: _selectedTab,
                  onSelect: (index) async {
                    setState(() => _selectedTab = index);
                    await context.read<ReportProvider>().loadForTab(index);
                  },
                ),
                const SizedBox(height: 24),
                _HeroAnalyticsCard(report: report),
                const SizedBox(height: 22),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.98,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  children: [
                    _StatCard(value: report.amountSales, label: 'Gross Revenue', icon: Icons.trending_up, iconColor: const Color(0xFF1FB7B8), tint: const Color(0xFFEAF9FB)),
                    _StatCard(value: report.amountExpenses, label: 'Total Costs', icon: Icons.trending_down, iconColor: const Color(0xFFEB6E74), tint: const Color(0xFFFFEFF1)),
                    _StatCard(value: report.mpesaIncome, label: 'M-Pesa Income', icon: Icons.phone_android, iconColor: const Color(0xFF4CAF50), tint: const Color(0xFFEAF8EA)),
                    _StatCard(value: report.cashOnHand, label: 'Cash on Hand', icon: Icons.account_balance_wallet_outlined, iconColor: const Color(0xFF5FA0EE), tint: const Color(0xFFECF5FF)),
                    _StatCard(value: report.eatInRevenue, label: 'Eat In Revenue', icon: Icons.restaurant, iconColor: const Color(0xFFF3A42B), tint: const Color(0xFFFFF3E4)),
                    _StatCard(value: report.deliveryRevenue, label: 'Delivery Revenue', icon: Icons.delivery_dining, iconColor: const Color(0xFF9246D8), tint: const Color(0xFFF5EAFE)),
                  ],
                ),
                const SizedBox(height: 28),
                _SectionTitle(emoji: '🍽️', title: 'Sales Summary'),
                const SizedBox(height: 12),
                _SalesSummaryTable(rows: report.salesSummary),
                const SizedBox(height: 28),
                _SectionTitle(emoji: '🗓️', title: 'Expenditure by Supplier'),
                const SizedBox(height: 12),
                _ExpenseSummaryTable(expenses: report.expenses),
                const SizedBox(height: 28),
                _SectionTitle(emoji: '🏆', title: 'Top Items'),
                const SizedBox(height: 12),
                _TopItemsList(rows: report.topItems),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.selectedTab,
    required this.onSelect,
  });

  final int selectedTab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          _SegmentItem(icon: Icons.calendar_today, label: 'Today', selected: selectedTab == 0, onTap: () => onSelect(0)),
          _SegmentItem(icon: Icons.calendar_month, label: 'This Week', selected: selectedTab == 1, onTap: () => onSelect(1)),
          _SegmentItem(icon: Icons.grid_view, label: 'This Month', selected: selectedTab == 2, onTap: () => onSelect(2)),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1B5E20) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : const Color(0xFF838383), size: 24),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroAnalyticsCard extends StatelessWidget {
  const _HeroAnalyticsCard({required this.report});

  final ReportProvider report;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF238A2F),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(color: Color(0x2239A846), blurRadius: 28, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: Color(0xBFFFFFFF), size: 22),
              SizedBox(width: 10),
              Text(
                'NET PROFIT / LOSS',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'KES ${report.netProfit.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeroMetric(label: 'Gross Revenue', value: report.amountSales),
              _HeroMetric(label: 'Total Costs', value: report.amountExpenses),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xC8FFFFFF), fontSize: 18)),
        const SizedBox(height: 6),
        Text(
          'KES ${value.toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.tint,
  });

  final double value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const Spacer(),
          Text(
            'KES ${value.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF8B8B8B)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.emoji,
    required this.title,
  });

  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SalesSummaryTable extends StatelessWidget {
  const _SalesSummaryTable({required this.rows});

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    final amountQuantity = rows.fold<int>(0, (sum, row) => sum + ((row['quantity'] ?? 0) as num).toInt());
    final amountAmount = rows.fold<double>(0.0, (sum, row) => sum + ((row['amount'] ?? 0) as num).toDouble());

    return _RoundedTable(
      headerColor: const Color(0xFF1B5E20),
      footerColor: const Color(0xFFEFF7EE),
      columns: const ['Item', 'Qty', 'Amount'],
      rows: rows
          .map(
            (row) => [
              (row['item_name'] ?? '').toString().toLowerCase(),
              ((row['quantity'] ?? 0) as num).toInt().toString(),
              'KES ${((row['amount'] ?? 0) as num).toDouble().toStringAsFixed(0)}',
            ],
          )
          .toList(),
      amountRow: ['TOTAL', '$amountQuantity', 'KES ${amountAmount.toStringAsFixed(0)}'],
      amountColor: const Color(0xFF1B5E20),
    );
  }
}

class _ExpenseSummaryTable extends StatelessWidget {
  const _ExpenseSummaryTable({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final amountAmount = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

    return _RoundedTable(
      headerColor: const Color(0xFFFF4336),
      footerColor: const Color(0xFFFFEFEF),
      columns: const ['Supplier / Shop', 'Amount Spent'],
      rows: expenses
          .map(
            (expense) => [
              expense.title,
              'KES ${expense.amount.toStringAsFixed(0)}',
            ],
          )
          .toList(),
      amountRow: ['TOTAL', 'KES ${amountAmount.toStringAsFixed(0)}'],
      amountColor: const Color(0xFFD93D53),
    );
  }
}

class _RoundedTable extends StatelessWidget {
  const _RoundedTable({
    required this.headerColor,
    required this.footerColor,
    required this.columns,
    required this.rows,
    required this.amountRow,
    required this.amountColor,
  });

  final Color headerColor;
  final Color footerColor;
  final List<String> columns;
  final List<List<String>> rows;
  final List<String> amountRow;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 5))],
        ),
        child: Column(
          children: [
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: columns.length == 3 ? 3 : 4,
                    child: Text(columns[0], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  if (columns.length == 3)
                    Expanded(
                      child: Text(columns[1], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                    ),
                  Expanded(
                    flex: 2,
                    child: Text(columns.last, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No data yet', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16)),
              )
            else
              ...rows.map((row) => _TableRowItem(row: row, amountColor: amountColor)),
            Container(
              color: footerColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    flex: columns.length == 3 ? 3 : 4,
                    child: Text(amountRow[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ),
                  if (columns.length == 3)
                    Expanded(
                      child: Text(amountRow[1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                  Expanded(
                    flex: 2,
                    child: Text(amountRow.last, textAlign: TextAlign.right, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: amountColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  const _TableRowItem({
    required this.row,
    required this.amountColor,
  });

  final List<String> row;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: row.length == 3 ? 3 : 4,
            child: Text(row[0], style: const TextStyle(fontSize: 18)),
          ),
          if (row.length == 3)
            Expanded(
              child: Text(row[1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            ),
          Expanded(
            flex: 2,
            child: Text(
              row.last,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: amountColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopItemsList extends StatelessWidget {
  const _TopItemsList({required this.rows});

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 5)),
        ],
      ),
      child: rows.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(22),
              child: Text('No item sales yet', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16)),
            )
          : Column(
              children: rows.map((row) {
                final quantity = ((row['quantity'] ?? 0) as num).toInt();
                final percent = ((row['percent'] ?? 0) as num).toDouble();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (row['item_name'] ?? '').toString().toLowerCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            '$quantity sold',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: const Color(0xFFECECEC),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF1B5E20)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${(percent * 100).toStringAsFixed(1)}% of amount sold',
                          style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
