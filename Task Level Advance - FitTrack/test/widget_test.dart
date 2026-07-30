import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('FitTrack Pro smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const FitTrackApp());
    // Verify the splash screen loads (the app starts on SplashScreen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
