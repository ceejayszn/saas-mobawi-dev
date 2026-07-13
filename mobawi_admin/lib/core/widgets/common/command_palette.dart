import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/nexus_theme.dart';

class CommandPalette extends StatefulWidget {
  final Function(String) onActionSelected;

  const CommandPalette({
    super.key,
    required this.onActionSelected,
  });

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _allCommands = [
    {
      'title': 'Deploy Product',
      'subtitle': 'Trigger a new pipeline build',
      'icon': Icons.rocket_launch_outlined,
      'category': 'Deployments',
      'action': 'deploy'
    },
    {
      'title': 'Restart API Service',
      'subtitle': 'Perform zero-downtime hot reload',
      'icon': Icons.restart_alt_outlined,
      'category': 'Infrastructure',
      'action': 'restart_api'
    },
    {
      'title': 'Backup Database Now',
      'subtitle': 'Create immediate point-in-time PostgreSQL backup',
      'icon': Icons.backup_outlined,
      'category': 'Infrastructure',
      'action': 'backup_db'
    },
    {
      'title': 'Generate License Key',
      'subtitle': 'Create new offline or subscription license key',
      'icon': Icons.key_outlined,
      'category': 'Licensing',
      'action': 'gen_license'
    },
    {
      'title': 'Add New Customer',
      'subtitle': 'Provision a new customer company workspace',
      'icon': Icons.business_outlined,
      'category': 'Customers',
      'action': 'add_customer'
    },
    {
      'title': 'Invite Employee',
      'subtitle': 'Add a new member to the Founder organization',
      'icon': Icons.person_add_outlined,
      'category': 'Employees',
      'action': 'invite_employee'
    },
    {
      'title': 'Inspect Live Logs',
      'subtitle': 'Stream stdout logs directly from Railway API',
      'icon': Icons.terminal_outlined,
      'category': 'Monitoring',
      'action': 'view_logs'
    },
    {
      'title': 'Run Database Migration',
      'subtitle': 'Apply pending SQL schema migrations',
      'icon': Icons.dns_outlined,
      'category': 'Engineering',
      'action': 'run_migrations'
    },
  ];

  List<Map<String, dynamic>> _filteredCommands = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredCommands = List.from(_allCommands);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommands = _allCommands.where((cmd) {
        final title = cmd['title'].toString().toLowerCase();
        final subtitle = cmd['subtitle'].toString().toLowerCase();
        final cat = cmd['category'].toString().toLowerCase();
        return title.contains(query) || subtitle.contains(query) || cat.contains(query);
      }).toList();
      _selectedIndex = 0;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (_filteredCommands.isNotEmpty) {
            _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (_filteredCommands.isNotEmpty) {
            _selectedIndex = (_selectedIndex - 1 + _filteredCommands.length) % _filteredCommands.length;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredCommands.isNotEmpty) {
          _triggerAction(_filteredCommands[_selectedIndex]['action']);
        }
      }
    }
  }

  void _triggerAction(String action) {
    widget.onActionSelected(action);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        child: Container(
          width: 600,
          decoration: BoxDecoration(
            color: NexusTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NexusTheme.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: NexusTheme.textSecondary),
                    hintText: 'Search actions, services, customers...',
                    hintStyle: TextStyle(color: NexusTheme.textMuted),
                    filled: true,
                    fillColor: NexusTheme.background,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: NexusTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: NexusTheme.accent),
                    ),
                  ),
                ),
              ),
              const Divider(),
              // Command list
              Flexible(
                child: _filteredCommands.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No matching commands found',
                          style: TextStyle(color: NexusTheme.textMuted),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredCommands.length,
                        itemBuilder: (context, index) {
                          final cmd = _filteredCommands[index];
                          final isSelected = index == _selectedIndex;
                          return InkWell(
                            onTap: () => _triggerAction(cmd['action']),
                            onHover: (hovered) {
                              if (hovered) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              }
                            },
                            child: Container(
                              color: isSelected ? NexusTheme.surfaceElevated : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(
                                    cmd['icon'] as IconData,
                                    color: isSelected ? NexusTheme.accent : NexusTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cmd['title'] as String,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: isSelected ? NexusTheme.accent : NexusTheme.textPrimary,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cmd['subtitle'] as String,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isSelected ? NexusTheme.textSecondary : NexusTheme.textMuted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: NexusTheme.background,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: NexusTheme.border),
                                    ),
                                    child: Text(
                                      cmd['category'] as String,
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            fontSize: 10,
                                            color: NexusTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              // Keyboard guides footer
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Use ↑↓ to navigate, Enter to select, Esc to close',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 10,
                            color: NexusTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
