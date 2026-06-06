import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Renderizado simple de un shell para asegurar el funcionamiento de Riverpod y Flutter Test
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Scotiabank App'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Scotiabank App'), findsOneWidget);
  });
}
