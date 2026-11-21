import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CoCircle App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CoCircle – The Group Life Assistant'),
          ),
        ),
      ),
    );

    expect(find.text('CoCircle – The Group Life Assistant'), findsOneWidget);
  });
}
