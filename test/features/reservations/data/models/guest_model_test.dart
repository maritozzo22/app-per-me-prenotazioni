import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';

void main() {
  group('GuestModel', () {
    test('should serialize to JSON correctly with phone', () {
      const model = GuestModel(name: 'Mario Rossi', phone: '+39123456789');

      final json = model.toJson();

      expect(json['name'], 'Mario Rossi');
      expect(json['phone'], '+39123456789');
    });

    test('should serialize to JSON correctly without phone', () {
      const model = GuestModel(name: 'Mario Rossi');

      final json = model.toJson();

      expect(json['name'], 'Mario Rossi');
      expect(json['phone'], isNull);
    });

    test('should deserialize from JSON correctly with phone', () {
      final json = {
        'name': 'Mario Rossi',
        'phone': '+39123456789',
      };

      final model = GuestModel.fromJson(json);

      expect(model.name, 'Mario Rossi');
      expect(model.phone, '+39123456789');
    });

    test('should deserialize from JSON correctly without phone', () {
      final json = {
        'name': 'Mario Rossi',
        'phone': null,
      };

      final model = GuestModel.fromJson(json);

      expect(model.name, 'Mario Rossi');
      expect(model.phone, isNull);
    });

    test('should convert to Guest entity correctly', () {
      const model = GuestModel(name: 'Mario Rossi', phone: '+39123456789');

      final entity = model.toEntity();

      expect(entity.name, 'Mario Rossi');
      expect(entity.phone, '+39123456789');
    });

    test('should handle round-trip serialization', () {
      const original = GuestModel(name: 'Mario Rossi', phone: '+39123456789');

      final json = original.toJson();
      final restored = GuestModel.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.phone, original.phone);
    });
  });
}
