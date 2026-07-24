// Smart Login App – Widget Smoke Test
// Verifies that the app boots and the login screen renders key elements.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    // Pump the root widget.
    await tester.pumpWidget(const SmartLoginApp());

    // Pump a frame to allow the initial build (skip pumpAndSettle because
    // the animated background orbController repeats forever and will never
    // "settle").
    await tester.pump(const Duration(milliseconds: 500));

    // The app title should appear somewhere on the login screen.
    expect(find.text('Simple Login Page'), findsWidgets);

    // The sign-in button text should be present (inside GlassCard headline
    // AND inside the CustomButton label).
    expect(find.text('Sign In'), findsWidgets);
  });
}
