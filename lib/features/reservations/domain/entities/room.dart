/// Types of rooms available in the property.
enum RoomType {
  singleRoom,
  entireApartment,
}

/// Represents a bookable room in the property.
class Room {
  final String id;
  final String name;
  final RoomType type;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  /// Predefined rooms for this app (ROOM-01).
  static final List<Room> defaultRooms = [
    Room(
      id: 'room-1',
      name: 'Stanza 1',
      type: RoomType.singleRoom,
      createdAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'room-2',
      name: 'Stanza 2',
      type: RoomType.singleRoom,
      createdAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'room-3',
      name: 'Stanza 3',
      type: RoomType.singleRoom,
      createdAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'apartment',
      name: 'Appartamento Intero',
      type: RoomType.entireApartment,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
}
