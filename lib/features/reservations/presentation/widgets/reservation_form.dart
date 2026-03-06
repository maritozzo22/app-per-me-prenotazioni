import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/validation_result.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/room_dropdown.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/platform_dropdown.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/payment_status_toggle.dart';
import 'package:app_prenotazioni/core/widgets/animations.dart';
import 'package:uuid/uuid.dart';

class ReservationForm extends StatefulWidget {
  final Reservation? existingReservation;
  final List<Room> rooms;
  final List<BookingPlatform> platforms;
  final ReservationValidationService validationService;
  final Future<bool> Function(Reservation) onSubmit;
  final VoidCallback? onApartmentSelected;

  const ReservationForm({
    super.key,
    this.existingReservation,
    required this.rooms,
    required this.platforms,
    required this.validationService,
    required this.onSubmit,
    this.onApartmentSelected,
  });

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _uuid = const Uuid();

  // Form state
  String? _selectedRoomId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  Map<String, ValidationResult> _availabilityCache = {};

  // Validation state
  String? _dateError;
  bool _isSubmitting = false;
  bool _shouldShake = false;

  bool get _isEditing => widget.existingReservation != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingReservation != null) {
      _selectedRoomId = widget.existingReservation!.roomId;
      _checkIn = widget.existingReservation!.checkIn;
      _checkOut = widget.existingReservation!.checkOut;
      _paymentStatus = widget.existingReservation!.paymentStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShakeAnimation(
      trigger: _shouldShake,
      duration: const Duration(milliseconds: 500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Room selection
            Semantics(
              label: 'Seleziona stanza',
              hint: 'Scegli la stanza per questa prenotazione',
              child: RoomDropdown(
                value: _selectedRoomId,
                rooms: widget.rooms,
                checkIn: _checkIn,
                checkOut: _checkOut,
                availabilityCache: _availabilityCache,
                onChanged: (value) {
                  setState(() {
                    _selectedRoomId = value;
                    if (value == 'apartment' && widget.onApartmentSelected != null) {
                      widget.onApartmentSelected!();
                    }
                    _validateRoomAvailability();
                  });
                },
                validator: FormBuilderValidators.required(
                  errorText: 'Seleziona una stanza',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Data check-in',
                    hint: 'Seleziona la data di arrivo',
                    child: FormBuilderDateTimePicker(
                      name: 'checkIn',
                      initialValue: _checkIn,
                      decoration: const InputDecoration(
                        labelText: 'Check-in',
                        border: OutlineInputBorder(),
                      ),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onChanged: (value) {
                        setState(() {
                          _checkIn = value;
                          _validateDates();
                          _updateAvailabilityCache();
                        });
                      },
                      validator: FormBuilderValidators.required(
                        errorText: 'Seleziona data check-in',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Semantics(
                    label: 'Data check-out',
                    hint: 'Seleziona la data di partenza',
                    child: FormBuilderDateTimePicker(
                      name: 'checkOut',
                      initialValue: _checkOut,
                      decoration: const InputDecoration(
                        labelText: 'Check-out',
                        border: OutlineInputBorder(),
                      ),
                      firstDate: _checkIn ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onChanged: (value) {
                        setState(() {
                          _checkOut = value;
                          _validateDates();
                          _updateAvailabilityCache();
                        });
                      },
                      validator: FormBuilderValidators.required(
                        errorText: 'Seleziona data check-out',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_dateError != null) ...[
              const SizedBox(height: 8),
              FadeIn(
                slide: SlideDirection.down,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _dateError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Platform
            Semantics(
              label: 'Seleziona piattaforma',
              hint: 'Scegli la piattaforma di prenotazione',
              child: PlatformDropdown(
                value: widget.existingReservation?.platformId,
                platforms: widget.platforms,
                onChanged: (value) {},
                validator: FormBuilderValidators.required(
                  errorText: 'Seleziona una piattaforma',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guest name (mandatory)
            Semantics(
              label: 'Nome ospite',
              hint: 'Inserisci il nome completo dell\'ospite',
              child: FormBuilderTextField(
                name: 'guestName',
                initialValue: widget.existingReservation?.guest.name,
                decoration: const InputDecoration(
                  labelText: 'Nome ospite *',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'Inserisci il nome dell\'ospite',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guest phone (optional)
            Semantics(
              label: 'Telefono ospite',
              hint: 'Inserisci il numero di telefono dell\'ospite',
              child: FormBuilderTextField(
                name: 'guestPhone',
                initialValue: widget.existingReservation?.guest.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 16),

            // Amount and payment status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Semantics(
                    label: 'Importo prenotazione',
                    hint: 'Inserisci l\'importo totale della prenotazione',
                    child: FormBuilderTextField(
                      name: 'amount',
                      initialValue: widget.existingReservation?.amount?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Importo (€)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: FormBuilderValidators.numeric(
                        errorText: 'Inserisci un importo valido',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stato pagamento'),
                      const SizedBox(height: 8),
                      PaymentStatusToggle(
                        value: _paymentStatus,
                        onChanged: (status) {
                          setState(() {
                            _paymentStatus = status;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes (multi-line)
            Semantics(
              label: 'Note prenotazione',
              hint: 'Aggiungi note aggiuntive sulla prenotazione (opzionale)',
              child: FormBuilderTextField(
                name: 'notes',
                initialValue: widget.existingReservation?.notes,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            FilledButton(
              onPressed: _canSubmit() && !_isSubmitting ? _submit : null,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Aggiorna' : 'Crea prenotazione'),
            ),
          ],
        ),
      ),
    ));
  }

  bool _canSubmit() {
    return _formKey.currentState?.isValid == true &&
        _dateError == null &&
        _selectedRoomId != null &&
        _checkIn != null &&
        _checkOut != null;
  }

  void _validateDates() {
    if (_checkIn != null && _checkOut != null) {
      final result = widget.validationService.validateDates(_checkIn!, _checkOut!);
      setState(() {
        _dateError = result.isValid ? null : result.errorMessage;
      });
    }
  }

  Future<void> _validateRoomAvailability() async {
    if (_selectedRoomId == null || _checkIn == null || _checkOut == null) return;

    final result = await widget.validationService.validateReservation(
      roomId: _selectedRoomId!,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      excludeReservationId: widget.existingReservation?.id,
    );

    if (result.isInvalid) {
      setState(() {
        _dateError = result.errorMessage;
      });
    }
  }

  Future<void> _updateAvailabilityCache() async {
    if (_checkIn == null || _checkOut == null) return;

    final cache = <String, ValidationResult>{};
    for (final room in widget.rooms) {
      cache[room.id] = await widget.validationService.validateReservation(
        roomId: room.id,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        excludeReservationId: widget.existingReservation?.id,
      );
    }
    setState(() {
      _availabilityCache = cache;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      // Trigger shake animation for visual feedback
      setState(() {
        _shouldShake = true;
      });
      // Reset shake trigger after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shouldShake = false;
          });
        }
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final values = _formKey.currentState!.value;
      final now = DateTime.now();

      final reservation = Reservation(
        id: widget.existingReservation?.id ?? _uuid.v4(),
        roomId: _selectedRoomId!,
        platformId: values['platform'] as String,
        guest: Guest(
          name: values['guestName'] as String,
          phone: values['guestPhone'] as String?,
        ),
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        amount: values['amount'] != null
            ? double.tryParse(values['amount'] as String)
            : null,
        paymentStatus: _paymentStatus,
        notes: values['notes'] as String?,
        createdAt: widget.existingReservation?.createdAt ?? now,
        updatedAt: now,
      );

      final success = await widget.onSubmit(reservation);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
