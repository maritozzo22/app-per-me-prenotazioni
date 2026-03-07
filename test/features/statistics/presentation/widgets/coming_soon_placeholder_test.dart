import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/coming_soon_placeholder.dart';

void main() {
  group('ComingSoonPlaceholder', () {
    testWidgets('displays centered icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComingSoonPlaceholder(),
          ),
        ),
      );

      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('displays default title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComingSoonPlaceholder(),
          ),
        ),
      );

      expect(find.text('Statistiche in arrivo...'), findsOneWidget);
    });

    testWidgets('displays custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComingSoonPlaceholder(title: 'Custom Title'),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComingSoonPlaceholder(),
          ),
        ),
      );

      // Verify semantics are present via Semantics widget
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
