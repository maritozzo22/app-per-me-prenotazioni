import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_data_model.freezed.dart';
part 'backup_data_model.g.dart';

/// Backup data model containing all app data for export/import.
@freezed
class BackupDataModel with _$BackupDataModel {
  const factory BackupDataModel({
    required String version,
    required DateTime timestamp,
    required List<Map<String, dynamic>> reservations,
    required List<Map<String, dynamic>> platforms,
    required List<Map<String, dynamic>> rooms,
    @Default('manual') String backupType,
  }) = _BackupDataModel;

  factory BackupDataModel.fromJson(Map<String, dynamic> json) =>
      _$BackupDataModelFromJson(json);
}

/// Information about a backup file for display in UI.
class BackupInfo {
  final String filePath;
  final String fileName;
  final DateTime timestamp;
  final String backupType;
  final int fileSizeBytes;
  final int reservationCount;
  final int platformCount;
  final int roomCount;

  const BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.timestamp,
    required this.backupType,
    required this.fileSizeBytes,
    required this.reservationCount,
    required this.platformCount,
    required this.roomCount,
  });

  /// Human-readable file size (e.g., "2.5 KB")
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Formatted timestamp for display
  String get timestampFormatted {
    final date = timestamp.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Backup type enumeration
enum BackupType {
  manual,
  daily,
  weekly,
}
