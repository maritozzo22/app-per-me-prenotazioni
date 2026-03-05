---
phase: 02-crud-prenotazioni
plan: 02
type: execute
wave: 2
depends_on: [02-crud-prenotazioni/01]
files_modified:
  - pubspec.yaml
  - lib/features/reservations/presentation/widgets/reservation_form.dart
  - lib/features/reservations/presentation/widgets/room_dropdown.dart
  - lib/features/reservations/presentation/widgets/platform_dropdown.dart
  - lib/features/reservations/presentation/widgets/payment_status_toggle.dart
  - lib/features/reservations/presentation/widgets/date_range_picker.dart
  - lib/features/reservations/presentation/widgets/delete_confirmation_dialog.dart
  - lib/features/reservations/presentation/widgets/undo_snackbar.dart
  - lib/features/reservations/presentation/screens/reservation_form_screen.dart
autonomous: true
requirements:
  - RES-01/02/03/04/05/06/07
  - UI-03
  - TEST-02
must_haves:
  truths:
    - "Form validates in real-time as user types/selects"
    - "Room dropdown filters to show only available rooms"
    - "Delete confirmation shows reservation details"
    - "Undo snackbar restores deleted reservations"
  artifacts:
    - path: "lib/features/reservations/presentation/widgets/reservation_form.dart"
      provides: "Main form widget for creating/editing reservations"
      exports: ["ReservationForm"]
    - path: "lib/features/reservations/presentation/widgets/room_dropdown.dart"
      provides: "Room selector with availability filtering"
      exports: ["RoomDropdown"]
  key_links:
    - from: "ReservationForm"
      to: "ReservationValidationService"
      via: "real-time validation"
      pattern: "reactive form"
---

<objective>
Build the UI components for reservation CRUD operations including form, dropdowns, date pickers, and delete confirmation.

Purpose: Create reusable widgets for reservation management with real-time validation.
Output: Complete form widget with all input fields and validation feedback.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/phases/02-crud-prenotazioni/02-CONTEXT.md

## User Decisions Applied

### Form UX
- Single page scrollable form
- Mandatory: Nome, Date, Stanza, Piattaforma
- Optional: Importo, Telefono, Note
- Notes: Multi-line textarea
- Amount: Number field + payment status toggle

### Validation
- Real-time validation as user types/selects
- Inline error + show conflicting reservation details
- Room dropdown shows only available rooms

### Delete
- Dialog shows guest name, dates, room
- Swipe-to-delete + detail screen access
- 5-second undo snackbar

## Dependencies from Wave 1
- PaymentStatus enum
- ReservationValidationService with business rules
- Updated Reservation entity with paymentStatus
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add form_builder dependency</name>
  <files>pubspec.yaml</files>
  <action>
Add flutter_form_builder and form_builder_validators to pubspec.yaml:

```yaml
dependencies:
  # ... existing dependencies ...

  # Form handling
  flutter_form_builder: ^9.7.0
  form_builder_validators: ^11.1.0

  # State management (for form state)
  flutter_riverpod: ^2.6.0
```

Run `flutter pub get` to resolve dependencies.
</action>
  <verify>
    <automated>flutter pub get && flutter analyze</automated>
  </verify>
  <done>
    - flutter_form_builder added
    - form_builder_validators added
    - flutter_riverpod added
    - Dependencies resolve without conflicts
  </done>
</task>

<task type="auto">
  <name>Task 2: Create RoomDropdown widget</name>
  <files>lib/features/reservations/presentation/widgets/room_dropdown.dart</files>
  <action>
Create the room dropdown with availability filtering:

```dart
// lib/features/reservations/presentation/widgets/room_dropdown.dart

import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';

class RoomDropdown extends StatelessWidget {
  final String? value;
  final List<Room> rooms;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final Map<String, ValidationResult>? availabilityCache;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const RoomDropdown({
    super.key,
    required this.value,
    required this.rooms,
    this.checkIn,
    this.checkOut,
    this.availabilityCache,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Stanza',
        border: OutlineInputBorder(),
      ),
      items: rooms.map((room) {
        final isAvailable = _isRoomAvailable(room.id);
        final blockingInfo = _getBlockingInfo(room.id);

        return DropdownMenuItem<String>(
          value: room.id,
          enabled: isAvailable,
          child: Tooltip(
            message: blockingInfo ?? room.name,
            child: Text(
              room.name,
              style: TextStyle(
                color: isAvailable ? null : Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  bool _isRoomAvailable(String roomId) {
    if (checkIn == null || checkOut == null || availabilityCache == null) {
      return true; // No dates selected, assume available
    }
    final result = availabilityCache![roomId];
    return result?.isValid ?? true;
  }

  String? _getBlockingInfo(String roomId) {
    if (checkIn == null || checkOut == null || availabilityCache == null) {
      return null;
    }
    final result = availabilityCache![roomId];
    if (result?.isInvalid == true) {
      return result!.errorMessage;
    }
    return null;
  }
}
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/presentation/widgets/room_dropdown.dart</automated>
  </verify>
  <done>
    - RoomDropdown widget created
    - Shows all rooms with availability indication
    - Grayed out rooms show tooltip with blocking info
    - Integrates with validation cache
  </done>
</task>

<task type="auto">
  <name>Task 3: Create PlatformDropdown widget</name>
  <files>lib/features/reservations/presentation/widgets/platform_dropdown.dart</files>
  <action>
Create the platform dropdown with color indicators:

```dart
// lib/features/reservations/presentation/widgets/platform_dropdown.dart

