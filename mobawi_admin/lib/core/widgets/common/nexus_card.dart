import 'package:flutter/material.dart';
import '../../theme/nexus_theme.dart';

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isHovered ? NexusTheme.surfaceElevated : NexusTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? NexusTheme.accent : NexusTheme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? NexusTheme.accent.withValues(alpha: 0.08)
                    : Colors.transparent,
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
