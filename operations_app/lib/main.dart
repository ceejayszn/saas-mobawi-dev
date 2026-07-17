import 'package:flutter/material.dart';
import 'presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/inventory_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/sale_provider.dart';
import 'presentation/providers/report_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

import 'data/repositories/i_expense_repository.dart';
import 'data/repositories/local_expense_repository.dart';
import 'data/repositories/api_expense_repository.dart';
import 'data/repositories/i_menu_repository.dart';
import 'data/repositories/local_menu_repository.dart';
import 'data/repositories/api_menu_repository.dart';
import 'data/repositories/i_order_repository.dart';
import 'data/repositories/local_order_repository.dart';
import 'data/repositories/api_order_repository.dart';
import 'data/repositories/i_report_repository.dart';
import 'data/repositories/local_report_repository.dart';
import 'data/repositories/api_report_repository.dart';
import 'data/services/sync_service.dart';

const bool useCloudBackend = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SyncService.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        // ── Repository Layer (Dependency Injection) ──
        Provider<IExpenseRepository>(
          create: (_) => useCloudBackend ? ApiExpenseRepository() : LocalExpenseRepository(),
        ),
        Provider<IMenuRepository>(
          create: (_) => useCloudBackend ? ApiMenuRepository() : LocalMenuRepository(),
        ),
        Provider<IOrderRepository>(
          create: (_) => useCloudBackend ? ApiOrderRepository() : LocalOrderRepository(),
        ),
        Provider<IReportRepository>(
          create: (_) => useCloudBackend ? ApiReportRepository() : LocalReportRepository(),
        ),

        // ── State Layer (Providers) ──
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<IExpenseRepository, ExpenseProvider>(
          create: (context) => ExpenseProvider(context.read<IExpenseRepository>()),
          update: (_, repo, prev) => prev ?? ExpenseProvider(repo),
        ),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProxyProvider<IMenuRepository, ProductProvider>(
          create: (context) => ProductProvider(context.read<IMenuRepository>()),
          update: (_, repo, prev) => prev ?? ProductProvider(repo),
        ),
        ChangeNotifierProxyProvider<IOrderRepository, SaleProvider>(
          create: (context) => SaleProvider(context.read<IOrderRepository>()),
          update: (_, repo, prev) => prev ?? SaleProvider(repo),
        ),
        ChangeNotifierProxyProvider<IReportRepository, ReportProvider>(
          create: (context) => ReportProvider(context.read<IReportRepository>()),
          update: (_, repo, prev) => prev ?? ReportProvider(repo),
        ),
      ],
      child: const OperationsApp(),
    ),
  );
}

class OperationsApp extends StatelessWidget {
  const OperationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operations App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
