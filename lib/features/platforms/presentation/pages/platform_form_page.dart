import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Page for creating or editing a platform
class PlatformFormPage extends ConsumerStatefulWidget {
  final BookingPlatform? platform;

  const PlatformFormPage({
    super.key,
    this.platform,
  });

  @override
  ConsumerState<PlatformFormPage> createState() => _PlatformFormPageState();
}

class _PlatformFormPageState extends ConsumerState<PlatformFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Color _selectedColor;

  // Predefined color palette
  static const List<Color> _colorPalette = [
    Color(0xFF2196F3), // Blue
    Color(0xFFE91E63), // Pink
    Color(0xFF4CAF50), // Green
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFF212121), // Black
    Color(0xFF9E9E9E), // Grey
    Color(0xFFCDDC39), // Lime
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.platform?.name ?? '');
    _selectedColor = widget.platform?.color ?? _colorPalette.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.platform != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifica Piattaforma' : 'Nuova Piattaforma'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Piattaforma',
                hintText: 'Es. Booking, Airbnb, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hotel),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci il nome della piattaforma';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            const Text(
              'Seleziona Colore',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildColorPreview(),
            const SizedBox(height: 16),
            _buildColorPalette(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _savePlatform,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _selectedColor,
                foregroundColor: _getTextColor(_selectedColor),
              ),
              child: Text(
                isEditing ? 'Aggiorna Piattaforma' : 'Crea Piattaforma',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anteprima',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getColorHex(_selectedColor),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _colorPalette.length,
      itemBuilder: (context, index) {
        final color = _colorPalette[index];
        final isSelected = color.value == _selectedColor.value;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                width: isSelected ? 4 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _getTextColor(color),
                    size: 28,
                  )
                : null,
          ),
        );
      },
    );
  }

  void _savePlatform() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();

    if (isEditing) {
      // Update existing platform
      // This will be connected to the provider in the integration task
      Navigator.pop(context, BookingPlatform(
        id: widget.platform!.id,
        name: name,
        color: _selectedColor,
        isSystem: widget.platform!.isSystem,
        createdAt: widget.platform!.createdAt,
      ));
    } else {
      // Create new platform
      // This will be connected to the provider in the integration task
      final newPlatform = BookingPlatform(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        color: _selectedColor,
        isSystem: false,
        createdAt: DateTime.now(),
      );
      Navigator.pop(context, newPlatform);
    }
  }

  String _getColorHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _getTextColor(Color color) {
    // Calculate luminance to determine if text should be white or black
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
