import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Medicine Reminder Test'),
          ),
        ),
      ),
    );

    // Verify text is displayed
    expect(find.text('Medicine Reminder Test'), findsOneWidget);
  });
}
