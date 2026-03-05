import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  group('DashboardNotifier', () {
    late MockReservationRepository mockRepository;
    late DashboardNotifier notifier;

    setUp(() {
      mockRepository = MockReservationRepository();
      registerFallbackValue(Reservation(
        id: 'test',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Test', phone: null),
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 2),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));
    });

    test('initial state is loading', () {
      notifier = DashboardNotifier(mockRepository);
      expect(notifier.state.isLoading, true);
    });

    test('loadDashboard updates state with statistics', () async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario', phone: null),
          checkIn: DateTime.now().subtract(const Duration(days: 1)),
          checkOut: DateTime.now().add(const Duration(days: 2)),
          amount: 100,
          paymentStatus: PaymentStatus.received,
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      notifier = DashboardNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for init

      expect(notifier.state.isLoading, false);
      expect(notifier.state.statistics, isNotNull);
      expect(notifier.state.statistics!.occupiedRoomsToday, 1);
    });

    test('loadDashboard calculates room occupancy', () async {
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);

      notifier = DashboardNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.roomOccupancy.length, 4);
    });

    test('refresh reloads data', () async {
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);

      notifier = DashboardNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.refresh();

      verify(() => mockRepository.getAllReservations()).called(2);
    });
  });
}
