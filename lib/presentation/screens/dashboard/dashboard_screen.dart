import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../pos/pos_screen.dart';
import '../menu/menu_screen.dart';
import '../expenses/expenses_screen.dart';
import '../reports/reports_screen.dart';
import '../inventory/inventory_screen.dart';
import '../../widgets/custom_widgets.dart';

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
    const ReportsScreen(),
    const InventoryScreen(),
    const MenuScreen(),
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 0 || index == 2) {
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
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: 'POS'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Stock'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'Menu'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Euton Hotel'),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    SummaryCard(
                      label: 'Total Sales',
                      value: 'KES ${report.totalSales.toStringAsFixed(0)}',
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
                      label: 'Expenses',
                      value: 'KES ${report.totalExpenses.toStringAsFixed(0)}',
                      icon: Icons.money_off_rounded,
                      color: Colors.red,
                    ),
                    SummaryCard(
                      label: 'Net Profit',
                      value: 'KES ${report.netProfit.toStringAsFixed(0)}',
                      icon: Icons.trending_up_rounded,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        AppCard(
          onTap: () {
            // This is handled by index stack in parent, but for now we fallback or navigate
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
          },
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_shopping_cart, color: Colors.red),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Log supplies or utility bills', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          onTap: () {
            // Logic to open POS from dashboard
          },
          color: Theme.of(context).primaryColor,
          child: const Row(
            children: [
              Icon(Icons.flash_on, color: Colors.white),
              SizedBox(width: 16),
              Text(
                'New Instant Sale',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ],
    );
  }
}

