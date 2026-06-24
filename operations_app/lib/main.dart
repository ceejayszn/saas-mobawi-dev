import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/inventory_provider.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/report_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
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
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
      ),
      home: const SplashScreen(),
    );
  }
}
