import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_game/main.dart';

void main() {
  testWidgets('Initial app test', (WidgetTester tester) async {
    // Build app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));

    // Verify title text exists
    expect(find.text('Snake Game'), findsOneWidget);
    
    // Verify menu buttons exist
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('High Scores'), findsOneWidget);
    expect(find.text('Instructions'), findsOneWidget);
  });
}