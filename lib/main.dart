import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/kiosk_services.dart';
import 'screens/splash/splash_screen_v2.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalesService()),
        ChangeNotifierProvider(create: (_) => ProductionService()),
        ChangeNotifierProvider(create: (_) => ExpenseService()),
        ChangeNotifierProvider(create: (_) => SummaryService()),
        ChangeNotifierProvider(create: (_) => CreditService()),
        ChangeNotifierProvider(create: (_) => BillService()),
        ChangeNotifierProvider(create: (_) => AnalysisService()),
        ChangeNotifierProvider(create: (_) => SupplierService()),
        ChangeNotifierProvider(create: (_) => DeliveryService()),
      ],
      child: const EutonHotelApp(),
    ),
  );
}

class EutonHotelApp extends StatelessWidget {
  const EutonHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euton Hotel POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B5E20),
        scaffoldBackgroundColor: const Color(0xFFF5F7F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFFB8860B),
          surface: Colors.white,
          background: const Color(0xFFF5F7F9),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1B5E20)),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1B5E20),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1B5E20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      ),
      home: const SplashScreenV2(),
    );
  }
}
