import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

void main() {
  group('Guest', () {
    test('should create a guest with name only', () {
      const guest = Guest(name: 'Mario Rossi');

      expect(guest.name, 'Mario Rossi');
      expect(guest.phone, isNull);
    });

    test('should create a guest with name and phone', () {
      const guest = Guest(name: 'Mario Rossi', phone: '+39123456789');

      expect(guest.name, 'Mario Rossi');
      expect(guest.phone, '+39123456789');
    });

    test('should support equality', () {
      const guest1 = Guest(name: 'Mario Rossi', phone: '+39123456789');
      const guest2 = Guest(name: 'Mario Rossi', phone: '+39123456789');
      const guest3 = Guest(name: 'Giuseppe Verdi', phone: '+39123456789');

      expect(guest1, equals(guest2));
      expect(guest1, isNot(equals(guest3)));
    });

    test('should have readable toString', () {
      const guest = Guest(name: 'Mario Rossi', phone: '+39123456789');

      expect(guest.toString(), contains('Mario Rossi'));
    });
  });
}
