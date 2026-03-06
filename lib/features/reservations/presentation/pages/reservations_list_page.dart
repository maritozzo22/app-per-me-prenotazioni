import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservation_list_skeleton.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';
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

      // Cancel notifications before deleting (Android only)
      if (PlatformService.notificationsSupported) {
        try {
          final scheduler = ref.read(reservationNotificationSchedulerProvider);
          await scheduler.cancelReservationNotifications(reservation.id);
        } catch (e) {
          // Don't fail the delete if notification cancellation fails
          print('Error cancelling notifications: $e');
        }
      }

      await repository.deleteReservation(reservation.id);

      if (mounted) {
        ErrorSnackbar.showSuccess(
          context,
          'Prenotazione di ${reservation.guest.name} eliminata',
        );
        await _loadReservations();
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
      await _loadReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      key: const Key('reservations_list'),
      appBar: AppBar(
        title: const Text('Prenotazioni'),
        elevation: 2,
        actions: const [
          ThemeToggleButton(),
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
              onRefresh: _loadReservations,
              child: _buildBody(searchState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState searchState) {
    // Determine which reservations to show
    final reservationsToShow = searchState.hasQuery
        ? searchState.results
        : _reservations;

    if (_isLoading && reservationsToShow == null) {
      return const ReservationListSkeleton();
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        error: _error!,
        onRetry: _loadReservations,
      );
    }

    if (searchState.hasQuery && searchState.isEmpty) {
      return EmptyStates.noSearchResults();
    }

    if (reservationsToShow == null || reservationsToShow.isEmpty) {
      return EmptyStates.noReservations();
    }

    return _buildList(reservationsToShow);
  }

  Widget _buildList(List<Reservation> reservations) {
    return ListView.builder(
      itemCount: reservations.length,
      cacheExtent: 500, // Pre-render 500px worth of items for smoother scrolling
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return FadeIn(
          slide: SlideDirection.left,
          delay: Duration(milliseconds: 50 * index),
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
