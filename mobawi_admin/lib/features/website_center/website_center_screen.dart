import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/kpi_card.dart';

class WebsiteCenterScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const WebsiteCenterScreen({super.key, required this.onNavigate});

  @override
  State<WebsiteCenterScreen> createState() => _WebsiteCenterScreenState();
}

class _WebsiteCenterScreenState extends State<WebsiteCenterScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  Map<String, dynamic> _webData = {};

  @override
  void initState() {
    super.initState();
    _loadWebData();
  }

  Future<void> _loadWebData() async {
    final data = await _api.fetchWebsiteOverview();
    if (mounted) {
      setState(() {
        _webData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_webData.isEmpty) {
      return NexusEmptyState(
        title: 'Website Analytics Offline',
        description: 'DNS zone records, SSL metrics, and Cloudflare CDN analytics integrations are disconnected.',
        icon: Icons.web_outlined,
        actionLabel: 'Connect Cloudflare Registry',
        onAction: _loadWebData,
      );
    }

    final cloudflare = _webData['cloudflare'] as Map<String, dynamic>? ?? {};
    final domains = _webData['domains'] as List<dynamic>? ?? [];
    final dnsRecords = _webData['cloudflare_dns'] as List<dynamic>? ?? [];

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
                  Text('INTEGRATIONS & WEBSITES', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text('Cloudflare DNS proxy, edge caching analytics, and external integration logs.', style: theme.textTheme.bodyMedium),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadWebData,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reload Edge'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: borderColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // KPI Cards
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Cloudflare Uniques (24h)',
                  value: '${cloudflare['visitors_24h'] ?? 0} hosts',
                  subtitle: 'Global unique visits logged',
                  icon: Icons.language_outlined,
                  iconColor: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  title: 'Edge Bandwidth Served',
                  value: '${cloudflare['bandwidth_gb_24h'] ?? 0.0} GB',
                  subtitle: 'Served via Cloudflare Edge Cache',
                  icon: Icons.cloud_done_outlined,
                  iconColor: NexusTheme.success,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  title: 'SSL Security Handshake',
                  value: cloudflare['ssl_status'] ?? 'N/A',
                  subtitle: cloudflare['ssl_issuer'] ?? 'Cloudflare CA',
                  icon: Icons.verified_user_outlined,
                  iconColor: NexusTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: DNS Registry
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cloudflare DNS Zone Records', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      const Text('Cloud DNS pointer setups mapped in primary zones.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 24),
                      if (dnsRecords.isEmpty)
                        const Text('No DNS records configured.', style: TextStyle(color: NexusTheme.textMuted))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dnsRecords.length,
                          itemBuilder: (context, index) {
                            final record = dnsRecords[index];
                            final name = record['name'] ?? '';
                            final type = record['type'] ?? 'A';
                            final val = record['value'] ?? '';
                            final proxied = record['proxied'] ?? false;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(type, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(val, style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11, fontFamily: 'JetBrains Mono')),
                                      ],
                                    ),
                                  ),
                                  if (proxied)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                      ),
                                      child: const Text('PROXIED', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Active domain names status checklist
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Domain Registry List', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text('External domains managed by Mobawi.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                      const SizedBox(height: 24),
                      if (domains.isEmpty)
                        const Text('No domains listed.', style: TextStyle(color: NexusTheme.textMuted))
                      else
                        ...domains.map((dom) {
                          final domain = dom['domain'] ?? '';
                          final status = dom['status'] ?? 'INACTIVE';
                          final ssl = dom['ssl'] ?? 'SECURE';

                          final isActive = status == 'ACTIVE';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Icon(Icons.dns_outlined, color: isActive ? NexusTheme.success : NexusTheme.textMuted, size: 20),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(domain, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('SSL Encryption: $ssl', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.check_circle, color: isActive ? NexusTheme.success : Colors.grey, size: 16),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
