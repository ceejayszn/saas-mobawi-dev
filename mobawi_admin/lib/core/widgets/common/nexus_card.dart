import 'package:flutter/material.dart';
import '../../theme/nexus_theme.dart';

/// Theme-aware NexusCard that properly responds to light/dark mode.
class NexusCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const NexusCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<NexusCard> createState() => _NexusCardState();
}

class _NexusCardState extends State<NexusCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseBg = isDark ? NexusTheme.surface : NexusTheme.lightSurface;
    final hoveredBg = isDark ? NexusTheme.surfaceElevated : const Color(0xFFF1F5F9);
    final baseBorder = isDark ? NexusTheme.border : NexusTheme.lightBorder;
    final hoveredBorder = isDark ? NexusTheme.accent : NexusTheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isHovered ? hoveredBg : baseBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered ? hoveredBorder.withValues(alpha: 0.5) : baseBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.2)
                    : Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.03),
                blurRadius: _isHovered ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
