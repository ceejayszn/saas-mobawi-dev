import 'package:flutter/material.dart';
import '../../theme/nexus_theme.dart';

class NexusSidebar extends StatelessWidget {
  final String activeSection;
  final Function(String) onSectionChanged;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const NexusSidebar({
    super.key,
    required this.activeSection,
    required this.onSectionChanged,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? NexusTheme.surface : NexusTheme.lightSurface;
    final borderColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;
    final textMuted = isDark ? NexusTheme.textMuted : const Color(0xFF94A3B8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: isCollapsed ? 68 : 240,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo / Brand ──────────────────────────
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 14 : 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                // Mobawi Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mobawi Nexus',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'SaaS Command Center',
                          style: TextStyle(color: textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  // Collapse toggle
                  InkWell(
                    onTap: onToggleCollapse,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.unfold_less_rounded, size: 16, color: textMuted),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // ── Notifications item ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: _navItem(
              context,
              label: 'Updates',
              icon: Icons.notifications_none_outlined,
              section: 'updates',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              badge: '2',
            ),
          ),

          Divider(height: 1, color: borderColor),

          // ── Main Navigation ───────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _navItem(context, label: 'Dashboard', icon: Icons.grid_view_rounded, section: 'god_mode', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Businesses', icon: Icons.business_outlined, section: 'customers', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Monitoring', icon: Icons.speed_outlined, section: 'command_center', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Products', icon: Icons.inventory_2_outlined, section: 'products', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Billing', icon: Icons.card_membership_outlined, section: 'billing', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Security', icon: Icons.shield_outlined, section: 'security', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Deployments', icon: Icons.rocket_launch_outlined, section: 'deployments', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'AI Center', icon: Icons.psychology_outlined, section: 'ai_center', textPrimary: textPrimary, textSecondary: textSecondary),

                  const SizedBox(height: 16),

                  // PLATFORMS section label
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(
                        'PLATFORMS',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                  _navItem(context, label: 'AI Assistant', icon: Icons.chat_bubble_outline_rounded, section: 'ai_assistant', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Integrations', icon: Icons.integration_instructions_outlined, section: 'website_center', textPrimary: textPrimary, textSecondary: textSecondary),
                  _navItem(context, label: 'Developer', icon: Icons.code_rounded, section: 'infrastructure', textPrimary: textPrimary, textSecondary: textSecondary),
                ],
              ),
            ),
          ),

          // ── Bottom Pinned ─────────────────────────
          Divider(height: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              children: [
                _navItem(context, label: 'Settings', icon: Icons.settings_outlined, section: 'settings', textPrimary: textPrimary, textSecondary: textSecondary),
                _navItem(context, label: 'Documentation', icon: Icons.menu_book_outlined, section: 'docs', textPrimary: textPrimary, textSecondary: textSecondary, onTapOverride: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Documentation — coming soon!')),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String section,
    required Color textPrimary,
    required Color textSecondary,
    String? badge,
    VoidCallback? onTapOverride,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = activeSection == section;
    final selectedBg = isDark
        ? theme.primaryColor.withValues(alpha: 0.12)
        : theme.primaryColor.withValues(alpha: 0.08);
    final selectedIcon = theme.primaryColor;

    return Tooltip(
      message: isCollapsed ? label : '',
      preferBelow: false,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapOverride ?? () => onSectionChanged(section),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? selectedIcon : textSecondary,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? textPrimary : textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
