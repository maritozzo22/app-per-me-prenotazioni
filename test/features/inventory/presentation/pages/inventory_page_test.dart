import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/inventory/presentation/pages/inventory_page.dart';
import 'package:app_prenotazioni/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';
import 'package:app_prenotazioni/features/inventory/domain/repositories/inventory_repository.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late MockInventoryRepository mockRepo;

  setUp(() {
    mockRepo = MockInventoryRepository();
    when(() => mockRepo.getAllItems()).thenAnswer((_) async => []);
  });

  group('InventoryPage', () {
    testWidgets('shows page title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: InventoryPage(),
          ),
        ),
      );

      expect(find.text('Magazzino'), findsOneWidget);
    });

    testWidgets('shows FAB with correct label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: InventoryPage(),
          ),
        ),
      );

      expect(find.text('Aggiungi Articolo'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows empty state when no items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: InventoryPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Magazzino Vuoto'), findsOneWidget);
    });
  });
}
