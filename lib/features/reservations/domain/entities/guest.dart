/// Represents a guest making a reservation.
class Guest {
  final String name;
  final String? phone;

  const Guest({
    required this.name,
    this.phone,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guest &&
        other.name == name &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(name, phone);

  @override
  String toString() => 'Guest(name: $name, phone: $phone)';
}
