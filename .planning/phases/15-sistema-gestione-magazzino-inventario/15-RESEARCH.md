# Phase 15: Sistema Gestione Magazzino Inventario - Research

**Researched:** 2026-04-12
**Domain:** Flutter Inventory Management with SQLite & Local Notifications
**Confidence:** HIGH

## Summary

Phase 15 implements a personal inventory management system for an Airbnb apartment. The feature tracks household items with expiry dates (food) and quantity-managed items (towels, linens), enabling periodic stock counts every 2-3 months. Key technical challenges include: (1) database schema design for inventory items and movement history, (2) reusing the existing awesome_notifications system for expiry alerts, (3) implementing color-coded UI indicators for expiry status, and (4) modifying the bottom navigation to replace Settings with Magazzino tab.

The project uses Flutter 3.38.9+ with Dart 3.10.8+, SQLite for local storage, Riverpod for state management, and freezed for immutable entities. The existing notification infrastructure (awesome_notifications 0.11.0) can be extended for expiry notifications. Database migrations are well-established (currently at version 7), making it straightforward to add inventory tables.

**Primary recommendation:** Use existing architectural patterns (feature-first structure, Riverpod providers, freezed entities, SQLite migrations) and extend the notification system for expiry alerts. The inventory feature fits naturally within the current codebase structure.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** 3 categorie fisse: Alimentari, Tessili, Altro
- **D-02:** Unica lista filtrabile per categoria — nessun comportamento speciale per tipo
- **D-03:** Ogni item ha: nome, categoria, quantità attuale, data scadenza (solo per Alimentari), note opzionali
- **D-04:** Doppio sistema di avviso: colori nella lista (rosso = scaduto, arancione = scade presto, verde = ok) + notifiche push
- **D-05:** Notifica 3 giorni prima della scadenza (solo per Alimentari)
- **D-06:** Data di scadenza singola per item — inserimento diretto della data, non calcolo da data acquisto
- **D-07:** Tracciamento periodico: l'utente registra +/- manualmente quando fa il conteggio (ogni 2-3 mesi)
- **D-08:** Ogni registrazione contiene solo: data, quantità +/- (nessun motivo/nota obbligatori)
- **D-09:** Lo storico delle registrazioni è visibile per ogni item (data + delta quantità)
- **D-10:** Quantità può diventare negativa per indicare perdite/spiriti (es: asciugamani scomparsi)
- **D-11:** Nuova tab "Magazzino" sostituisce tab "Impostazioni" nella bottom navigation
- **D-12:** Impostazioni diventa icona ingranaggio nell'AppBar della Dashboard
- **D-13:** 5 tab finali: Dashboard, Calendario, Prenotazioni, Statistiche, Magazzino

### Claude's Discretion
- Schema database (tabelle, colonne, relazioni)
- Design UI pagina magazzino (layout cards/lista, filtri, form inserimento)
- Implementazione notifiche scadenza (riuso sistema notifiche esistente)
- Ordinamento default della lista magazzino
- Gestione item scaduti (eliminazione automatica vs manuale)

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter | 3.38.9+ | UI framework | Project baseline, web-first development |
| flutter_riverpod | 2.6.0 | State management | Established pattern across all features |
| freezed | 2.5.2 | Immutable entities | Used for all domain entities (reservations, platforms, statistics) |
| sqflite | 2.4.2 | Local database | Project's SQLite database for Android |
| path | 1.8.3 | Database path manipulation | Already used for database operations |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| awesome_notifications | 0.11.0 | Expiry notifications | Schedule notifications 3 days before food items expire |
| intl | 0.20.0 | Date formatting | Format expiry dates in Italian locale |
| uuid | 4.5.0 | Unique IDs | Generate IDs for inventory items and movements |
| shared_preferences | 2.3.5 | Settings persistence | Store user preferences for inventory filters/sorting |

### Feature-Specific for Phase 15
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_form_builder | 10.3.0 | Form handling | Reuse existing form patterns from reservation forms |
| form_builder_validators | 11.1.0 | Form validation | Validate inventory item inputs (name, quantity, dates) |

