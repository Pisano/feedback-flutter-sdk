// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:feedback_flutter_sdk_example/main.dart';

void main() {
  testWidgets('Displays example CTAs', (WidgetTester tester) async {
    // Build the example app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the default app bar title and the three action buttons.
    expect(find.text('Plugin example app'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });
}
