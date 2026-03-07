import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Filter sheet for filtering reservations.
class FilterSheet extends StatefulWidget {
  final ReservationFilter initialFilter;
  final List<BookingPlatform> platforms;
  final List<Room> rooms;
  final void Function(ReservationFilter) onApply;

  const FilterSheet({
    super.key,
    required this.initialFilter,
    required this.platforms,
    required this.rooms,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _selectedPlatformId;
  late String? _selectedRoomId;
  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;
  late PaymentStatus? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    _selectedPlatformId = widget.initialFilter.platformId;
    _selectedRoomId = widget.initialFilter.roomId;
    _selectedStartDate = widget.initialFilter.startDate;
    _selectedEndDate = widget.initialFilter.endDate;
    _selectedPaymentStatus = widget.initialFilter.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtri',
                style: Theme.of(context).textTheme.headline6,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Period filter (date range picker)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Periodlo'),
            subtitle: Text(_selectedStartDate != null
                ? '${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}'
                : 'Tutte le date'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDateRange,
          ),
          const SizedBox(height: 16),

          // Platform filter
          Text(
            'Piattaforma',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Tutte'),
                selected: _selectedPlatformId == null,
                onSelected: (_) => setState(() => _selectedPlatformId = null),
              ),
              ...widget.platforms.map((platform) => FilterChip(
                    label: Text(platform.name),
                    selected: _selectedPlatformId == platform.id,
                    onSelected: (_) =>
                        setState(() => _selectedPlatformId = platform.id),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Room filter
          Text(
            'Camera',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Tutte'),
                selected: _selectedRoomId == null,
                onSelected: (_) => setState(() => _selectedRoomId = null),
              ),
              ...widget.rooms.map((room) => FilterChip(
                    label: Text(room.name),
                    selected: _selectedRoomId == room.id,
                    onSelected: (_) =>
                        setState(() => _selectedRoomId = room.id),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Payment status filter
          Text(
            'Stato Pagamento',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Tutti'),
                selected: _selectedPaymentStatus == null,
                onSelected: (_) =>
                    setState(() => _selectedPaymentStatus = null),
              ),
              ...PaymentStatus.values.map((status) => FilterChip(
                    label: Text(status.label),
                    selected: _selectedPaymentStatus == status,
                    onSelected: (_) =>
                        setState(() => _selectedPaymentStatus = status),
                  )),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Cancella'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Applica'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedStartDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _selectedStartDate = range.start;
        _selectedEndDate = range.end;
      });
    }
  }

  void _clearFilters() {
    widget.onApply(const ReservationFilter());
    Navigator.pop(context);
  }

  void _applyFilters() {
    widget.onApply(ReservationFilter(
      platformId: _selectedPlatformId,
      roomId: _selectedRoomId,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      paymentStatus: _selectedPaymentStatus,
    ));
    Navigator.pop(context);
  }
}
