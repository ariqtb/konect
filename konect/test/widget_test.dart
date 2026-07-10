// Basic smoke test for KonectApp — verifies the app boots and shows the login page.

import 'package:flutter_test/flutter_test.dart';
import 'package:konect/app.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KonectApp());

    // Verify that login screen text is displayed.
    expect(find.text('KONECT'), findsWidgets);
  });
}
