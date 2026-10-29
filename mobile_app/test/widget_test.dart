import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app.dart';

void main() {
  testWidgets('Splash Screen displays MessMind branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MessMindApp());

    expect(find.text('MessMind'), findsOneWidget);
    expect(find.text('Smarter Meals. Less Waste. Better Planning.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });
}
