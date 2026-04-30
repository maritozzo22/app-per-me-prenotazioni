import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/backup/domain/services/backup_service.dart';
import 'package:app_prenotazioni/features/backup/data/models/backup_data_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import '../../../../fixtures/backup_test_data.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late BackupService backupService;
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
    backupService = BackupService(repository: mockRepository);
  });

  group('BackupService', () {
    group('createBackup', () {
      test('creates backup with all data', () async {
        // Arrange
        final testReservations = BackupTestData.createSampleReservations();
        final testRooms = _createTestRooms();
        final testPlatforms = _createTestPlatforms();

        when(() => mockRepository.getAllReservations())
            .thenAnswer((_) async => testReservations);
        when(() => mockRepository.getAllRooms())
            .thenAnswer((_) async => testRooms);
        when(() => mockRepository.getAllPlatforms())
            .thenAnswer((_) async => testPlatforms);

        // Act
        final backup = await backupService.createBackup();

        // Assert
        expect(backup.version, equals('1.0.0'));
        expect(backup.timestamp, isNotNull);
        expect(backup.reservations.length, equals(15));
        expect(backup.platforms.length, equals(5));
        expect(backup.rooms.length, equals(4));
        expect(backup.backupType, equals('manual'));

        verify(() => mockRepository.getAllReservations()).called(1);
        verify(() => mockRepository.getAllRooms()).called(1);
        verify(() => mockRepository.getAllPlatforms()).called(1);
      });

      test('creates backup with correct type', () async {
        // Arrange
        when(() => mockRepository.getAllReservations())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getAllRooms())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getAllPlatforms())
            .thenAnswer((_) async => []);

        // Act
        final dailyBackup = await backupService.createBackup(type: BackupType.daily);
        final weeklyBackup = await backupService.createBackup(type: BackupType.weekly);

        // Assert
        expect(dailyBackup.backupType, equals('daily'));
        expect(weeklyBackup.backupType, equals('weekly'));
      });
    });

    group('validateBackupFile', () {
      test('validates correct backup file', () async {
        // Arrange
        final backup = BackupDataModel(
          version: '1.0.0',
          timestamp: DateTime.now(),
          reservations: [],
          platforms: [],
          rooms: [],
        );

        // Act & Assert
        final json = backup.toJson();
        expect(json['version'], equals('1.0.0'));
        expect(json['timestamp'], isNotNull);
        expect(json['reservations'], isA<List>());
        expect(json['platforms'], isA<List>());
        expect(json['rooms'], isA<List>());
      });

      test('rejects backup with missing fields', () {
        // Arrange
        final invalidJson = {
          'version': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
          // Missing reservations, platforms, rooms
        };

        // Assert
        expect(invalidJson.containsKey('reservations'), isFalse);
        expect(invalidJson.containsKey('platforms'), isFalse);
        expect(invalidJson.containsKey('rooms'), isFalse);
      });
    });

    group('restoreBackup', () {
      test('restores reservations from backup', () async {
        // Arrange
        final testReservations = BackupTestData.createSampleReservations();
        final backup = BackupDataModel(
          version: '1.0.0',
          timestamp: DateTime.now(),
          reservations: testReservations.map((r) {
            return {
              'id': r.id,
              'roomId': r.roomId,
              'platformId': r.platformId,
              'guest': {'name': r.guest.name, 'phone': r.guest.phone},
              'checkIn': r.checkIn.toIso8601String(),
              'checkOut': r.checkOut.toIso8601String(),
              'amount': r.amount,
              'paymentStatus': r.paymentStatus.name,
              'notes': r.notes,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
            };
          }).toList(),
          platforms: [],
          rooms: [],
        );

        when(() => mockRepository.insertReservationsBatch(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await backupService.restoreBackup(backup);

        // Assert
        expect(result, isTrue);
        verify(() => mockRepository.insertReservationsBatch(any())).called(1);
      });

      test('throws on unsupported version', () async {
        // Arrange
        final backup = BackupDataModel(
          version: '99.0.0',
          timestamp: DateTime.now(),
          reservations: [],
          platforms: [],
          rooms: [],
        );

        // Act & Assert
        expect(
          () => backupService.restoreBackup(backup),
          throwsA(isA<BackupException>()),
        );
      });
    });

    group('BackupDataModel', () {
      test('serializes to JSON correctly', () {
        // Arrange
        final timestamp = DateTime(2026, 3, 6, 14, 30);
        final backup = BackupDataModel(
          version: '1.0.0',
          timestamp: timestamp,
          reservations: [
            {'id': 'test-1', 'name': 'Test Reservation'}
          ],
          platforms: [
            {'id': 'airbnb', 'name': 'Airbnb'}
          ],
          rooms: [
            {'id': 'room-1', 'name': 'Room 1'}
          ],
          backupType: 'manual',
        );

        // Act
        final json = backup.toJson();

        // Assert
        expect(json['version'], equals('1.0.0'));
        expect(json['timestamp'], equals(timestamp.toIso8601String()));
        expect(json['reservations'], isA<List>());
        expect(json['platforms'], isA<List>());
        expect(json['rooms'], isA<List>());
        expect(json['backupType'], equals('manual'));
      });

      test('deserializes from JSON correctly', () {
        // Arrange
        final json = {
          'version': '1.0.0',
          'timestamp': '2026-03-06T14:30:00.000',
          'reservations': [
            {'id': 'test-1', 'name': 'Test Reservation'}
          ],
          'platforms': [
            {'id': 'airbnb', 'name': 'Airbnb'}
          ],
          'rooms': [
            {'id': 'room-1', 'name': 'Room 1'}
          ],
          'backupType': 'daily',
        };

        // Act
        final backup = BackupDataModel.fromJson(json);

        // Assert
        expect(backup.version, equals('1.0.0'));
        expect(backup.reservations.length, equals(1));
        expect(backup.platforms.length, equals(1));
        expect(backup.rooms.length, equals(1));
        expect(backup.backupType, equals('daily'));
      });
    });

    group('BackupInfo', () {
      test('formats file size correctly', () {
        // Arrange & Act
        final smallBackup = BackupInfo(
          filePath: '/test/backup.json',
          fileName: 'backup.json',
          timestamp: DateTime.now(),
          backupType: 'manual',
          fileSizeBytes: 512,
          reservationCount: 5,
          platformCount: 3,
          roomCount: 2,
        );

        final mediumBackup = BackupInfo(
          filePath: '/test/backup.json',
          fileName: 'backup.json',
          timestamp: DateTime.now(),
          backupType: 'manual',
          fileSizeBytes: 2048,
          reservationCount: 5,
          platformCount: 3,
          roomCount: 2,
        );

        final largeBackup = BackupInfo(
          filePath: '/test/backup.json',
          fileName: 'backup.json',
          timestamp: DateTime.now(),
          backupType: 'manual',
          fileSizeBytes: 2 * 1024 * 1024, // 2 MB
          reservationCount: 5,
          platformCount: 3,
          roomCount: 2,
        );

        // Assert
        expect(smallBackup.fileSizeFormatted, equals('512 B'));
        expect(mediumBackup.fileSizeFormatted, equals('2.0 KB'));
        expect(largeBackup.fileSizeFormatted, equals('2.0 MB'));
      });

      test('formats timestamp correctly', () {
        // Arrange
        final timestamp = DateTime(2026, 3, 6, 14, 30);
        final backupInfo = BackupInfo(
          filePath: '/test/backup.json',
          fileName: 'backup.json',
          timestamp: timestamp,
          backupType: 'manual',
          fileSizeBytes: 1024,
          reservationCount: 5,
          platformCount: 3,
          roomCount: 2,
        );

        // Act
        final formatted = backupInfo.timestampFormatted;

        // Assert - format is DD/MM/YYYY HH:MM
        expect(formatted, contains('06'));
        expect(formatted, contains('03'));
        expect(formatted, contains('2026'));
        expect(formatted, contains('14:30'));
      });
    });
  });
}

