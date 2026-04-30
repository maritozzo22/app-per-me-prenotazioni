import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/paginated_result.dart';

void main() {
  group('PaginatedResult', () {
    group('hasMore', () {
      test('should return true when there are more pages available', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: ['item1', 'item2'],
          totalCount: 100,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.hasMore, isTrue);
      });

      test('should return true on middle page', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: ['item1', 'item2'],
          totalCount: 100,
          currentPage: 4,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.hasMore, isTrue);
      });

      test('should return false when on last page with exact page count', () {
        // Arrange: 100 items, 20 per page = 5 pages
        const result = PaginatedResult<String>(
          items: ['item1', 'item2'],
          totalCount: 100,
          currentPage: 5,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.hasMore, isFalse);
      });

      test('should return false when on last page with partial page', () {
        // Arrange: 95 items, 20 per page = 5 pages (last page has 15 items)
        // Page 5 of 5: 5 * 20 = 100 >= 95, so hasMore = false
        const result = PaginatedResult<String>(
          items: ['item1'],
          totalCount: 95,
          currentPage: 5,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.hasMore, isFalse);
      });

      test('should return false when all items fit on current page', () {
        // Arrange: 5 items total, on page 1 with size 20
        const result = PaginatedResult<String>(
          items: ['item1', 'item2', 'item3', 'item4', 'item5'],
          totalCount: 5,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.hasMore, isFalse);
      });
    });

    group('totalPages', () {
      test('should calculate correct total pages for exact division', () {
        // Arrange: 100 items / 20 per page = 5 pages
        const result = PaginatedResult<String>(
          items: [],
          totalCount: 100,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.totalPages, 5);
      });

      test('should calculate correct total pages for partial last page', () {
        // Arrange: 95 items / 20 per page = 4.75 -> 5 pages
        const result = PaginatedResult<String>(
          items: [],
          totalCount: 95,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.totalPages, 5);
      });

      test('should return 0 pages for empty result', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: [],
          totalCount: 0,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.totalPages, 0);
      });

      test('should return 1 page for single item', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: ['only-item'],
          totalCount: 1,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.totalPages, 1);
      });

      test('should handle small page sizes correctly', () {
        // Arrange: 7 items / 2 per page = 3.5 -> 4 pages
        const result = PaginatedResult<String>(
          items: [],
          totalCount: 7,
          currentPage: 1,
          pageSize: 2,
        );

        // Act & Assert
        expect(result.totalPages, 4);
      });
    });

    group('edge cases', () {
      test('should handle empty items list correctly', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: [],
          totalCount: 0,
          currentPage: 1,
          pageSize: 20,
        );

        // Act & Assert
        expect(result.items, isEmpty);
        expect(result.totalCount, 0);
        expect(result.hasMore, isFalse);
        expect(result.totalPages, 0);
      });

      test('should work with different generic types', () {
        // Arrange
        const intResult = PaginatedResult<int>(
          items: [1, 2, 3],
          totalCount: 30,
          currentPage: 1,
          pageSize: 10,
        );

        // Act & Assert
        expect(intResult.items, equals([1, 2, 3]));
        expect(intResult.hasMore, isTrue);
      });

      test('should handle page 1 of 1 correctly', () {
        // Arrange: Single page with all items
        const result = PaginatedResult<String>(
          items: ['a', 'b', 'c'],
          totalCount: 3,
          currentPage: 1,
          pageSize: 10,
        );

        // Act & Assert
        expect(result.currentPage, 1);
        expect(result.totalPages, 1);
        expect(result.hasMore, isFalse);
      });

      test('should handle pageSize equal to totalCount', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: ['a', 'b', 'c'],
          totalCount: 3,
          currentPage: 1,
          pageSize: 3,
        );

        // Act & Assert
        expect(result.totalPages, 1);
        expect(result.hasMore, isFalse);
      });

      test('should handle pageSize larger than totalCount', () {
        // Arrange
        const result = PaginatedResult<String>(
          items: ['a', 'b'],
          totalCount: 2,
          currentPage: 1,
          pageSize: 10,
        );

        // Act & Assert
        expect(result.totalPages, 1);
        expect(result.hasMore, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const result1 = PaginatedResult<String>(
          items: ['a', 'b'],
          totalCount: 10,
          currentPage: 1,
          pageSize: 5,
        );
        const result2 = PaginatedResult<String>(
          items: ['a', 'b'],
          totalCount: 10,
          currentPage: 1,
          pageSize: 5,
        );

        // Act & Assert
        expect(result1, equals(result2));
      });

      test('should not be equal when items differ', () {
        // Arrange
        const result1 = PaginatedResult<String>(
          items: ['a', 'b'],
          totalCount: 10,
          currentPage: 1,
          pageSize: 5,
        );
        const result2 = PaginatedResult<String>(
          items: ['a', 'c'],
          totalCount: 10,
          currentPage: 1,
          pageSize: 5,
        );

        // Act & Assert
        expect(result1 == result2, isFalse);
      });

      test('should not be equal when metadata differs', () {
        // Arrange
        const result1 = PaginatedResult<String>(
          items: ['a'],
          totalCount: 10,
          currentPage: 1,
          pageSize: 5,
        );
        const result2 = PaginatedResult<String>(
          items: ['a'],
          totalCount: 20,
          currentPage: 1,
          pageSize: 5,
        );

        // Act & Assert
        expect(result1 == result2, isFalse);
      });
    });
  });
}
