import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_list_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_list_skeleton.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/filter_sheet.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_form.dart';
import 'package:app_prenotazioni/features/search/presentation/providers/search_provider.dart';
import 'package:app_prenotazioni/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:app_prenotazioni/core/widgets/theme_toggle_button.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';
import 'package:app_prenotazioni/features/notifications/application/reservation_notification_scheduler.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart' show NotificationSchedulerServiceImpl;
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_permission_provider.dart';
import 'package:app_prenotazioni/core/presentation/widgets/error_display_widget.dart';
import 'package:app_prenotazioni/core/presentation/widgets/empty_state_widget.dart';
import 'package:app_prenotazioni/core/presentation/error/error_snackbar.dart';
import 'package:app_prenotazioni/core/widgets/animations.dart';

/// Provider for notification scheduler
final reservationNotificationSchedulerProvider = Provider<ReservationNotificationScheduler>((ref) {
  final schedulerService = NotificationSchedulerServiceImpl();
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return ReservationNotificationScheduler(
    schedulerService: schedulerService,
    notificationRepository: notificationRepository,
    notificationService: notificationService,
  );
});

/// Page showing list of all reservations with edit/delete actions.
class ReservationsListPage extends ConsumerStatefulWidget {
  const ReservationsListPage({super.key});

  @override
  ConsumerState<ReservationsListPage> createState() => _ReservationsListPageState();
}

class _ReservationsListPageState extends ConsumerState<ReservationsListPage> {
  @override
  void initState() {
    super.initState();
    // Load initial reservations using the provider
    Future.microtask(() {
      ref.read(reservationListProvider.notifier).loadInitial();
    });
  }

  Future<void> _refreshReservations() async {
    await ref.read(reservationListProvider.notifier).loadInitial();
  }

  Future<void> _deleteReservation(Reservation reservation) async {
    try {
      final repository = ref.read(reservationRepositoryProvider);

      // Cancel notifications before deleting (Android only)
      if (PlatformService.notificationsSupported) {
        try {
          final scheduler = ref.read(reservationNotificationSchedulerProvider);
          await scheduler.cancelReservationNotifications(reservation.id);
        } catch (e) {
          // Don't fail the delete if notification cancellation fails
          debugPrint('Error cancelling notifications: $e');
        }
      }

      await repository.deleteReservation(reservation.id);

      // Invalidate dashboard cache (statistics changed)
      final cacheService = ref.read(statisticsCacheServiceProvider);
      await cacheService.invalidateCache();

      if (mounted) {
        ErrorSnackbar.showSuccess(
          context,
          'Prenotazione di ${reservation.guest.name} eliminata',
        );
        await _refreshReservations();
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(context, 'Errore: $e');
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
      await _refreshReservations();
    }
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const _AddReservationPage(),
      ),
    );

    if (result == true && mounted) {
      await _refreshReservations();
    }
  }

  void _openFilterSheet() {
    final state = ref.read(reservationListProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterSheet(
        initialFilter: state.activeFilter,
        platforms: BookingPlatform.defaultPlatforms,
        rooms: Room.defaultRooms,
        onApply: (filter) {
          ref.read(reservationListProvider.notifier).applyFilter(filter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final listState = ref.watch(reservationListProvider);

    return Scaffold(
      key: const Key('reservations_list'),
      appBar: AppBar(
        title: const Text('Prenotazioni'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
            tooltip: 'Filtri',
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              key: const Key('search_field'),
              onChanged: (query) {
                // Search is handled by the provider
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshReservations,
              child: _buildBody(searchState, listState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_reservation_fab'),
        onPressed: _navigateToAdd,
        tooltip: 'Aggiungi Prenotazione',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(SearchState searchState, ReservationListState listState) {
    // Determine which reservations to show
    final reservationsToShow = searchState.hasQuery
        ? searchState.results
        : listState.reservations;

    // Show loading skeleton for initial load
    if (listState.isLoading && reservationsToShow.isEmpty) {
      return const ReservationListSkeleton();
    }

    // Show error state
    if (listState.error != null && reservationsToShow.isEmpty) {
      return ErrorDisplayWidget(
        error: listState.error!,
        onRetry: _refreshReservations,
      );
    }

    // Show empty search results
    if (searchState.hasQuery && searchState.isEmpty) {
      return EmptyStates.noSearchResults();
    }

    // Show empty state
    if (reservationsToShow.isEmpty) {
      return EmptyStates.noReservations();
    }

    return _buildList(reservationsToShow, listState.hasMore, listState.isLoadingMore);
  }

  Widget _buildList(List<Reservation> reservations, bool hasMore, bool isLoadingMore) {
    // Add 1 to item count for loading indicator if more pages exist
    final itemCount = reservations.length + (hasMore ? 1 : 0);

    return ListView.builder(
      itemCount: itemCount,
      cacheExtent: 500, // Pre-render 500px worth of items for smoother scrolling
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == reservations.length) {
          // Trigger load more when reaching the bottom
          Future.microtask(() {
            ref.read(reservationListProvider.notifier).loadMore();
          });
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reservation = reservations[index];
        return FadeIn(
          slide: SlideDirection.left,
          delay: Duration(milliseconds: 50 * (index % 20)), // Cap delay for infinite scroll
          child: ReservationListTile(
            reservation: reservation,
            onEdit: () => _navigateToEdit(reservation),
            onDelete: () => _deleteReservation(reservation),
          ),
        );
      },
    );
  }
}

/// Page for adding a new reservation
class _AddReservationPage extends ConsumerWidget {
  const _AddReservationPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(reservationRepositoryProvider);
    final validationService = ReservationValidationService(repository);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Prenotazione'),
        elevation: 2,
      ),
      body: ReservationForm(
        existingReservation: null,
        rooms: Room.defaultRooms,
        platforms: BookingPlatform.defaultPlatforms,
        validationService: validationService,
        onSubmit: (newReservation) async {
          try {
            // Save the new reservation
            await repository.saveReservation(newReservation);

            // Invalidate dashboard cache (statistics changed)
            final cacheService = ref.read(statisticsCacheServiceProvider);
            await cacheService.invalidateCache();

            // Schedule notifications (Android only)
            if (PlatformService.notificationsSupported) {
              try {
                final scheduler = ref.read(reservationNotificationSchedulerProvider);
                await scheduler.scheduleReservationNotifications(newReservation);
              } catch (e) {
                // Don't fail the save if notification scheduling fails
                debugPrint('Error scheduling notifications: $e');
              }
            }

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
