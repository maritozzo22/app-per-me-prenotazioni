---
phase: 04-dashboard-navigation
plan: 03
type: execute
wave: 3
depends_on:
  - 04-02
files_modified:
  - lib/features/reservations/presentation/pages/reservations_list_page.dart
  - lib/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart
  - lib/features/reservations/presentation/pages/edit_reservation_page.dart
  - test/features/reservations/presentation/pages/reservations_list_page_test.dart
  - test/features/reservations/presentation/widgets/reservations_list/reservation_list_tile_test.dart
autonomous: true
requirements:
  - RES-08
  - RES-09
  - TEST-04
must_haves:
  truths:
    - "L'utente vede una lista di tutte le prenotazioni ordinate per check-in"
    - "L'utente puo scorrere a sinistra per vedere azioni (modifica/elimina)"
    - "L'utente puo modificare una prenotazione esistente"
    - "L'utente puo eliminare una prenotazione con conferma"
    - "La conferma eliminazione mostra il nome dell'ospite"
    - "Dopo eliminazione la lista si aggiorna"
  artifacts:
    - path: "lib/features/reservations/presentation/pages/reservations_list_page.dart"
      provides: "Pagina lista prenotazioni con swipe actions"
      exports: ["ReservationsListPage"]
      min_lines: 80
    - path: "lib/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart"
      provides: "Widget singolo item lista con swipe"
      exports: ["ReservationListTile"]
      min_lines: 100
    - path: "lib/features/reservations/presentation/pages/edit_reservation_page.dart"
      provides: "Pagina modifica prenotazione (riusa ReservationForm)"
      exports: ["EditReservationPage"]
      min_lines: 60
  key_links:
    - from: "reservations_list_page.dart"
      to: "reservationRepositoryProvider"
      via: "ref.read"
      pattern: "ref.read\\(reservationRepositoryProvider\\)"
    - from: "reservation_list_tile.dart"
      to: "flutter_slidable"
      via: "Slidable widget"
      pattern: "Slidable\\("
    - from: "edit_reservation_page.dart"
      to: "ReservationForm"
      via: "Widget composition"
      pattern: "ReservationForm\\("
    - from: "reservations_list_page.dart"
      to: "EditReservationPage"
      via: "Navigator.push"
      pattern: "Navigator.*EditReservationPage"
---

<objective>
Implementare la lista prenotazioni con swipe actions per modifica ed eliminazione.

Purpose: Fornire all'utente accesso completo alle prenotazioni esistenti con possibilita di modificarle o eliminarle tramite gesture intuitive.

Output: ReservationsListPage con lista ordinata, swipeable items, e flusso di modifica/eliminazione.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/04-dashboard-navigation/CONTEXT.md
@.planning/phases/04-dashboard-navigation/04-RESEARCH.md

# Wave 1-2 outputs (dependencies)
@.planning/phases/04-dashboard-navigation/01-PLAN.md
@.planning/phases/04-dashboard-navigation/02-PLAN.md

# Existing entities from Phases 1-3

From lib/features/reservations/domain/entities/reservation.dart:
```dart
class Reservation {
  final String id;
  final String roomId;
  final String platformId;
  final Guest guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final double? amount;
  final PaymentStatus paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get numberOfNights => checkOut.difference(checkIn).inDays;
}
```

From lib/features/reservations/presentation/providers/reservation_provider.dart:
```dart
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dataSource = ref.watch(reservationDataSourceProvider);
  return ReservationRepositoryImpl(dataSource: dataSource);
});
```

From lib/features/reservations/presentation/widgets/reservation_form.dart:
```dart
class ReservationForm extends StatefulWidget {
  final Reservation? existingReservation;
  final List<Room> rooms;
  final List<BookingPlatform> platforms;
  final ReservationValidationService validationService;
  final Future<bool> Function(Reservation) onSubmit;
  final VoidCallback? onApartmentSelected;

  const ReservationForm({...});
}
```

From lib/features/reservations/domain/repositories/reservation_repository.dart:
```dart
abstract class ReservationRepository {
  Future<List<Reservation>> getAllReservations();
  Future<void> updateReservation(Reservation reservation);
  Future<void> deleteReservation(String id);
}
```

# flutter_slidable Pattern (from RESEARCH.md)

