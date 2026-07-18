import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../pos/pos_screen.dart';
import '../expenses/expenses_screen.dart';
import '../../widgets/custom_widgets.dart';
import '../orders/orders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const POSScreen(),
    const ExpensesScreen(),
    const OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 0) {
              context.read<ReportProvider>().refreshReports();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 10,
          unselectedFontSize: 10,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.touch_app_rounded), label: 'Sell'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Expenses'),
            BottomNavigationBarItem(icon: Icon(Icons.delivery_dining_rounded), label: 'Orders'),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().refreshReports();
    });
  }

  void _showExpensesModal(BuildContext context, ReportProvider report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Expenses Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: report.expenses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No expenses recorded today',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: report.expenses.length,
                    itemBuilder: (context, index) {
                      final item = report.expenses[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFEE2E2),
                          child: Icon(Icons.money_off_rounded, color: Colors.red, size: 20),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          'Account: ${item.accountName}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        trailing: Text(
                          'KES ${item.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy App'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<ReportProvider>().refreshReports(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, report, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, // Reduced card size
                  childAspectRatio: 1.15,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    SummaryCard(
                      label: 'Total Sales',
                      value: 'KES ${report.amountSales.toStringAsFixed(0)}',
                      icon: Icons.payments_rounded,
                      color: Colors.green,
                    ),
                    SummaryCard(
                      label: 'Orders',
                      value: report.orderCount.toString(),
                      icon: Icons.receipt_long_rounded,
                      color: Colors.blue,
                    ),
                    SummaryCard(
                      label: 'Deliveries',
                      value: 'KES ${report.deliveryRevenue.toStringAsFixed(0)}',
                      icon: Icons.delivery_dining_rounded,
                      color: Colors.purple,
                    ),
                    SummaryCard(
                      label: 'Cash on Hand',
                      value: 'KES ${report.cashOnHand.toStringAsFixed(0)}',
                      icon: Icons.money_rounded,
                      color: Colors.teal,
                    ),
                    SummaryCard(
                      label: 'M-Pesa Amount',
                      value: 'KES ${report.mpesaIncome.toStringAsFixed(0)}',
                      icon: Icons.phone_android_rounded,
                      color: Colors.indigo,
                    ),
                    GestureDetector(
                      onTap: () => _showExpensesModal(context, report),
                      child: SummaryCard(
                        label: 'Expenses (Tap)',
                        value: 'KES ${report.amountExpenses.toStringAsFixed(0)}',
                        icon: Icons.money_off_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }


}
