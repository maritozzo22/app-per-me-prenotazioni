import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  group('CalendarNotifier', () {
    late MockReservationRepository mockRepository;
    late CalendarNotifier notifier;

    setUp(() {
      mockRepository = MockReservationRepository();
      notifier = CalendarNotifier(mockRepository);
    });

    test('initial state has current focused day and isLoading true', () {
      expect(notifier.state.focusedDay, isNotNull);
      expect(notifier.state.reservationsByDate, isEmpty);
      expect(notifier.state.isLoading, false); // Loaded immediately
    });

    test('loadReservations groups reservations by date', () async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Mario', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      await notifier.loadReservations();

      expect(notifier.state.reservationsByDate.length, greaterThan(0));
      expect(notifier.state.isLoading, false);
    });

    test('selectDay updates selected day', () {
      final day = DateTime(2024, 6, 15);
      notifier.selectDay(day);
      expect(notifier.state.selectedDay, day);
    });

    test('changeMonth updates focused day', () {
      final newMonth = DateTime(2024, 7, 1);
      notifier.changeMonth(newMonth);
      expect(notifier.state.focusedDay, newMonth);
    });
  });
}