```dart
Slidable(
  key: ValueKey(reservation.id),
  startActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => onEdit(),
        backgroundColor: Colors.blue,
        icon: Icons.edit,
        label: 'Modifica',
      ),
    ],
  ),
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => _confirmDelete(context),
        backgroundColor: Colors.red,
        icon: Icons.delete,
        label: 'Elimina',
      ),
    ],
  ),
  child: ListTile(...),
)
```
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Create ReservationListTile with swipe actions</name>
  <files>lib/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart</files>
  <behavior>
    - Uses flutter_slidable for swipe gestures
    - Left swipe reveals Edit action (blue)
    - Right swipe reveals Delete action (red)
    - Shows: guest name, date range, room name, platform color, payment status
    - Tap on item opens edit page
    - Delete shows confirmation dialog before action
    - Accessible with semantic labels
  </behavior>
  <action>
    Create reservation_list_tile.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_slidable/flutter_slidable.dart';
    import 'package:intl/intl.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

    /// Swipeable list tile for a reservation with edit and delete actions.
    class ReservationListTile extends StatelessWidget {
      final Reservation reservation;
      final VoidCallback onEdit;
      final VoidCallback onDelete;

      const ReservationListTile({
        super.key,
        required this.reservation,
        required this.onEdit,
        required this.onDelete,
      });

      @override
      Widget build(BuildContext context) {
        return Slidable(
          key: ValueKey(reservation.id),
          // Left swipe: Edit
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onEdit(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Modifica',
                autoClose: true,
              ),
            ],
          ),
          // Right swipe: Delete
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _confirmDelete(context),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Elimina',
                autoClose: true,
              ),
            ],
          ),
          child: InkWell(
            onTap: onEdit,
            child: _buildContent(context),
          ),
        );
      }

      Widget _buildContent(BuildContext context) {
        final platform = BookingPlatform.defaultPlatforms.firstWhere(
          (p) => p.id == reservation.platformId,
          orElse: () => BookingPlatform.defaultPlatforms.first,
        );
        final room = Room.defaultRooms.firstWhere(
          (r) => r.id == reservation.roomId,
          orElse: () => Room.defaultRooms.first,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Platform color indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: platform.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.guest.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.bed,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateRange(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Payment status
              Icon(
                reservation.paymentStatus.icon,
                color: reservation.paymentStatus.color,
                size: 24,
                semanticLabel: reservation.paymentStatus.label,
              ),
            ],
          ),
        );
      }

      String _formatDateRange() {
        final checkIn = DateFormat('dd/MM').format(reservation.checkIn);
        final checkOut = DateFormat('dd/MM').format(reservation.checkOut);
        return '$checkIn - $checkOut';
      }

      void _confirmDelete(BuildContext context) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Conferma eliminazione'),
            content: Text(
              'Eliminare la prenotazione di ${reservation.guest.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Elimina'),
              ),
            ],
          ),
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservations_list/reservation_list_tile_test.dart</automated>
  </verify>
  <done>ReservationListTile created with swipe actions and delete confirmation</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Create ReservationsListPage</name>
  <files>lib/features/reservations/presentation/pages/reservations_list_page.dart</files>
  <behavior>
    - Shows all reservations sorted by check-in date ascending (nearest first)
    - Pull-to-refresh to reload data
    - Loading indicator while fetching
    - Empty state when no reservations
    - Uses ReservationRepository directly for data
    - Navigates to EditReservationPage on edit
    - Calls delete on repository after confirmation
    - Shows snackbar after successful delete
  </behavior>
  <action>
    Create reservations_list_page.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';

    /// Page showing list of all reservations with edit/delete actions.
    class ReservationsListPage extends ConsumerStatefulWidget {
      const ReservationsListPage({super.key});

      @override
      ConsumerState<ReservationsListPage> createState() => _ReservationsListPageState();
    }

    class _ReservationsListPageState extends ConsumerState<ReservationsListPage> {
      List<Reservation>? _reservations;
      bool _isLoading = true;
      String? _error;

      @override
      void initState() {
        super.initState();
        _loadReservations();
      }

      Future<void> _loadReservations() async {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        try {
          final repository = ref.read(reservationRepositoryProvider);
          final reservations = await repository.getAllReservations();

          // Sort by check-in date ascending (nearest first)
          reservations.sort((a, b) => a.checkIn.compareTo(b.checkIn));

          if (mounted) {
            setState(() {
              _reservations = reservations;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _error = e.toString();
              _isLoading = false;
            });
          }
        }
      }

      Future<void> _deleteReservation(Reservation reservation) async {
        try {
          final repository = ref.read(reservationRepositoryProvider);
          await repository.deleteReservation(reservation.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Prenotazione di ${reservation.guest.name} eliminata'),
                backgroundColor: Colors.green,
              ),
            );
            await _loadReservations();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Errore: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      Future<void> _navigateToEdit(Reservation reservation) async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => EditReservationPage(reservation: reservation),
          ),
        );

        if (result == true && mounted) {
          await _loadReservations();
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Prenotazioni'),
            elevation: 2,
          ),
          body: RefreshIndicator(
            onRefresh: _loadReservations,
            child: _buildBody(),
          ),
        );
      }

      Widget _buildBody() {
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_error != null) {
          return _buildError();
        }

        if (_reservations == null || _reservations!.isEmpty) {
          return _buildEmptyState();
        }

        return _buildList();
      }

      Widget _buildError() {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Errore nel caricamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadReservations,
                child: const Text('Riprova'),
              ),
            ],
          ),
        );
      }

      Widget _buildEmptyState() {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nessuna prenotazione',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Le prenotazioni appariranno qui',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      Widget _buildList() {
        return ListView.builder(
          itemCount: _reservations!.length,
          itemBuilder: (context, index) {
            final reservation = _reservations![index];
            return ReservationListTile(
              reservation: reservation,
              onEdit: () => _navigateToEdit(reservation),
              onDelete: () => _deleteReservation(reservation),
            );
          },
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/pages/reservations_list_page_test.dart</automated>
  </verify>
  <done>ReservationsListPage created with sorted list and CRUD actions</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Create EditReservationPage reusing ReservationForm</name>
  <files>lib/features/reservations/presentation/pages/edit_reservation_page.dart</files>
  <behavior>
    - Reuses existing ReservationForm widget
    - Passes existingReservation to form for editing
    - Uses ReservationValidationService for validation
    - Calls repository.updateReservation on submit
    - Returns true on success to trigger list refresh
    - Shows loading during submission
  </behavior>
  <action>
    Create edit_reservation_page.dart:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
    import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_form.dart';

    /// Page for editing an existing reservation.
    class EditReservationPage extends ConsumerWidget {
      final Reservation reservation;

      const EditReservationPage({
        super.key,
        required this.reservation,
      });

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final repository = ref.read(reservationRepositoryProvider);
        final validationService = ReservationValidationService(repository);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Modifica Prenotazione'),
            elevation: 2,
          ),
          body: ReservationForm(
            existingReservation: reservation,
            rooms: Room.defaultRooms,
            platforms: BookingPlatform.defaultPlatforms,
            validationService: validationService,
            onSubmit: (updatedReservation) async {
              try {
                await repository.updateReservation(updatedReservation);
                return true;
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return false;
              }
            },
          ),
        );
      }
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/pages/edit_reservation_page_test.dart</automated>
  </verify>
  <done>EditReservationPage created reusing ReservationForm</done>
</task>

<task type="auto">
  <name>Task 4: Create widget tests for list and edit components</name>
  <files>
    test/features/reservations/presentation/widgets/reservations_list/reservation_list_tile_test.dart
    test/features/reservations/presentation/pages/reservations_list_page_test.dart
    test/features/reservations/presentation/pages/edit_reservation_page_test.dart
  </files>
  <action>
    Create widget tests:

    **reservation_list_tile_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:flutter_slidable/flutter_slidable.dart';

    void main() {
      group('ReservationListTile', () {
        late Reservation testReservation;

        setUp(() {
          testReservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario Rossi', phone: '+39123456789'),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18),
            amount: 150.0,
            paymentStatus: PaymentStatus.received,
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );
        });

        testWidgets('displays guest name', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationListTile(
                  reservation: testReservation,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          );

          expect(find.text('Mario Rossi'), findsOneWidget);
        });

        testWidgets('displays room name', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationListTile(
                  reservation: testReservation,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          );

          expect(find.text('Stanza 1'), findsOneWidget);
        });

        testWidgets('shows payment status icon', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationListTile(
                  reservation: testReservation,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          );

          expect(find.byIcon(PaymentStatus.received.icon), findsOneWidget);
        });

        testWidgets('calls onEdit when tapped', (tester) async {
          var editCalled = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationListTile(
                  reservation: testReservation,
                  onEdit: () => editCalled = true,
                  onDelete: () {},
                ),
              ),
            ),
          );

          await tester.tap(find.byType(InkWell));
          expect(editCalled, true);
        });

        testWidgets('shows delete confirmation dialog', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReservationListTile(
                  reservation: testReservation,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          );

          // Find and tap the delete slidable action
          final slidable = tester.widget<Slidable>(find.byType(Slidable));

          // Simulate swipe to reveal delete action
          await tester.drag(
            find.byType(ReservationListTile),
            const Offset(-300, 0),
          );
          await tester.pumpAndSettle();

          // The delete button should now be visible
          expect(find.text('Elimina'), findsOneWidget);
        });
      });
    }
    ```

    **reservations_list_page_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/reservations_list_page.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
    import 'package:mocktail/mocktail.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
      group('ReservationsListPage', () {
        late MockReservationRepository mockRepository;

        setUp(() {
          mockRepository = MockReservationRepository();
          registerFallbackValue(Reservation(
            id: 'test',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Test', phone: null),
            checkIn: DateTime(2024, 1, 1),
            checkOut: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ));
        });

        testWidgets('shows loading indicator initially', (tester) async {
          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => []);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                reservationRepositoryProvider.overrideWithValue(mockRepository),
              ],
              child: const MaterialApp(home: ReservationsListPage()),
            ),
          );

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

        testWidgets('shows empty state when no reservations', (tester) async {
          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => []);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                reservationRepositoryProvider.overrideWithValue(mockRepository),
              ],
              child: const MaterialApp(home: ReservationsListPage()),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Nessuna prenotazione'), findsOneWidget);
        });

        testWidgets('shows reservations when loaded', (tester) async {
          final reservations = [
            Reservation(
              id: '1',
              roomId: 'room-1',
              platformId: 'booking',
              guest: const Guest(name: 'Mario', phone: null),
              checkIn: DateTime(2024, 6, 15),
              checkOut: DateTime(2024, 6, 18),
              createdAt: DateTime(2024, 6, 1),
              updatedAt: DateTime(2024, 6, 1),
            ),
          ];

          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => reservations);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                reservationRepositoryProvider.overrideWithValue(mockRepository),
              ],
              child: const MaterialApp(home: ReservationsListPage()),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Mario'), findsOneWidget);
        });
      });
    }
    ```

    **edit_reservation_page_test.dart:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
    import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
    import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
    import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
    import 'package:mocktail/mocktail.dart';

    class MockReservationRepository extends Mock implements ReservationRepository {}

    void main() {
      group('EditReservationPage', () {
        late MockReservationRepository mockRepository;
        late Reservation testReservation;

        setUp(() {
          mockRepository = MockReservationRepository();
          testReservation = Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario Rossi', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          );

          registerFallbackValue(testReservation);
        });

        testWidgets('shows app bar with edit title', (tester) async {
          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => []);
          when(() => mockRepository.updateReservation(any()))
              .thenAnswer((_) async {});

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                reservationRepositoryProvider.overrideWithValue(mockRepository),
              ],
              child: MaterialApp(
                home: EditReservationPage(reservation: testReservation),
              ),
            ),
          );

          expect(find.text('Modifica Prenotazione'), findsOneWidget);
        });

        testWidgets('shows reservation form with existing data', (tester) async {
          when(() => mockRepository.getAllReservations())
              .thenAnswer((_) async => []);
          when(() => mockRepository.updateReservation(any()))
              .thenAnswer((_) async {});

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                reservationRepositoryProvider.overrideWithValue(mockRepository),
              ],
              child: MaterialApp(
                home: EditReservationPage(reservation: testReservation),
              ),
            ),
          );

          // Form should be pre-filled with existing data
          expect(find.text('Mario Rossi'), findsOneWidget);
        });
      });
    }
    ```
  </action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/reservations_list/ test/features/reservations/presentation/pages/reservations_list_page_test.dart test/features/reservations/presentation/pages/edit_reservation_page_test.dart</automated>
  </verify>
  <done>All list and edit widget tests passing</done>
</task>

</tasks>

<verification>
1. `flutter analyze` passes for all new files
2. All widget tests pass
3. ReservationsListPage loads and displays reservations
4. List sorted by check-in date ascending
5. Swipe left reveals edit action
6. Swipe right reveals delete action with confirmation
7. Edit page reuses ReservationForm
8. Delete shows confirmation dialog with guest name
9. Snackbar shown after successful delete
</verification>

<success_criteria>
1. ReservationsListPage shows all reservations sorted by check-in
2. flutter_slidable provides intuitive swipe gestures
3. EditReservationPage reuses existing ReservationForm
4. Delete confirmation prevents accidental deletions
5. All widget tests pass
6. List refreshes after edit or delete
7. Error handling for failed operations
</success_criteria>

<output>
After completion, create `.planning/phases/04-dashboard-navigation/04-03-SUMMARY.md` with:
- Wave number (3)
- Tasks completed (4)
- Test results
- Files created/modified
- Next wave (04 - Navigation & Integration)
</output>