List<Room> _createTestRooms() {
  return [
    Room(
      id: 'room-1',
      name: 'Stanza 1',
      type: RoomType.singleRoom,
      createdAt: DateTime(2026, 1, 1),
    ),
    Room(
      id: 'room-2',
      name: 'Stanza 2',
      type: RoomType.singleRoom,
      createdAt: DateTime(2026, 1, 1),
    ),
    Room(
      id: 'room-3',
      name: 'Stanza 3',
      type: RoomType.singleRoom,
      createdAt: DateTime(2026, 1, 1),
    ),
    Room(
      id: 'apartment',
      name: 'Appartamento Intero',
      type: RoomType.entireApartment,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];
}

List<BookingPlatform> _createTestPlatforms() {
  return [
    BookingPlatform(
      id: 'booking',
      name: 'Booking',
      color: const Color(0xFF2196F3),
      createdAt: DateTime(2026, 1, 1),
    ),
    BookingPlatform(
      id: 'airbnb',
      name: 'Airbnb',
      color: const Color(0xFFE91E63),
      createdAt: DateTime(2026, 1, 1),
    ),
    BookingPlatform(
      id: 'whatsapp',
      name: 'WhatsApp',
      color: const Color(0xFF4CAF50),
      createdAt: DateTime(2026, 1, 1),
    ),
    BookingPlatform(
      id: 'website',
      name: 'Sito Web',
      color: const Color(0xFF9C27B0),
      createdAt: DateTime(2026, 1, 1),
    ),
    BookingPlatform(
      id: 'tiktok',
      name: 'TikTok',
      color: const Color(0xFF212121),
      createdAt: DateTime(2026, 1, 1),
    ),
  ];
}
