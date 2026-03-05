import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

void main() {
  group('RoomModel', () {
    final testDateTime = DateTime(2024, 6, 15, 10, 30);

    test('should serialize to JSON correctly', () {
      final model = RoomModel(
        id: 'room-1',
        name: 'Stanza 1',
        type: 'singleRoom',
        createdAt: testDateTime,
      );

      final json = model.toJson();

      expect(json['id'], 'room-1');
      expect(json['name'], 'Stanza 1');
      expect(json['type'], 'singleRoom');
      expect(json['createdAt'], testDateTime.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'room-1',
        'name': 'Stanza 1',
        'type': 'singleRoom',
        'createdAt': testDateTime.toIso8601String(),
      };

      final model = RoomModel.fromJson(json);

      expect(model.id, 'room-1');
      expect(model.name, 'Stanza 1');
      expect(model.type, 'singleRoom');
      expect(model.createdAt, testDateTime);
    });

    test('should convert to Room entity correctly for singleRoom', () {
      final model = RoomModel(
        id: 'room-1',
        name: 'Stanza 1',
        type: 'singleRoom',
        createdAt: testDateTime,
      );

      final entity = model.toEntity();

      expect(entity.id, 'room-1');
      expect(entity.name, 'Stanza 1');
      expect(entity.type, RoomType.singleRoom);
      expect(entity.createdAt, testDateTime);
    });

    test('should convert to Room entity correctly for entireApartment', () {
      final model = RoomModel(
        id: 'apartment',
        name: 'Appartamento Intero',
        type: 'entireApartment',
        createdAt: testDateTime,
      );

      final entity = model.toEntity();

      expect(entity.id, 'apartment');
      expect(entity.name, 'Appartamento Intero');
      expect(entity.type, RoomType.entireApartment);
      expect(entity.createdAt, testDateTime);
    });

    test('should handle round-trip serialization', () {
      final original = RoomModel(
        id: 'room-2',
        name: 'Stanza 2',
        type: 'singleRoom',
        createdAt: testDateTime,
      );

      final json = original.toJson();
      final restored = RoomModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
