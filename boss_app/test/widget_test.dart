// Basic widget test for Copy App admin app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:boss_app/main.dart';
import 'package:boss_app/providers/theme_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const CopyApp(),
      ),
    );
    // App should at least render a Scaffold-based widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
