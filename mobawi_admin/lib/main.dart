import 'package:flutter/material.dart';
import 'core/theme/nexus_theme.dart';
import 'core/widgets/sidebar/nexus_sidebar.dart';
import 'core/widgets/common/command_palette.dart';
import 'core/services/nexus_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/home/god_mode_screen.dart';
import 'features/command_center/command_center_screen.dart';
import 'features/products/products_screen.dart';
import 'features/customers/customers_screen.dart';
import 'features/billing/billing_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/portfolio/portfolio_screen.dart';
import 'features/analysis/analysis_screen.dart';
import 'features/community/community_screen.dart';
import 'features/support/support_screen.dart';
import 'features/docs/docs_screen.dart';


import 'package:shared_preferences/shared_preferences.dart';

// Global Notifier for Theme Toggle
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MobawiNexusApp(isLoggedIn: isLoggedIn));
}

class MobawiNexusApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MobawiNexusApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Mobawi Nexus — CEO Command Center',
          debugShowCheckedModeBanner: false,
          theme: NexusTheme.lightTheme,
          darkTheme: NexusTheme.darkTheme,
          themeMode: currentMode,
          home: isLoggedIn ? const NexusShell() : const PasswordScreen(),
        );
      },
    );
  }
}

class NexusShell extends StatefulWidget {
  const NexusShell({super.key});

  @override
  State<NexusShell> createState() => _NexusShellState();
}

class _NexusShellState extends State<NexusShell> {
  String _activeSection = 'god_mode';
  bool _isSidebarCollapsed = false;
  final NexusApi _api = NexusApi();

  @override
  void initState() {
    super.initState();
    // Start active polling connections to Backend APIs
    _api.startStreaming();
  }

  @override
  void dispose() {
    _api.stopStreaming();
    super.dispose();
  }

  Widget _buildActiveScreen() {
    switch (_activeSection) {
      case 'god_mode':
        return GodModeScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'command_center':
        return CommandCenterScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'products':
        return ProductsScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'customers':
        return CustomersScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'billing':
        return BillingScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'settings':
        return SettingsScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'portfolio':
        return PortfolioScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'analysis':
        return AnalysisScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'community':
        return CommunityScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'support':
        return SupportScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'docs':
        return DocsScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      default:
        return GodModeScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Top Navigation Bar (Fixed)
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(color: borderSideColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Company Logo
                Image.asset(
                  'assets/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.diamond_outlined,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ),
                const Spacer(),
                // Centered Stylish Name
                Text(
                  'MOBAWI SAAS LLC',
                  style: GoogleFonts.orbitron(
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: isDark ? Colors.white : Colors.black87,
                      shadows: [
                        Shadow(
                          color: theme.primaryColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Notifications Bell
                IconButton(
                  icon: Icon(Icons.notifications_none_outlined, color: textSecondary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                // Theme Toggle Button
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: textSecondary,
                  ),
                  onPressed: () {
                    themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
                const SizedBox(width: 16),
                // User Avatar
                const CircleAvatar(
                  backgroundColor: NexusTheme.accent,
                  radius: 16,
                  child: Text(
                    'M',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 2. Middle Section (Sidebar + Workspace side-by-side)
          Expanded(
            child: Row(
              children: [
                // Collapsible Sidebar
                NexusSidebar(
                  activeSection: _activeSection,
                  onSectionChanged: (sec) => setState(() => _activeSection = sec),
                  isCollapsed: _isSidebarCollapsed,
                  onToggleCollapse: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                ),
                // Main screen workspace canvas
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildActiveScreen(),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Status Bar (Fixed)
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(color: borderSideColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: NexusTheme.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Railway Server: Connected',
                  style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  'Version: 1.0.0',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
                const SizedBox(width: 16),
                Text(
                  'Last sync: Just now',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submit(String value) async {
    // Real login with backend
    if (value == 'kali') {
      final success = await NexusApi().login('admin', 'kali');
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NexusShell()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to backend API.')),
        );
      }
    } else {
      final url = Uri.parse('https://watchbutdonotlearn.github.io/');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TextField(
          controller: _controller,
          autofocus: true,
          obscureText: true,
          onSubmitted: _submit,
          style: const TextStyle(color: Colors.transparent),
          cursorColor: Colors.transparent,
          decoration: const InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.black,
            filled: true,
          ),
        ),
      ),
    );
  }
}
