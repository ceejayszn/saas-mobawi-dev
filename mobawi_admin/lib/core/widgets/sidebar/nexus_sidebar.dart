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

    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;
    final itemSelectedColor = theme.primaryColor;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 260,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(color: borderSideColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Toggle Button at the top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: isCollapsed ? Alignment.center : Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                size: 20,
                color: textSecondary,
              ),
              onPressed: onToggleCollapse,
            ),
          ),
          const Divider(),

          // Menu Scroll List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildNavItem(context, 'Dashboard', 'god_mode', Icons.grid_view_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Businesses', 'customers', Icons.business_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Users', 'security', Icons.people_outline, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Subscriptions', 'billing', Icons.card_membership_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Reports', 'products', Icons.analytics_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Monitoring', 'command_center', Icons.speed_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Support', 'ai_assistant', Icons.support_agent_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Updates', 'deployments', Icons.system_update_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Integrations', 'website_center', Icons.integration_instructions_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Developer', 'infrastructure', Icons.developer_mode_outlined, itemSelectedColor, textPrimary, textSecondary),
                _buildNavItem(context, 'Settings', 'settings', Icons.settings_outlined, itemSelectedColor, textPrimary, textSecondary),
              ],
            ),
          ),

          // Bottom Section
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildNavItem(context, 'Documentation', 'docs', Icons.menu_book_outlined, itemSelectedColor, textPrimary, textSecondary, onTapOverride: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Documentation is coming soon!')),
                  );
                }),
                _buildNavItem(context, 'Logout', 'logout', Icons.logout_outlined, itemSelectedColor, textPrimary, textSecondary, onTapOverride: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully.')),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    String section,
    IconData icon,
    Color itemSelectedColor,
    Color textPrimary,
    Color textSecondary, {
    VoidCallback? onTapOverride,
  }) {
    final isSelected = activeSection == section;
    return Tooltip(
      message: isCollapsed ? title : '',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: InkWell(
          onTap: onTapOverride ?? () => onSectionChanged(section),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? itemSelectedColor.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? itemSelectedColor.withValues(alpha: 0.2) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? itemSelectedColor : textSecondary,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 13,
                            color: isSelected ? textPrimary : textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
