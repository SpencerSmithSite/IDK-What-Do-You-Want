// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:rest_chooser/main.dart';

void main() {
  testWidgets('App loads default screen', (WidgetTester tester) async {
    // Build the widget.
    await tester.pumpWidget(const MyApp());

    // Verify we see the default welcome text and buttons.
    expect(find.text('Welcome to Restaurant Chooser!'), findsOneWidget);
    expect(find.text('Choose Random'), findsOneWidget);
    expect(find.text('Help Me Decide'), findsOneWidget);
  });
}
