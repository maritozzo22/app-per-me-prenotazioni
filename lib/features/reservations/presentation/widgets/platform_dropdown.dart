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
      initialValue: value,
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
