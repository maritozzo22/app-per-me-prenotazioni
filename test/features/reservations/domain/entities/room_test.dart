import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

void main() {
  group('Room', () {
    group('RoomType', () {
      test('should have singleRoom and entireApartment values', () {
        expect(RoomType.values, contains(RoomType.singleRoom));
        expect(RoomType.values, contains(RoomType.entireApartment));
        expect(RoomType.values.length, 2);
      });
    });

    group('defaultRooms', () {
      test('should contain exactly 4 rooms', () {
        expect(Room.defaultRooms.length, 4);
      });

      test('Stanza 1 should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'room-1');
        expect(room.name, 'Stanza 1');
        expect(room.type, RoomType.singleRoom);
      });

      test('Stanza 2 should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'room-2');
        expect(room.name, 'Stanza 2');
        expect(room.type, RoomType.singleRoom);
      });

      test('Stanza 3 should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'room-3');
        expect(room.name, 'Stanza 3');
        expect(room.type, RoomType.singleRoom);
      });

      test('Appartamento Intero should have correct properties', () {
        final room = Room.defaultRooms.firstWhere((r) => r.id == 'apartment');
        expect(room.name, 'Appartamento Intero');
        expect(room.type, RoomType.entireApartment);
      });

      test('all rooms should have unique ids', () {
        final ids = Room.defaultRooms.map((r) => r.id).toList();
        expect(ids.toSet().length, ids.length);
      });
    });

    group('Room entity', () {
      test('should create a room with all required fields', () {
        final room = Room(
          id: 'test-id',
          name: 'Test Room',
          type: RoomType.singleRoom,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(room.id, 'test-id');
        expect(room.name, 'Test Room');
        expect(room.type, RoomType.singleRoom);
        expect(room.createdAt, DateTime(2024, 1, 1));
      });
    });
  });
}
