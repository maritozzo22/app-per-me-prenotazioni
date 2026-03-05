import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // CRITICAL: Initialize sqflite FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;

    setUp(() {
      databaseHelper = DatabaseHelper.forTesting();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should initialize database without errors', () async {
      final db = await databaseHelper.database as Database;

      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create rooms table', () async {
      final db = await databaseHelper.database as Database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='rooms'",
      );

      expect(tables, isNotEmpty);
    });

    test('should create platforms table', () async {
      final db = await databaseHelper.database as Database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='platforms'",
      );

      expect(tables, isNotEmpty);
    });

    test('should create reservations table', () async {
      final db = await databaseHelper.database as Database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='reservations'",
      );

      expect(tables, isNotEmpty);
    });

    test('should insert default platforms on creation', () async {
      final db = await databaseHelper.database as Database;

      final platforms = await db.query('platforms');

      expect(platforms.length, 5);
      expect(platforms.any((p) => p['id'] == 'booking'), isTrue);
      expect(platforms.any((p) => p['id'] == 'airbnb'), isTrue);
      expect(platforms.any((p) => p['id'] == 'whatsapp'), isTrue);
      expect(platforms.any((p) => p['id'] == 'website'), isTrue);
      expect(platforms.any((p) => p['id'] == 'tiktok'), isTrue);
    });

    test('should insert default rooms on creation', () async {
      final db = await databaseHelper.database as Database;

      final rooms = await db.query('rooms');

      expect(rooms.length, 4);
      expect(rooms.any((r) => r['id'] == 'room-1'), isTrue);
      expect(rooms.any((r) => r['id'] == 'room-2'), isTrue);
      expect(rooms.any((r) => r['id'] == 'room-3'), isTrue);
      expect(rooms.any((r) => r['id'] == 'apartment'), isTrue);
    });

    test('should have Booking platform with blue color', () async {
      final db = await databaseHelper.database as Database;

      final platforms = await db.query(
        'platforms',
        where: 'id = ?',
        whereArgs: ['booking'],
      );

      expect(platforms, isNotEmpty);
      expect(platforms.first['color_value'], 0xFF2196F3);
    });

    test('should close database successfully', () async {
      await databaseHelper.database;
      await databaseHelper.close();

      // After close, accessing database should create a new instance
      final db = await databaseHelper.database as Database;
      expect(db.isOpen, isTrue);
    });
  });
}
