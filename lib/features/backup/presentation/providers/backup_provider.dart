import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/backup/data/models/backup_data_model.dart';
import 'package:app_prenotazioni/features/backup/domain/services/backup_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';

/// State for backup operations.
class BackupState {
  final bool isBackingUp;
  final bool isRestoring;
  final bool isLoading;
  final List<BackupInfo> availableBackups;
  final DateTime? lastBackupTime;
  final String? errorMessage;
  final String? successMessage;
  final int totalBackupSizeBytes;

  const BackupState({
    this.isBackingUp = false,
    this.isRestoring = false,
    this.isLoading = false,
    this.availableBackups = const [],
    this.lastBackupTime,
    this.errorMessage,
    this.successMessage,
    this.totalBackupSizeBytes = 0,
  });

  BackupState copyWith({
    bool? isBackingUp,
    bool? isRestoring,
    bool? isLoading,
    List<BackupInfo>? availableBackups,
    DateTime? lastBackupTime,
    String? errorMessage,
    String? successMessage,
    int? totalBackupSizeBytes,
  }) {
    return BackupState(
      isBackingUp: isBackingUp ?? this.isBackingUp,
      isRestoring: isRestoring ?? this.isRestoring,
      isLoading: isLoading ?? this.isLoading,
      availableBackups: availableBackups ?? this.availableBackups,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      errorMessage: errorMessage,
      successMessage: successMessage,
      totalBackupSizeBytes: totalBackupSizeBytes ?? this.totalBackupSizeBytes,
    );
  }

  /// Human-readable total backup size.
  String get totalBackupSizeFormatted {
    if (totalBackupSizeBytes < 1024) {
      return '$totalBackupSizeBytes B';
    } else if (totalBackupSizeBytes < 1024 * 1024) {
      return '${(totalBackupSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalBackupSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Notifier for backup state management.
class BackupNotifier extends StateNotifier<BackupState> {
  final BackupService _backupService;

  BackupNotifier({required BackupService backupService})
      : _backupService = backupService,
        super(const BackupState()) {
    loadBackups();
  }

  /// Loads available backups from storage.
  Future<void> loadBackups() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final backups = await _backupService.getAvailableBackups();
      final lastBackupTime = await _backupService.getLastBackupTime();
      final totalSize = await _backupService.getTotalBackupSize();

      state = state.copyWith(
        isLoading: false,
        availableBackups: backups,
        lastBackupTime: lastBackupTime,
        totalBackupSizeBytes: totalSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Errore durante il caricamento dei backup: $e',
      );
    }
  }

  /// Creates a manual backup.
  Future<bool> createBackup({BackupType type = BackupType.manual}) async {
    state = state.copyWith(isBackingUp: true, errorMessage: null, successMessage: null);

    try {
      final backupInfo = await _backupService.createAndSaveBackup(type: type);

      // Reload backups to include the new one
      await loadBackups();

      state = state.copyWith(
        isBackingUp: false,
        successMessage: 'Backup creato con successo: ${backupInfo.fileName}',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isBackingUp: false,
        errorMessage: 'Errore durante la creazione del backup: $e',
      );
      return false;
    }
  }

  /// Restores data from a backup.
  Future<bool> restoreBackup(BackupInfo backupInfo) async {
    state = state.copyWith(isRestoring: true, errorMessage: null, successMessage: null);

    try {
      final backup = await _backupService.loadBackupFromFile(backupInfo.filePath);
      if (backup == null) {
        throw BackupException('Impossibile caricare il file di backup');
      }

      final success = await _backupService.restoreBackup(backup);

      if (success) {
        state = state.copyWith(
          isRestoring: false,
          successMessage: 'Backup ripristinato con successo',
        );
      } else {
        throw BackupException('Ripristino fallito');
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isRestoring: false,
        errorMessage: 'Errore durante il ripristino: $e',
      );
      return false;
    }
  }

  /// Deletes a backup file.
  Future<bool> deleteBackup(BackupInfo backupInfo) async {
    try {
      final success = await _backupService.deleteBackup(backupInfo.filePath);

      if (success) {
        // Remove from local list
        final updatedBackups = state.availableBackups
            .where((b) => b.filePath != backupInfo.filePath)
            .toList();

        final totalSize = updatedBackups.fold<int>(
          0,
          (sum, backup) => sum + backup.fileSizeBytes,
        );

        state = state.copyWith(
          availableBackups: updatedBackups,
          totalBackupSizeBytes: totalSize,
          successMessage: 'Backup eliminato: ${backupInfo.fileName}',
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Errore durante l\'eliminazione: $e',
      );
      return false;
    }
  }

  /// Validates a backup file.
  Future<bool> validateBackup(String filePath) async {
    return await _backupService.validateBackupFile(filePath);
  }

  /// Clears any error or success messages.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// Provider for the backup service.
final backupServiceProvider = Provider<BackupService>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return BackupService(repository: repository);
});

/// Provider for backup state.
final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  return BackupNotifier(backupService: backupService);
});
