import 'package:flutter/material.dart';
import 'core/theme/nexus_theme.dart';
import 'core/widgets/sidebar/nexus_sidebar.dart';
import 'core/widgets/common/command_palette.dart';
import 'core/services/nexus_api.dart';
import 'package:url_launcher/url_launcher.dart';

// Screens
import 'features/home/god_mode_screen.dart';
import 'features/command_center/command_center_screen.dart';
import 'features/products/products_screen.dart';
import 'features/customers/customers_screen.dart';
import 'features/deployments/deployments_screen.dart';
import 'features/infrastructure/infrastructure_screen.dart';
import 'features/billing/billing_screen.dart';
import 'features/security/security_screen.dart';
import 'features/ai_center/ai_center_screen.dart';
import 'features/assistant/ai_assistant_screen.dart';
import 'features/website_center/website_center_screen.dart';
import 'features/settings/settings_screen.dart';


// Global Notifier for Theme Toggle
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const MobawiNexusApp());
}

class MobawiNexusApp extends StatelessWidget {
  const MobawiNexusApp({super.key});

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
          home: const PasswordScreen(),
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
  String _currentWorkspace = 'Mobawi Main';

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

  void _showCommandPalette() {
    showDialog(
      context: context,
      builder: (context) => CommandPalette(
        onActionSelected: (action) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Executing Command: $action'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
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
      case 'deployments':
        return DeploymentsScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'updates':
        return DeploymentsScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'infrastructure':
        return InfrastructureScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'billing':
        return BillingScreen(onNavigate: (sec) => setState(() => _activeSection = sec));

      case 'security':
        return SecurityScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'ai_center':
        return AiCenterScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'ai_assistant':
        return AiAssistantScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'website_center':
        return WebsiteCenterScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
      case 'settings':
        return SettingsScreen(onNavigate: (sec) => setState(() => _activeSection = sec));
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
                // Mobawi Logo
                Icon(
                  Icons.space_dashboard_outlined,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                // Workspace Selector
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentWorkspace,
                    dropdownColor: theme.cardColor,
                    style: TextStyle(
                      color: isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: <String>['Mobawi Main', 'SaaS Mobawi Dev', 'Staging Workspace'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _currentWorkspace = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 24),
                // Search Trigger Bar
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: _showCommandPalette,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderSideColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 16, color: textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              'Search actions, systems...',
                              style: TextStyle(color: textSecondary.withValues(alpha: 0.6), fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              'Ctrl+K',
                              style: TextStyle(color: textSecondary.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
    // Hardcoded bypass as requested
    if (value == 'kali') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NexusShell()),
      );
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
