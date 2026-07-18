import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/security/auth_service.dart';
import 'providers/theme_provider.dart';
import 'providers/report_provider.dart';
import 'providers/staff_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

import 'data/repositories/i_report_repository.dart';
import 'data/repositories/local_report_repository.dart';
import 'data/repositories/api_report_repository.dart';
import 'data/repositories/i_staff_repository.dart';
import 'data/repositories/local_staff_repository.dart';
import 'data/repositories/api_staff_repository.dart';
import 'data/repositories/i_audit_log_repository.dart';
import 'data/repositories/local_audit_log_repository.dart';
import 'data/repositories/api_audit_log_repository.dart';

const bool useCloudBackend = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize auth service (creates hashed default PIN if needed)
  await AuthService.instance.initialize();

  // Load theme preference
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        // ── Repository Layer (Dependency Injection) ──
        Provider<IReportRepository>(
          create: (_) => useCloudBackend ? ApiReportRepository() : LocalReportRepository.instance,
        ),
        Provider<IStaffRepository>(
          create: (_) => useCloudBackend ? ApiStaffRepository() : LocalStaffRepository.instance,
        ),
        Provider<IAuditLogRepository>(
          create: (_) => useCloudBackend ? ApiAuditLogRepository() : LocalAuditLogRepository(),
        ),

        // ── State Layer (Providers) ──
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProxyProvider2<IReportRepository, IAuditLogRepository, ReportProvider>(
          create: (context) => ReportProvider(
            context.read<IReportRepository>(),
            context.read<IAuditLogRepository>(),
          ),
          update: (_, reportRepo, auditRepo, prev) => prev ?? ReportProvider(reportRepo, auditRepo),
        ),
        ChangeNotifierProxyProvider<IStaffRepository, StaffProvider>(
          create: (context) => StaffProvider(context.read<IStaffRepository>()),
          update: (_, repo, prev) => prev ?? StaffProvider(repo),
        ),
      ],
      child: const CopyApp(),
    ),
  );
}

class CopyApp extends StatelessWidget {
  const CopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const LoginScreen(),
          builder: (context, child) {
            // Ensure text scaling doesn't break layouts
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
