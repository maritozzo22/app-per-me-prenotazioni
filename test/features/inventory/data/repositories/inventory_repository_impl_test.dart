import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:app_prenotazioni/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_item_model.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_movement_model.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

class MockInventoryLocalDataSource extends Mock
    implements InventoryLocalDataSource {}

void main() {
  late InventoryRepositoryImpl repository;
  late MockInventoryLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockInventoryLocalDataSource();
    repository = InventoryRepositoryImpl(mockDataSource);

    // Register fallback values for mocktail
    registerFallbackValue(
      InventoryItemModel(
        id: '0',
        name: '',
        category: 'altro',
        quantity: 0,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    registerFallbackValue(
      InventoryMovementModel(
        id: '0',
        itemId: '0',
        delta: 0,
        date: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  });

  group('InventoryRepositoryImpl', () {
    final now = DateTime(2026, 4, 12);

    test('getAllItems returns entities', () async {
      final model = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        createdAt: now.toIso8601String(),
      );

      when(() => mockDataSource.getAllItems())
          .thenAnswer((_) async => [model]);

      final items = await repository.getAllItems();

      expect(items.length, equals(1));
      expect(items.first.name, equals('Pasta'));
    });

    test('addItem saves to data source', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        createdAt: now,
      );

      when(() => mockDataSource.addItem(any()))
          .thenAnswer((_) async {});

      await repository.addItem(item);

      verify(() => mockDataSource.addItem(any())).called(1);
    });

    test('addMovement updates quantity with positive delta', () async {
      final itemModel = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        createdAt: now.toIso8601String(),
      );

      when(() => mockDataSource.getItemById('1'))
          .thenAnswer((_) async => itemModel);
      when(() => mockDataSource.addMovement(any(), 8))
          .thenAnswer((_) async {});

      await repository.addMovement('1', 3); // 5 + 3 = 8

      verify(() => mockDataSource.addMovement(any(), 8)).called(1);
    });

    test('addMovement handles negative delta per D-10', () async {
      final itemModel = InventoryItemModel(
        id: '1',
        name: 'Asciugamani',
        category: 'tessili',
        quantity: 10,
        createdAt: now.toIso8601String(),
      );

      when(() => mockDataSource.getItemById('1'))
          .thenAnswer((_) async => itemModel);
      when(() => mockDataSource.addMovement(any(), 7))
          .thenAnswer((_) async {});

      await repository.addMovement('1', -3); // 10 - 3 = 7

      verify(() => mockDataSource.addMovement(any(), 7)).called(1);
    });

    test('addMovement throws if item not found', () async {
      when(() => mockDataSource.getItemById('1'))
          .thenAnswer((_) async => null);

      expect(
        () => repository.addMovement('1', 5),
        throwsA(isA<Exception>()),
      );
    });
  });
}
