/// A generic container for paginated results with metadata.
///
/// This class encapsulates the result of a paginated query, providing
/// both the items for the current page and metadata about the total
/// result set for pagination UI controls.
class PaginatedResult<T> {
  /// The items for the current page.
  final List<T> items;

  /// The total count of items across all pages.
  final int totalCount;

  /// The current page number (1-indexed).
  final int currentPage;

  /// The number of items per page.
  final int pageSize;

  /// Creates a new PaginatedResult.
  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  /// Returns true if there are more pages available after the current one.
  ///
  /// Calculation: currentPage * pageSize < totalCount
  /// Example: Page 1 of 100 items with 20 per page -> 1 * 20 < 100 = true
  /// Example: Page 5 of 100 items with 20 per page -> 5 * 20 < 100 = false
  bool get hasMore => (currentPage * pageSize) < totalCount;

  /// Returns the total number of pages.
  ///
  /// Uses ceiling division to handle partial last pages.
  /// Example: 100 items / 20 per page = 5 pages
  /// Example: 95 items / 20 per page = 5 pages (last page has 15 items)
  int get totalPages => (totalCount / pageSize).ceil();

  /// Creates a copy of this result with optionally updated fields.
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? currentPage,
    int? pageSize,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, totalCount: $totalCount, '
        'currentPage: $currentPage, pageSize: $pageSize, hasMore: $hasMore, '
        'totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginatedResult<T>) return false;
    // Compare lists by content
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return totalCount == other.totalCount &&
        currentPage == other.currentPage &&
        pageSize == other.pageSize;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        totalCount,
        currentPage,
        pageSize,
      );
}