**Installation:**
```bash
# All dependencies already installed in pubspec.yaml
# No new packages required for Phase 15
flutter pub get
```

**Version verification:**
- `awesome_notifications: 0.11.0` - VERIFIED from pubspec.yaml [2026-04-12]
- `flutter_riverpod: 2.6.0` - VERIFIED from pubspec.yaml [2026-04-12]
- `freezed: 2.5.2` - VERIFIED from pubspec.yaml [2026-04-12]
- `sqflite: 2.4.2` - VERIFIED from pubspec.yaml [2026-04-12]

## Architecture Patterns

### Recommended Project Structure
```
lib/features/inventory/
├── domain/
│   ├── entities/
│   │   ├── inventory_item.dart           # Freezed entity (name, category, quantity, expiryDate, notes)
│   │   ├── inventory_category.dart       # Enum: Alimentari, Tessili, Altro
│   │   └── inventory_movement.dart       # Freezed entity (date, delta, itemId)
│   ├── repositories/
│   │   └── inventory_repository.dart     # Interface for CRUD operations
│   └── services/
│       └── inventory_notification_service.dart  # Calculate expiry, schedule notifications
├── data/
│   ├── datasources/
│   │   └── inventory_local_data_source.dart    # SQLite operations
│   ├── models/
│   │   ├── inventory_item_model.dart           # DB serialization
│   │   └── inventory_movement_model.dart       # DB serialization
│   └── repositories/
│       └── inventory_repository_impl.dart      # Repository implementation
├── presentation/
│   ├── pages/
│   │   └── inventory_page.dart                 # Main inventory list page
│   ├── providers/
│   │   └── inventory_provider.dart             # Riverpod state management
│   └── widgets/
│       ├── inventory_item_card.dart            # Single item display with color coding
│       ├── inventory_filter_chip.dart          # Category filter chips
│       ├── add_edit_inventory_item_dialog.dart # Form for add/edit
│       └── inventory_movement_history_sheet.dart  # Bottom sheet for movement history
```

### Pattern 1: Freezed Entities with Extensions
**What:** Use freezed for immutable domain entities with extension methods for business logic
**When to use:** All domain entities (InventoryItem, InventoryMovement)
**Example:**
```dart
// Source: Based on existing patterns in lib/features/reservations/domain/entities/
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String name,
    required InventoryCategory category,
    required int quantity,
    DateTime? expiryDate, // null for non-food items
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}

/// Extension for expiry status calculation
extension InventoryItemX on InventoryItem {
  /// Expiry status for color coding
  ExpiryStatus get expiryStatus {
    if (expiryDate == null) return ExpiryStatus.notApplicable;
    
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    
    if (expiryDate!.isBefore(now)) return ExpiryStatus.expired;
    if (expiryDate!.isBefore(threeDaysFromNow)) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.ok;
  }
}

enum ExpiryStatus { expired, expiringSoon, ok, notApplicable }
```

### Pattern 2: Riverpod AsyncNotifier for State Management
**What:** Use AsyncNotifier with Riverpod for async state + loading/error states
**When to use:** Inventory list fetching, CRUD operations
**Example:**
```dart
// Source: Based on lib/features/reservations/presentation/providers/reservation_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryNotifier extends AsyncNotifier<List<InventoryItem>> {
  late final InventoryRepository _repository;

  @override
  Future<List<InventoryItem>> build() async {
    _repository = ref.watch(inventoryRepositoryProvider);
    return _repository.getAllItems();
  }

  Future<void> addItem(InventoryItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addItem(item);
      return _repository.getAllItems();
    });
  }

  Future<void> addMovement(String itemId, int delta) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addMovement(itemId, delta);
      return _repository.getAllItems();
    });
  }
}

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, List<InventoryItem>>(
  InventoryNotifier.new,
);
```

