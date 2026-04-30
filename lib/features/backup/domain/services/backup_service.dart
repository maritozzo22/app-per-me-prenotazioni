import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:app_prenotazioni/features/backup/data/models/backup_data_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';

/// Service for creating, restoring, and managing backups.
class BackupService {
  final ReservationRepository _repository;
  static const String _backupDirectoryName = 'backups';
  static const String _backupVersion = '1.0.0';

  BackupService({required ReservationRepository repository})
      : _repository = repository;

  /// Creates a backup of all app data.
  Future<BackupDataModel> createBackup({BackupType type = BackupType.manual}) async {
    // Fetch all data from repository
    final reservations = await _repository.getAllReservations();
    final platforms = await _repository.getAllPlatforms();
    final rooms = await _repository.getAllRooms();

    // Convert to JSON-serializable maps
    final reservationMaps = reservations
        .map((r) => r.toModel().toJson())
        .toList();
    final platformMaps = platforms
        .map((p) => p.toModel().toJson())
        .toList();
    final roomMaps = rooms
        .map((r) => r.toModel().toJson())
        .toList();

    final backup = BackupDataModel(
      version: _backupVersion,
      timestamp: DateTime.now(),
      reservations: reservationMaps,
      platforms: platformMaps,
      rooms: roomMaps,
      backupType: type.name,
    );

    return backup;
  }

  /// Saves a backup to a file and returns the file path.
  Future<String> saveBackupToFile(BackupDataModel backup) async {
    final backupDir = await _getBackupDirectory();
    final fileName = _generateBackupFileName(backup.backupType);
    final filePath = '${backupDir.path}/$fileName';

    final jsonString = const JsonEncoder.withIndent('  ').convert(backup.toJson());
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  /// Creates and saves a backup in one operation.
  Future<BackupInfo> createAndSaveBackup({BackupType type = BackupType.manual}) async {
    final backup = await createBackup(type: type);
    final filePath = await saveBackupToFile(backup);
    final file = File(filePath);

    return BackupInfo(
      filePath: filePath,
      fileName: file.uri.pathSegments.last,
      timestamp: backup.timestamp,
      backupType: backup.backupType,
      fileSizeBytes: await file.length(),
      reservationCount: backup.reservations.length,
      platformCount: backup.platforms.length,
      roomCount: backup.rooms.length,
    );
  }

  /// Restores data from a backup.
  Future<bool> restoreBackup(BackupDataModel backup) async {
    try {
      // Validate backup version
      if (!_isVersionSupported(backup.version)) {
        throw BackupException('Unsupported backup version: ${backup.version}');
      }

      // Restore data using batch insert for performance
      // First, we need to clear existing data and restore all tables
      // Note: This is a destructive operation

      // Convert maps back to models and then to entities
      final reservations = backup.reservations
          .map((map) => ReservationModel.fromJson(map).toEntity())
          .toList();

      // Use batch insert for reservations
      await _repository.insertReservationsBatch(reservations);

      return true;
    } catch (e) {
      if (e is BackupException) {
        rethrow;
      }
      throw BackupException('Failed to restore backup: $e');
    }
  }

  /// Validates a backup file's integrity.
  Future<bool> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Check required fields
      final requiredFields = ['version', 'timestamp', 'reservations', 'platforms', 'rooms'];
      for (final field in requiredFields) {
        if (!json.containsKey(field)) {
          return false;
        }
      }

      // Validate version
      final version = json['version'] as String;
      if (!_isVersionSupported(version)) {
        return false;
      }

      // Validate timestamp
      try {
        DateTime.parse(json['timestamp'] as String);
      } catch (_) {
        return false;
      }

      // Validate arrays
      if (json['reservations'] is! List ||
          json['platforms'] is! List ||
          json['rooms'] is! List) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets all available backups.
  Future<List<BackupInfo>> getAvailableBackups() async {
    final backupDir = await _getBackupDirectory();
    final files = await backupDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    final backups = <BackupInfo>[];

    for (final file in files) {
      try {
        final info = await _getBackupInfoFromFile(file);
        if (info != null) {
          backups.add(info);
        }
      } catch (e) {
        // Skip invalid backup files
        continue;
      }
    }

    // Sort by timestamp descending (newest first)
    backups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return backups;
  }

  /// Deletes a backup file.
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Loads a backup from a file.
  Future<BackupDataModel?> loadBackupFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return BackupDataModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Gets the backup directory path.
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupDirectoryName');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  /// Generates a backup file name.
  String _generateBackupFileName(String backupType) {
    final now = DateTime.now();
    final timestamp = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    final prefix = backupType == 'weekly' ? 'weekly_' : '';
    return '${prefix}backup_$timestamp.json';
  }

  /// Checks if a backup version is supported.
  bool _isVersionSupported(String version) {
    // For now, we only support version 1.0.0
    // In the future, this can be expanded for migration support
    return version == _backupVersion || version.startsWith('1.');
  }

  /// Gets backup info from a file.
  Future<BackupInfo?> _getBackupInfoFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final backup = BackupDataModel.fromJson(json);

      return BackupInfo(
        filePath: file.path,
        fileName: file.uri.pathSegments.last,
        timestamp: backup.timestamp,
        backupType: backup.backupType,
        fileSizeBytes: await file.length(),
        reservationCount: backup.reservations.length,
        platformCount: backup.platforms.length,
        roomCount: backup.rooms.length,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets the last backup time.
  Future<DateTime?> getLastBackupTime() async {
    final backups = await getAvailableBackups();
    if (backups.isEmpty) {
      return null;
    }
    return backups.first.timestamp;
  }

  /// Gets the total size of all backups in bytes.
  Future<int> getTotalBackupSize() async {
    final backups = await getAvailableBackups();
    return backups.fold<int>(0, (sum, backup) => sum + backup.fileSizeBytes);
  }

  /// Gets the backup directory path as a string (for display).
  Future<String> getBackupDirectoryPath() async {
    final dir = await _getBackupDirectory();
    return dir.path;
  }
}

/// Exception thrown during backup operations.
class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => 'BackupException: $message';
}
