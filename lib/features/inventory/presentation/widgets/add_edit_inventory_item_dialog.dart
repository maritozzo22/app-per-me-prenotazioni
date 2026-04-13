import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

/// Dialog for adding or editing inventory items
class AddEditInventoryItemDialog extends ConsumerStatefulWidget {
  final InventoryItem? item;
  final Function({
    required String name,
    required InventoryCategory category,
    required int quantity,
    DateTime? expiryDate,
    String? notes,
  }) onSubmit;

  const AddEditInventoryItemDialog({
    super.key,
    this.item,
    required this.onSubmit,
  });

  @override
  ConsumerState<AddEditInventoryItemDialog> createState() =>
      _AddEditInventoryItemDialogState();
}

class _AddEditInventoryItemDialogState
    extends ConsumerState<AddEditInventoryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  InventoryCategory? _selectedCategory;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedCategory = widget.item?.category;
    _expiryDate = widget.item?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    final showExpiry = _selectedCategory == InventoryCategory.alimentari;

    return AlertDialog(
      title: Text(isEditing ? 'Modifica Articolo' : 'Aggiungi Articolo'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Es: Pasta, Asciugamani...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci un nome';
                  }
                  if (value.length > 50) {
                    return 'Massimo 50 caratteri';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<InventoryCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                ),
                items: InventoryCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    // Clear expiry date if switching away from Alimentari
                    if (_selectedCategory != InventoryCategory.alimentari) {
                      _expiryDate = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Seleziona una categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantità *',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci la quantità';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (showExpiry) ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Data scadenza *',
                    hintText: 'Seleziona data',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _pickExpiryDate,
                  controller: TextEditingController(
                    text: _expiryDate != null
                        ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                        : '',
                  ),
                  validator: (value) {
                    if (showExpiry && _expiryDate == null) {
                      return 'Seleziona la data di scadenza';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Note opzionali...',
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Salva' : 'Aggiungi'),
        ),
      ],
    );
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = int.parse(_quantityController.text);

    widget.onSubmit(
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      quantity: quantity,
      expiryDate: _expiryDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.pop(context);
  }
}
