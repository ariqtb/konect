// Basic smoke test for KonectApp — verifies the app boots and shows the login page.

import 'package:flutter_test/flutter_test.dart';

import 'package:konect/app.dart';

void main() {
  testWidgets('KonectApp builds and shows login page', (WidgetTester tester) async {
    await tester.pumpWidget(const KonectApp());
    // First frame: AuthBloc emits AuthCheckRequested, repository returns null
    // → AuthUnauthenticated. The login screen must be the initial route.
    expect(find.text('KONECT'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Belum punya akun? Daftar'), findsOneWidget);
  });
}