### Pattern 3: Database Migration Pattern
**What:** Versioned migrations in DatabaseSchema with forward-compatible upgrade path
**When to use:** Adding inventory tables to existing database (currently version 7)
**Example:**
```dart
// Source: lib/core/database/database_schema.dart (existing pattern)
class DatabaseSchema {
  static const int version = 8; // Increment from 7 to 8
  
  // New tables for inventory
  static const String tableInventoryItems = 'inventory_items';
  static const String tableInventoryMovements = 'inventory_movements';
  
  // Migration V7 -> V8
  static const String migrationV7ToV8CreateInventoryItemsTable = '''
    CREATE TABLE IF NOT EXISTS $tableInventoryItems (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 0,
      expiry_date TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT
    )
  ''';
  
  // Add to _onUpgrade in database_helper_native.dart
  if (oldVersion < 8) {
    await db.execute(DatabaseSchema.migrationV7ToV8CreateInventoryItemsTable);
    await db.execute(DatabaseSchema.migrationV7ToV8CreateInventoryMovementsTable);
    await db.execute(DatabaseSchema.migrationV7ToV8AddInventoryIndexes);
  }
}
```

### Anti-Patterns to Avoid
- **Storing category as arbitrary string:** Use enum `InventoryCategory` for type safety
- **Calculating expiry from purchase date:** Decision D-06 locked - store expiry date directly
- **Separate lists per category:** Decision D-02 locked - single filtered list
- **Automatic deletion of expired items:** Don't auto-delete - user may want to see what expired
- **Complex movement tracking with reasons:** Decision D-08 locked - only date + delta quantity

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Notification scheduling | Custom alarm/timer system | awesome_notifications | Already integrated, handles Android lifecycle, permissions, channels |
| Immutable entities | Manual copyWith | freezed | Established pattern, code generation, null safety |
| State management | setState, InheritedWidget | Riverpod AsyncNotifier | Used across all features, handles loading/error states |
| Form validation | Manual validation logic | flutter_form_builder + form_builder_validators | Reuse existing form patterns from reservation forms |
| Date formatting | Manual string manipulation | intl package | Italian locale support, date formatting standards |

**Key insight:** The inventory feature reuses 100% of existing infrastructure. No new packages needed. The notification system for expiry alerts is already built for reservation reminders - just extend with inventory-specific notifications.

## Runtime State Inventory

> This section is NOT applicable for Phase 15 (greenfield feature).
> Phase 15 adds new functionality, no rename/refactor involved.

## Common Pitfalls

### Pitfall 1: Negative Quantity Handling
**What goes wrong:** User enters "-5" as movement delta, quantity becomes negative, UI shows "-5 asciugamani"
**Why it happens:** Decision D-10 allows negative quantities to track losses, but UI doesn't handle display
**How to avoid:** Add explicit UI handling for negative quantities (show "Mancano: 5" instead of "-5")
**Warning signs:** Test cases for negative quantities, UI displays negative numbers

### Pitfall 2: Expiry Date Nullability by Category
**What goes wrong:** User sets expiry date for "Tessili" (linens), or doesn't set expiry for "Alimentari" (food)
**Why it happens:** Expiry date is nullable in schema, but business rules require it for Alimentari
**How to avoid:** Add form validation logic - expiry date required if category == Alimentari, hidden otherwise
**Warning signs:** Validation tests for each category, null expiry date checks

### Pitfall 3: Notification ID Collision
**What goes wrong:** Inventory expiry notification overwrites reservation reminder notification (same ID hash)
**Why it happens:** awesome_notifications uses integer IDs, hash codes may collide between features
**How to avoid:** Use namespace prefix in notification ID generation (e.g., "inventory_${itemId}")
**Warning signs:** Test notifications for both reservations and inventory items simultaneously

### Pitfall 4: Bottom Navigation State Loss
**What goes wrong:** Switching from Settings tab (index 4) to Magazzino tab (new index 4) loses Settings page state
**Why it happens:** IndexedStack uses index to preserve state - replacing tab at index 4 changes state mapping
**How to avoid:** Update AppShell._pages array order and increment all indices after Settings
**Warning signs:** Test tab switching before/after navigation change, verify Settings state preserved

