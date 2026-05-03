/// Inventory item categories (fixed 3 types per D-01)
enum InventoryCategory {
  /// Food items with expiry dates
  alimentari,
  /// Linens, towels, sheets (quantity-managed)
  tessili,
  /// Other household items
  altro,
}

/// Extension for inventory category properties
extension InventoryCategoryX on InventoryCategory {
  /// Italian display label
  String get label {
    return switch (this) {
      InventoryCategory.alimentari => 'Alimentari',
      InventoryCategory.tessili => 'Tessili',
      InventoryCategory.altro => 'Altro',
    };
  }

  /// Whether this category requires expiry date (only Alimentari per D-06)
  bool get hasExpiryDate => this == InventoryCategory.alimentari;

  /// Whether this category supports quantity tracking (all except notes-only items)
  bool get hasQuantity => true;
}
