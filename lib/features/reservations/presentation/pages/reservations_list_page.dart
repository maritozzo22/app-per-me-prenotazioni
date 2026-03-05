import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/reservations_list/reservation_list_tile.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';
import 'package:app_prenotazioni/features/search/presentation/providers/search_provider.dart';
import 'package:app_prenotazioni/features/search/presentation/widgets/search_bar_widget.dart';

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
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prenotazioni'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
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

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (searchState.hasQuery && searchState.isEmpty) {
      return _buildSearchEmptyState();
    }

    if (reservationsToShow == null || reservationsToShow.isEmpty) {
      return _buildEmptyState();
    }

    return _buildList(reservationsToShow);
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

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna prenotazione trovata',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prova con altri termini di ricerca',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Reservation> reservations) {
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return ReservationListTile(
          reservation: reservation,
          onEdit: () => _navigateToEdit(reservation),
          onDelete: () => _deleteReservation(reservation),
        );
      },
    );
  }
}