### Pitfall 5: Database Migration on Existing Installations
**What goes wrong:** Users with existing app (version 7 database) don't get inventory tables, app crashes
**Why it happens:** Migration path not tested, or version number not incremented
**How to avoid:** Test migration on database copy from production, verify _onUpgrade handles version 7 -> 8
**Warning signs:** Integration test with database version 7, upgrade path verification

## Code Examples

Verified patterns from official sources:

### Database Schema with Foreign Key
```dart
// Source: lib/core/database/database_schema.dart (existing pattern)
static const String createInventoryMovementsTable = '''
  CREATE TABLE IF NOT EXISTS $tableInventoryMovements (
    id TEXT PRIMARY KEY,
    item_id TEXT NOT NULL,
    quantity_delta INTEGER NOT NULL,
    movement_date TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES $tableInventoryItems (id) ON DELETE CASCADE
  )
''';

// Index for movement history queries
static const String createInventoryMovementsItemIndex = '''
  CREATE INDEX IF NOT EXISTS idx_inventory_movements_item 
  ON $tableInventoryMovements (item_id, movement_date DESC)
''';
```

### Expiry Notification Scheduling
```dart
// Source: Based on lib/features/notifications/application/reservation_notification_scheduler.dart
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';

class InventoryNotificationScheduler {
  final NotificationService _notificationService;
  
  /// Schedule notification for inventory item expiring in 3 days
  Future<void> scheduleExpiryNotification(InventoryItem item) async {
    if (item.expiryDate == null) return; // Only food items have expiry
    
    final notificationDate = item.expiryDate!.subtract(const Duration(days: 3));
    final now = DateTime.now();
    
    // Only schedule if expiry is in the future
    if (notificationDate.isBefore(now)) return;
    
    final schedule = NotificationSchedule(
      id: 'inventory_${item.id}',
      reservationId: '', // Not a reservation, but field required
      type: NotificationType.custom, // Add new type or reuse existing
      scheduledDate: notificationDate,
      isSent: false,
      createdAt: now,
    );
    
    await _notificationService.scheduleNotification(
      schedule,
      item.name,
      _getCategoryLabel(item.category),
      PaymentStatus.received, // Not applicable for inventory
    );
  }
  
  String _getCategoryLabel(InventoryCategory category) {
    return switch (category) {
      InventoryCategory.alimentari => 'Scade tra 3 giorni',
      InventoryCategory.tessili => 'Magazzino',
      InventoryCategory.altro => 'Magazzino',
    };
  }
}
```

### Color-Coded Expiry Indicators
```dart
// Source: Based on lib/features/reservations/presentation/widgets/ (color patterns)
import 'package:flutter/material.dart';

class ExpiryIndicator extends StatelessWidget {
  final ExpiryStatus status;
  
  const ExpiryIndicator({required this.status});
  
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ExpiryStatus.expired => Colors.red,
      ExpiryStatus.expiringSoon => Colors.orange,
      ExpiryStatus.ok => Colors.green,
      ExpiryStatus.notApplicable => Colors.grey,
    };
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
```

