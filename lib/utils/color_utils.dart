import 'package:flutter/material.dart';

class ColorUtils {
  static const List<Color> _userColors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
  ];

  static Color getColorForUser(String username) {
    if (username.isEmpty || username == 'unknown') {
      return Colors.grey;
    }
    
    // Simple hash to map username to a consistent color
    int hash = 0;
    for (int i = 0; i < username.length; i++) {
      hash = username.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    int index = hash.abs() % _userColors.length;
    return _userColors[index];
  }
}
