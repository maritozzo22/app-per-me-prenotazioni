import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:sqflite/sqflite.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

class FakeDatabase extends Fake implements Database {}

void main() {
  late MockInventoryRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockInventoryRepository();

    // Register fallback values for mocktail
    registerFallbackValue(
      InventoryItem(
        id: 'test-id',
        name: 'Test Item',
        category: InventoryCategory.alimentari,
        quantity: 1,
        createdAt: DateTime.now(),
      ),
    );

    container = ProviderContainer(
      overrides: [
        inventoryRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('InventoryNotifier', () {
    final now = DateTime(2026, 4, 12);

    test('loads items on build', () async {
      final items = [
        InventoryItem(
          id: '1',
          name: 'Pasta',
          category: InventoryCategory.alimentari,
          quantity: 5,
          createdAt: now,
        ),
      ];

      when(() => mockRepo.getAllItems()).thenAnswer((_) async => items);

      final notifier = container.read(inventoryProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(inventoryProvider);
      expect(state.value, equals(items));
    });

    test('addItem adds item and refreshes', () async {
      when(() => mockRepo.getAllItems()).thenAnswer((_) async => []);
      when(() => mockRepo.addItem(any())).thenAnswer((_) async {});

      final notifier = container.read(inventoryProvider.notifier);
      await notifier.addItem(
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
      );

      verify(() => mockRepo.addItem(any())).called(1);
      verify(() => mockRepo.getAllItems()).called(greaterThanOrEqualTo(2));
    });

    test('updateItem updates item and refreshes', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        createdAt: now,
      );

      when(() => mockRepo.getAllItems()).thenAnswer((_) async => []);
      when(() => mockRepo.updateItem(any())).thenAnswer((_) async {});

      final notifier = container.read(inventoryProvider.notifier);
      await notifier.updateItem(item);

      verify(() => mockRepo.updateItem(item)).called(1);
      verify(() => mockRepo.getAllItems()).called(greaterThanOrEqualTo(2));
    });

    test('deleteItem deletes item and refreshes', () async {
      when(() => mockRepo.getAllItems()).thenAnswer((_) async => []);
      when(() => mockRepo.getItemById(any())).thenAnswer((_) async => null); // Stub getItemById to return null (item not found)
      when(() => mockRepo.deleteItem('1')).thenAnswer((_) async {});

      final notifier = container.read(inventoryProvider.notifier);
      await notifier.deleteItem('1');

      verify(() => mockRepo.deleteItem('1')).called(1);
      verify(() => mockRepo.getAllItems()).called(greaterThanOrEqualTo(2));
    });

    test('addMovement records movement', () async {
      when(() => mockRepo.getAllItems()).thenAnswer((_) async => []);
      when(() => mockRepo.addMovement('1', 5)).thenAnswer((_) async {});

      final notifier = container.read(inventoryProvider.notifier);
      await notifier.addMovement('1', 5);

      verify(() => mockRepo.addMovement('1', 5)).called(1);
    });

    test('refresh reloads items', () async {
      when(() => mockRepo.getAllItems()).thenAnswer((_) async => []);

      final notifier = container.read(inventoryProvider.notifier);
      await notifier.refresh();

      verify(() => mockRepo.getAllItems()).called(greaterThanOrEqualTo(1));
    });
  });

  group('filteredItemsProvider', () {
    final now = DateTime(2026, 4, 12);

    test('returns all items when category is null', () async {
      final items = [
        InventoryItem(
          id: '1',
          name: 'Pasta',
          category: InventoryCategory.alimentari,
          quantity: 5,
          createdAt: now,
        ),
        InventoryItem(
          id: '2',
          name: 'Asciugamani',
          category: InventoryCategory.tessili,
          quantity: 10,
          createdAt: now,
        ),
      ];

      when(() => mockRepo.getAllItems()).thenAnswer((_) async => items);

      // Trigger inventoryProvider to load
      container.read(inventoryProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      container.read(selectedCategoryProvider.notifier).state = null;
      final filtered = container.read(filteredItemsProvider);

      expect(filtered.length, equals(2));
    });

    test('filters by selected category', () async {
      final items = [
        InventoryItem(
          id: '1',
          name: 'Pasta',
          category: InventoryCategory.alimentari,
          quantity: 5,
          createdAt: now,
        ),
        InventoryItem(
          id: '2',
          name: 'Asciugamani',
          category: InventoryCategory.tessili,
          quantity: 10,
          createdAt: now,
        ),
      ];

      when(() => mockRepo.getAllItems()).thenAnswer((_) async => items);

      // Trigger inventoryProvider to load
      container.read(inventoryProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      container.read(selectedCategoryProvider.notifier).state =
          InventoryCategory.alimentari;
      final filtered = container.read(filteredItemsProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.name, equals('Pasta'));
    });
  });
}