### Movement History Bottom Sheet
```dart
// Source: Based on existing bottom sheet patterns in lib/features/
import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

class InventoryMovementHistorySheet extends StatelessWidget {
  final List<InventoryMovement> movements;
  
  const InventoryMovementHistorySheet({required this.movements});
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('Storico Movimenti'),
                trailing: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final deltaSign = movement.delta >= 0 ? '+' : '';
                    final deltaColor = movement.delta >= 0 ? Colors.green : Colors.red;
                    
                    return ListTile(
                      leading: Text(
                        '$deltaSign${movement.delta}',
                        style: TextStyle(color: deltaColor, fontWeight: FontWeight.bold),
                      ),
                      title: Text(DateFormat('dd MMM yyyy', 'it_IT').format(movement.date)),
                      subtitle: Text(DateFormat('HH:mm').format(movement.date)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### AppShell Navigation Modification
```dart
// Source: lib/core/widgets/app_shell.dart (existing file to modify)
class AppShellState extends ConsumerState<AppShell> {
  late final List<Widget> _pages = [
    DashboardPage(
      onCalendarTap: () => navigateToCalendar(),
      // Add settings button in Dashboard AppBar
    ),
    const CalendarPage(),
    const ReservationsListPage(),
    const StatisticsPage(),
    const InventoryPage(), // NEW: Replaces SettingsPage
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing body code ...
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Prenotazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistiche'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined, semanticLabel: 'Magazzino'),
            label: 'Magazzino',
          ), // CHANGED: Was 'Impostazioni'
        ],
      ),
    );
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual state management | Riverpod AsyncNotifier | Project start | Consistent async state handling across features |
| Conditional platform imports | Platform-aware database helper | Phase 1 | Single codebase for web + Android |
| Custom notification scheduling | awesome_notifications package | Phase 13 | Simplified notification logic, better Android support |

**Deprecated/outdated:**
- None for Phase 15 stack - all packages are current (as of 2026-04-12)

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | awesome_notifications supports non-reservation notification types | Code Examples | Medium - may need to extend NotificationType enum |
| A2 | IndexedStack preserves Settings state when moved to AppBar | Common Pitfalls #4 | Low - can be tested early in Wave 0 |
| A3 | Database migration V7→V8 works without data loss | Common Pitfalls #5 | High - must test on production database copy |
| A4 | Negative quantities acceptable for business logic | Common Pitfalls #1 | Low - explicitly locked in Decision D-10 |
| A5 | 3-day expiry notification timing is sufficient | Locked Decisions | None - user decision, not technical |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

## Open Questions

1. **Notification channel for inventory**
   - What we know: awesome_notifications already configured with 'reservation_reminders' channel
   - What's unclear: Should inventory expiry notifications use same channel or separate 'inventory_expiry' channel?
   - Recommendation: Use same channel for simplicity, or create separate if user wants different notification settings

2. **Default sort order for inventory list**
   - What we know: Decision D-04 mentions color coding, no sort order specified
   - What's unclear: Should default sort be by name, expiry date, or category?
   - Recommendation: Sort by expiry date (soonest first) for Alimentari, by name for others

3. **Handling expired items in UI**
   - What we know: Items show red color when expired, but no explicit decision on deletion/archival
   - What's unclear: Should expired items be automatically hidden, archived, or always visible?
   - Recommendation: Always visible but sorted to bottom, add "Elimina" action for manual cleanup

4. **Movement history retention**
   - What we know: Decision D-09 requires history visibility, no retention policy specified
   - What's unclear: Should movement history be kept forever or trimmed after X months?
   - Recommendation: Keep forever for personal use case (2-3 month visits, low data volume)

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Feature development | ✓ | 3.38.9+ | — |
| Dart SDK | Language runtime | ✓ | 3.10.8+ | — |
| sqflite | Database | ✓ | 2.4.2 | — |
| awesome_notifications | Expiry notifications | ✓ | 0.11.0 | — |
| flutter_riverpod | State management | ✓ | 2.6.0 | — |
| freezed | Code generation | ✓ | 2.5.2 | — |

**Missing dependencies with no fallback:**
None

