import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const SettingsScreen({super.key, required this.onNavigate});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

  final TextEditingController _apiUrlController = TextEditingController();
  bool _mfaEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final data = await _api.fetchSettingsOverview();
    if (mounted) {
      setState(() {
        _settings = data;
        _apiUrlController.text = _api.apiBaseUrl;
        _mfaEnabled = _settings['mfa_enabled'] ?? false;
        _isLoading = false;
      });
    }
  }

  void _saveSettings() {
    _api.apiBaseUrl = _apiUrlController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('API Base URL updated to: ${_api.apiBaseUrl}')),
    );
  }

  void _toggleWebhook(int index) {
    setState(() {
      final list = _settings['webhooks'] as List<dynamic>? ?? [];
      final item = list[index];
      final current = item['status'] ?? 'ACTIVE';
      item['status'] = current == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Webhook route policy propagated to edge router.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_settings.isEmpty) {
      return NexusEmptyState(
        title: 'Settings Lock Active',
        description: 'Environment variables, webhook routes, and global parameters require authorization.',
        icon: Icons.settings_outlined,
        actionLabel: 'Load Settings Cache',
        onAction: _loadSettings,
      );
    }

    final webhooks = _settings['webhooks'] as List<dynamic>? ?? [];
    final rateLimits = _settings['rate_limits'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYSTEM & PLATFORM SETTINGS', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text('Manage global environment variables, client rate limits, and webhook callbacks.', style: theme.textTheme.bodyMedium),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadSettings,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reload Settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: borderColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Settings & Webhooks
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NexusCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Global Configuration', style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _apiUrlController,
                            style: const TextStyle(fontSize: 13, fontFamily: 'JetBrains Mono'),
                            decoration: InputDecoration(
                              labelText: 'Active Backend API Root URL',
                              border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                              labelStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Multifactor Authentication (MFA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Enforce founder-level mobile authentication.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                                ],
                              ),
                              Switch(
                                value: _mfaEnabled,
                                activeThumbColor: theme.primaryColor,
                                onChanged: (val) {
                                  setState(() => _mfaEnabled = val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Commit Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Webhooks List
                    NexusCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Registered Webhook Callbacks', style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 16),
                          ...webhooks.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final webhook = entry.value;
                            final url = webhook['url'] ?? '';
                            final event = webhook['event'] ?? '';
                            final status = webhook['status'] ?? 'ACTIVE';

                            final isActive = status == 'ACTIVE';
                            final color = isActive ? NexusTheme.success : NexusTheme.warning;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.webhook_outlined, color: color),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(url, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'JetBrains Mono')),
                                        Text('Subscribed event: $event', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _toggleWebhook(idx),
                                    child: Text(
                                      isActive ? 'Disable' : 'Enable',
                                      style: TextStyle(color: isActive ? NexusTheme.warning : NexusTheme.success, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right side: Rate limits / environment vars
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    NexusCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Environment variables', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 16),
                          _buildEnvVarRow('NODE_ENV', _settings['environment'] ?? 'production'),
                          _buildEnvVarRow('API_VERSION', _settings['api_version'] ?? 'v1.0.0'),
                          _buildEnvVarRow('DATABASE_PROVIDER', 'PostgreSQL (Neon)'),
                          _buildEnvVarRow('RATE_LIMITER', 'Redis Store'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    NexusCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('API Rate Limits', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ...rateLimits.entries.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key.replaceAll('_', ' ').toUpperCase(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NexusTheme.textSecondary),
                                    ),
                                    Text(
                                      e.value.toString(),
                                      style: const TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvVarRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: NexusTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
