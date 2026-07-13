import 'package:flutter_test/flutter_test.dart';
import 'package:mobawi_admin/main.dart';

void main() {
  testWidgets('Core App Sanity check', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MobawiNexusApp());
  });
}