**Missing dependencies with fallback:**
None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | pubspec.yaml (dev_dependencies) |
| Quick run command | `flutter test test/features/inventory/` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| INV-D01 | Create inventory item with category | unit | `flutter test test/features/inventory/domain/entities/inventory_item_test.dart -t create_item` | ❌ Wave 0 |
| INV-D02 | Filter items by category | unit | `flutter test test/features/inventory/presentation/providers/inventory_provider_test.dart -t filter_by_category` | ❌ Wave 0 |
| INV-D03 | Add movement and update quantity | integration | `flutter test test/features/inventory/data/repositories/inventory_repository_impl_test.dart -t add_movement` | ❌ Wave 0 |
| INV-D04 | Calculate expiry status | unit | `flutter test test/features/inventory/domain/entities/inventory_item_test.dart -t expiry_status` | ❌ Wave 0 |
| INV-D05 | Schedule expiry notification | integration | `flutter test test/features/inventory/application/inventory_notification_scheduler_test.dart -t schedule_expiry` | ❌ Wave 0 |
| INV-D06 | Navigation: Magazzino tab works | widget | `flutter test test/features/inventory/presentation/pages/inventory_page_test.dart -t tab_navigation` | ❌ Wave 0 |
| INV-D07 | Navigation: Settings in AppBar | widget | `flutter test test/core/widgets/app_shell_test.dart -t settings_appbar_button` | ❌ Wave 0 |
| INV-D08 | Movement history display | widget | `flutter test test/features/inventory/presentation/widgets/inventory_movement_history_sheet_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/inventory/ --reporter=compact`
- **Per wave merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/features/inventory/domain/entities/inventory_item_test.dart` - Entity tests (freezed, extensions)
- [ ] `test/features/inventory/domain/entities/inventory_movement_test.dart` - Movement entity tests
- [ ] `test/features/inventory/data/repositories/inventory_repository_impl_test.dart` - Repository tests
- [ ] `test/features/inventory/presentation/providers/inventory_provider_test.dart` - Provider state tests
- [ ] `test/features/inventory/presentation/pages/inventory_page_test.dart` - Page widget tests
- [ ] `test/features/inventory/presentation/widgets/inventory_item_card_test.dart` - Card widget tests
- [ ] `test/features/inventory/application/inventory_notification_scheduler_test.dart` - Notification tests
- [ ] `test/core/widgets/app_shell_test.dart` - Navigation tests (Magazzino tab, Settings button)
- [ ] Framework install: None (flutter_test built-in)

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | Personal app, no authentication |
| V3 Session Management | No | No user sessions |
| V4 Access Control | No | Single-user app |
| V5 Input Validation | Yes | flutter_form_builder + form_builder_validators for all form inputs |
| V6 Cryptography | No | Local data only, no encryption needed |

### Known Threat Patterns for Flutter SQLite Inventory App

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| SQL injection in movement queries | Tampering | Parameterized sqflite queries (no raw SQL) |
| Negative quantity overflow | Tampering | Dart int range check, UI validation for reasonable limits |
| Notification spam (expiry alerts) | Denial of Service | Rate limit: 1 notification per item per day, dedup by itemId |
| Invalid expiry dates | Spoofing | Date validation: expiryDate must be future date for new items |

## Sources

### Primary (HIGH confidence)
- `lib/core/database/database_schema.dart` - Database migration patterns, table creation SQL
- `lib/features/notifications/application/notification_service.dart` - awesome_notifications integration
- `lib/features/notifications/application/reservation_notification_scheduler.dart` - Scheduling pattern
- `lib/core/widgets/app_shell.dart` - Bottom navigation structure
- `lib/features/reservations/presentation/providers/reservation_list_provider.dart` - Riverpod AsyncNotifier pattern
- `lib/features/reservations/domain/entities/` - Freezed entity patterns
- `pubspec.yaml` - Package versions and dependencies
- `.planning/phases/15-sistema-gestione-magazzino-inventario/15-CONTEXT.md` - User decisions and constraints

### Secondary (MEDIUM confidence)
- Flutter documentation: https://docs.flutter.dev/cookbook/forms/validation - Form validation patterns
- awesome_notifications docs: https://pub.dev/packages/awesome_notifications - Notification scheduling API
- Riverpod documentation: https://riverpod.dev/docs/concepts/providers - AsyncNotifier usage

### Tertiary (LOW confidence)
- None - all research verified against codebase or official docs

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All packages verified in pubspec.yaml, patterns from existing codebase
- Architecture: HIGH - Feature structure verified from lib/features/ examples (statistics, platforms, reservations)
- Pitfalls: MEDIUM - Based on common Flutter/Dart issues, some specific to inventory feature need validation

**Research date:** 2026-04-12
**Valid until:** 2026-05-12 (30 days - stable tech stack, no major updates expected)
