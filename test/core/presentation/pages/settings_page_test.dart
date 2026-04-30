import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/presentation/pages/settings_page.dart';
import 'package:app_prenotazioni/core/providers/theme_provider.dart';
import 'package:app_prenotazioni/features/platforms/presentation/pages/platforms_list_page.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('shows all section headers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Verify all section headers exist
      expect(find.text('Aspetto'), findsOneWidget);
      expect(find.text('Gestione'), findsOneWidget);
      expect(find.text('Dati'), findsOneWidget);
      expect(find.text('Informazioni'), findsOneWidget);
    });

    testWidgets('shows Gestione section between Aspetto and Dati', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find all section headers
      final aspettoFinder = find.text('Aspetto');
      final gestioneFinder = find.text('Gestione');
      final datiFinder = find.text('Dati');

      expect(aspettoFinder, findsOneWidget);
      expect(gestioneFinder, findsOneWidget);
      expect(datiFinder, findsOneWidget);

      // Get the vertical positions of each header
      final aspettoY = tester.getTopLeft(aspettoFinder).dy;
      final gestioneY = tester.getTopLeft(gestioneFinder).dy;
      final datiY = tester.getTopLeft(datiFinder).dy;

      // Verify order: Aspetto < Gestione < Dati
      expect(aspettoY, lessThan(gestioneY));
      expect(gestioneY, lessThan(datiY));
    });

    testWidgets('shows Platforms tile in Gestione section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find 'Piattaforme di prenotazione' text
      expect(find.text('Piattaforme di prenotazione'), findsOneWidget);

      // Find subtitle
      expect(find.text('Gestisci le piattaforme di prenotazione'), findsOneWidget);
    });

    testWidgets('platforms tile has correct key', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find by Key('platforms_tile')
      final platformsTile = find.byKey(const Key('platforms_tile'));
      expect(platformsTile, findsOneWidget);
    });

    testWidgets('tapping Platforms tile navigates to PlatformsListPage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find and tap the platforms tile
      final platformsTile = find.byKey(const Key('platforms_tile'));
      expect(platformsTile, findsOneWidget);

      await tester.tap(platformsTile);
      await tester.pumpAndSettle();

      // Verify navigation to PlatformsListPage
      expect(find.byType(PlatformsListPage), findsOneWidget);
      expect(find.text('Gestione Piattaforme'), findsOneWidget);
    });

    testWidgets('platforms tile has correct icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find the platforms tile
      final platformsTile = find.byKey(const Key('platforms_tile'));
      expect(platformsTile, findsOneWidget);

      // Verify it has an icon (Icons.hotel_outlined or similar)
      final iconFinder = find.descendant(
        of: platformsTile,
        matching: find.byType(Icon),
      );
      expect(iconFinder, findsWidgets);
    });

    testWidgets('platforms tile has trailing chevron', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find the platforms tile
      final platformsTile = tester.widget<ListTile>(find.byKey(const Key('platforms_tile')));

      // Verify trailing is a chevron icon
      expect(platformsTile.trailing, isA<Icon>());
      final trailingIcon = platformsTile.trailing as Icon;
      expect(trailingIcon.icon, Icons.chevron_right);
    });

    testWidgets('shows theme tile in Aspetto section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      expect(find.text('Tema'), findsOneWidget);
      expect(find.byKey(const Key('theme_tile')), findsOneWidget);
    });

    testWidgets('shows backup tile in Dati section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      expect(find.text('Backup e Ripristino'), findsOneWidget);
    });

    testWidgets('shows version info in Informazioni section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      expect(find.text('Versione'), findsOneWidget);
      expect(find.text('Sviluppato con Flutter'), findsOneWidget);
    });
  });
}
