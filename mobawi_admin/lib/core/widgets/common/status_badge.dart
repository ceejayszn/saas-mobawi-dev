import 'package:flutter/material.dart';

enum StatusBadgeType {
  success,
  warning,
  error,
  info,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    switch (type) {
      case StatusBadgeType.success:
        baseColor = const Color(0xFF10B981);
        break;
      case StatusBadgeType.warning:
        baseColor = const Color(0xFFF59E0B);
        break;
      case StatusBadgeType.error:
        baseColor = const Color(0xFFEF4444);
        break;
      case StatusBadgeType.info:
        baseColor = const Color(0xFF3B82F6);
        break;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = outlined
        ? Colors.transparent
        : baseColor.withValues(alpha: isDark ? 0.15 : 0.1);

    final borderColor = baseColor.withValues(alpha: outlined ? 1.0 : 0.3);
    final textColor = baseColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
