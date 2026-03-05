import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/validation_result.dart';

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
      initialValue: value,
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