import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

class PlatformDropdown extends StatelessWidget {
  final String? value;
  final List<BookingPlatform> platforms;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const PlatformDropdown({
    super.key,
    required this.value,
    required this.platforms,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Piattaforma',
        border: OutlineInputBorder(),
      ),
      items: platforms.map((platform) {
        return DropdownMenuItem<String>(
          value: platform.id,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: platform.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(platform.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/presentation/widgets/platform_dropdown.dart</automated>
  </verify>
  <done>
    - PlatformDropdown widget created
    - Shows color indicator for each platform
    - Standard dropdown interface
  </done>
</task>

<task type="auto">
  <name>Task 4: Create PaymentStatusToggle widget</name>
  <files>lib/features/reservations/presentation/widgets/payment_status_toggle.dart</files>
  <action>
Create the payment status toggle:

```dart
// lib/features/reservations/presentation/widgets/payment_status_toggle.dart

import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class PaymentStatusToggle extends StatelessWidget {
  final PaymentStatus value;
  final ValueChanged<PaymentStatus> onChanged;

  const PaymentStatusToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PaymentStatus>(
      segments: PaymentStatus.values.map((status) {
        return ButtonSegment<PaymentStatus>(
          value: status,
          label: Text(status.label),
          icon: Icon(status.icon),
        );
      }).toList(),
      selected: {value},
      onSelectionChanged: (Set<PaymentStatus> selection) {
        onChanged(selection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return value.color.withValues(alpha: 0.2);
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return value.color;
          }
          return null;
        }),
      ),
    );
  }
}
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/presentation/widgets/payment_status_toggle.dart</automated>
  </verify>
  <done>
    - PaymentStatusToggle widget created
    - Uses SegmentedButton for clear toggle UI
    - Shows icon and label for each status
    - Color indicates current selection
  </done>
</task>

<task type="auto">
  <name>Task 5: Create DeleteConfirmationDialog widget</name>
  <files>lib/features/reservations/presentation/widgets/delete_confirmation_dialog.dart</files>
  <action>
Create the delete confirmation dialog:

```dart
// lib/features/reservations/presentation/widgets/delete_confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Reservation reservation;
  final List<Room> rooms;

  const DeleteConfirmationDialog({
    super.key,
    required this.reservation,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    final roomName = rooms.firstWhere(
      (r) => r.id == reservation.roomId,
      orElse: () => Room(
        id: reservation.roomId,
        name: reservation.roomId,
        type: RoomType.singleRoom,
        createdAt: DateTime.now(),
      ),
    ).name;

    return AlertDialog(
      title: const Text('Eliminare la prenotazione?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Ospite', reservation.guest.name),
          const SizedBox(height: 8),
          _buildDetailRow('Stanza', roomName),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Date',
            '${_formatDate(reservation.checkIn)} - ${_formatDate(reservation.checkOut)}',
          ),
          if (reservation.amount != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Importo',
              '€${reservation.amount!.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Elimina'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Shows delete confirmation dialog and returns true if confirmed.
Future<bool> showDeleteConfirmation({
  required BuildContext context,
  required Reservation reservation,
  required List<Room> rooms,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => DeleteConfirmationDialog(
      reservation: reservation,
      rooms: rooms,
    ),
  );
  return result ?? false;
}
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/presentation/widgets/delete_confirmation_dialog.dart</automated>
  </verify>
  <done>
    - DeleteConfirmationDialog created
    - Shows guest name, room, dates, and optional amount
    - Cancel and Delete buttons
    - Helper function for easy display
  </done>
</task>

<task type="auto">
  <name>Task 6: Create UndoSnackbar widget</name>
  <files>lib/features/reservations/presentation/widgets/undo_snackbar.dart</files>
  <action>
Create the undo snackbar:

```dart
// lib/features/reservations/presentation/widgets/undo_snackbar.dart

import 'package:flutter/material.dart';

/// Shows a snackbar with an undo action.
void showUndoSnackbar({
  required BuildContext context,
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: SnackBarAction(
        label: 'Annulla',
        onPressed: onUndo,
      ),
    ),
  );
}

/// Manages a pending deletion with undo capability.
class PendingDeletionManager<T> {
  T? _pendingItem;
  VoidCallback? _executeDeletion;
  bool _isPending = false;

  bool get isPending => _isPending;
  T? get pendingItem => _pendingItem;

  void scheduleDeletion({
    required T item,
    required VoidCallback executeDeletion,
  }) {
    _pendingItem = item;
    _executeDeletion = executeDeletion;
    _isPending = true;
  }

  void undo() {
    _pendingItem = null;
    _executeDeletion = null;
    _isPending = false;
  }

  void confirm() {
    if (_isPending && _executeDeletion != null) {
      _executeDeletion!();
    }
    _pendingItem = null;
    _executeDeletion = null;
    _isPending = false;
  }
}
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/presentation/widgets/undo_snackbar.dart</automated>
  </verify>
  <done>
    - showUndoSnackbar function created
    - PendingDeletionManager for managing undo state
    - 5-second default duration
    - Clear snackbar before showing new one
  </done>
</task>

<task type="auto">
  <name>Task 7: Create main ReservationForm widget</name>
  <files>lib/features/reservations/presentation/widgets/reservation_form.dart</files>
  <action>
Create the main reservation form with real-time validation:

```dart
// lib/features/reservations/presentation/widgets/reservation_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/room_dropdown.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/platform_dropdown.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/payment_status_toggle.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Room selection
            RoomDropdown(
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
            const SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 16),
                Expanded(
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
              ],
            ),
            if (_dateError != null) ...[
              const SizedBox(height: 8),
              Text(
                _dateError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Platform
            PlatformDropdown(
              value: widget.existingReservation?.platformId,
              platforms: widget.platforms,
              onChanged: (value) {},
              validator: FormBuilderValidators.required(
                errorText: 'Seleziona una piattaforma',
              ),
            ),
            const SizedBox(height: 16),

            // Guest name (mandatory)
            FormBuilderTextField(
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
            const SizedBox(height: 16),

            // Guest phone (optional)
            FormBuilderTextField(
              name: 'guestPhone',
              initialValue: widget.existingReservation?.guest.phone,
              decoration: const InputDecoration(
                labelText: 'Telefono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Amount and payment status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
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
            FormBuilderTextField(
              name: 'notes',
              initialValue: widget.existingReservation?.notes,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
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
    );
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
    if (!_formKey.currentState!.saveAndValidate()) return;

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
```
</action>
  <verify>
    <automated>flutter analyze lib/features/reservations/presentation/widgets/reservation_form.dart</automated>
  </verify>
  <done>
    - ReservationForm widget created
    - Real-time validation as user types/selects
    - Room availability filtering
    - Payment status toggle
    - Multi-line notes field
    - Submit button disabled until form is valid
  </done>
</task>

<task type="auto">
  <name>Task 8: Write widget tests</name>
  <files>
    test/features/reservations/presentation/widgets/room_dropdown_test.dart
    test/features/reservations/presentation/widgets/platform_dropdown_test.dart
    test/features/reservations/presentation/widgets/payment_status_toggle_test.dart
    test/features/reservations/presentation/widgets/delete_confirmation_dialog_test.dart
  </files>
  <action>
Create widget tests for all new widgets. Example for RoomDropdown:

```dart
// test/features/reservations/presentation/widgets/room_dropdown_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/room_dropdown.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/validation_result.dart';

void main() {
  group('RoomDropdown', () {
    final testRooms = Room.defaultRooms;

    testWidgets('shows all rooms when no dates selected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RoomDropdown(
            value: null,
            rooms: testRooms,
            onChanged: (_) {},
          ),
        ),
      ));

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show all 4 rooms
      expect(find.text('Stanza 1'), findsWidgets);
      expect(find.text('Stanza 2'), findsWidgets);
      expect(find.text('Stanza 3'), findsWidgets);
      expect(find.text('Appartamento Intero'), findsWidgets);
    });

    testWidgets('grays out unavailable room', (tester) async {
      final availabilityCache = {
        'room-2': const ValidationResult.failure('Stanza 2 occupata'),
      };

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RoomDropdown(
            value: null,
            rooms: testRooms,
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 18),
            availabilityCache: availabilityCache,
            onChanged: (_) {},
          ),
        ),
      ));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Room 2 should be disabled (grey text)
      // Note: Actual verification depends on DropdownButton implementation
    });
  });
}
```

Create similar tests for other widgets.
</action>
  <verify>
    <automated>flutter test test/features/reservations/presentation/widgets/</automated>
  </verify>
  <done>
    - Widget tests for RoomDropdown pass
    - Widget tests for PlatformDropdown pass
    - Widget tests for PaymentStatusToggle pass
    - Widget tests for DeleteConfirmationDialog pass
  </done>
</task>

</tasks>

<verification>
- [ ] flutter_form_builder dependency added
- [ ] RoomDropdown shows availability status
- [ ] PlatformDropdown shows color indicators
- [ ] PaymentStatusToggle works correctly
- [ ] DeleteConfirmationDialog shows reservation details
- [ ] UndoSnackbar with 5-second duration
- [ ] ReservationForm with real-time validation
- [ ] All widget tests pass
</verification>

<success_criteria>
1. Form validates in real-time as user interacts
2. Room dropdown shows only available rooms (or grays out unavailable)
3. Delete confirmation shows guest name, dates, room
4. Undo option available for 5 seconds after deletion
5. All widget tests pass
</success_criteria>

<output>
After completion, create `.planning/phases/02-crud-prenotazioni/02-02-SUMMARY.md`
</output>
