import 'package:game/domain/repositories/game_repository.dart';
import 'package:game/data/repositories/supabase_statistics_repository.dart';
import 'package:game/data/services/supabase_sync_service.dart';
import 'package:game/core/logging/app_logger.dart';

/// Hybrid repository that uses both local storage and Supabase for statistics
/// Implements offline-first strategy with background synchronization
class HybridStatisticsRepository {
  final GameRepository _localRepository;
  final SupabaseStatisticsRepository _remoteRepository;
  final SupabaseSyncService _syncService;

  HybridStatisticsRepository({
    required GameRepository localRepository,
    required SupabaseStatisticsRepository remoteRepository,
    required SupabaseSyncService syncService,
  }) : _localRepository = localRepository,
       _remoteRepository = remoteRepository,
       _syncService = syncService;

  /// Get comprehensive statistics (offline-first)
  Future<GameStatistics> getComprehensiveStatistics() async {
    try {
      AppLogger.debug(
        'Getting comprehensive statistics (hybrid)',
        tag: 'HybridStatisticsRepository',
      );

      // Always return local data first (offline-first)
      final localStats = await _localRepository.getGameStatistics();

      // Try to sync with remote in background if online
      _backgroundSync();

      AppLogger.info(
        'Successfully retrieved statistics: ${localStats.gamesPlayed} games (hybrid)',
        tag: 'HybridStatisticsRepository',
      );

      return localStats;
    } catch (e) {
      AppLogger.error(
        'Failed to get comprehensive statistics (hybrid): $e',
        tag: 'HybridStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Update comprehensive statistics (offline-first)
  Future<void> updateComprehensiveStatistics(GameStatistics statistics) async {
    try {
      AppLogger.debug(
        'Updating comprehensive statistics (hybrid): ${statistics.gamesPlayed} games',
        tag: 'HybridStatisticsRepository',
      );

      // Always update local storage first (offline-first)
      await _localRepository.saveGameStatistics(statistics);

      // Try to sync to remote if online
      try {
        if (await _syncService.isOnline) {
          await _remoteRepository.updateComprehensiveStatistics(statistics);
          AppLogger.debug(
            'Successfully synced statistics to remote',
            tag: 'HybridStatisticsRepository',
          );
        } else {
          // Mark as dirty for later sync
          await _syncService.markTableDirty('user_statistics');
          AppLogger.debug(
            'Offline: marked statistics for sync',
            tag: 'HybridStatisticsRepository',
          );
        }
      } catch (e) {
        // Remote sync failed, mark as dirty for later sync
        await _syncService.markTableDirty('user_statistics');
        AppLogger.warning(
          'Remote sync failed, marked for later: $e',
          tag: 'HybridStatisticsRepository',
        );
      }

      AppLogger.info(
        'Successfully updated comprehensive statistics (hybrid)',
        tag: 'HybridStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to update comprehensive statistics (hybrid): $e',
        tag: 'HybridStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Clear all statistics (offline-first)
  Future<void> clearStatistics() async {
    try {
      AppLogger.debug(
        'Clearing statistics (hybrid)',
        tag: 'HybridStatisticsRepository',
      );

      // Clear local data first
      await _localRepository.resetAllData();

      // Try to clear remote data if online
      try {
        if (await _syncService.isOnline) {
          await _remoteRepository.clearStatistics();
          AppLogger.debug(
            'Successfully cleared remote statistics',
            tag: 'HybridStatisticsRepository',
          );
        } else {
          // Mark as dirty for later sync
          await _syncService.markTableDirty('user_statistics');
          AppLogger.debug(
            'Offline: marked statistics clear for sync',
            tag: 'HybridStatisticsRepository',
          );
        }
      } catch (e) {
        // Remote clear failed, mark as dirty for later sync
        await _syncService.markTableDirty('user_statistics');
        AppLogger.warning(
          'Remote clear failed, marked for later: $e',
          tag: 'HybridStatisticsRepository',
        );
      }

      AppLogger.info(
        'Successfully cleared statistics (hybrid)',
        tag: 'HybridStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to clear statistics (hybrid): $e',
        tag: 'HybridStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Initialize statistics for new user
  Future<void> initializeStatistics() async {
    try {
      AppLogger.debug(
        'Initializing statistics (hybrid)',
        tag: 'HybridStatisticsRepository',
      );

      // Initialize local statistics (create empty statistics)
      final emptyStats = GameStatistics.empty();
      await _localRepository.saveGameStatistics(emptyStats);

      // Try to initialize remote statistics if online
      try {
        if (await _syncService.isOnline) {
          await _remoteRepository.initializeStatistics();
          AppLogger.debug(
            'Successfully initialized remote statistics',
            tag: 'HybridStatisticsRepository',
          );
        } else {
          // Mark as dirty for later sync
          await _syncService.markTableDirty('user_statistics');
          AppLogger.debug(
            'Offline: marked statistics initialization for sync',
            tag: 'HybridStatisticsRepository',
          );
        }
      } catch (e) {
        // Remote initialization failed, mark as dirty for later sync
        await _syncService.markTableDirty('user_statistics');
        AppLogger.warning(
          'Remote initialization failed, marked for later: $e',
          tag: 'HybridStatisticsRepository',
        );
      }

      AppLogger.info(
        'Successfully initialized statistics (hybrid)',
        tag: 'HybridStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to initialize statistics (hybrid): $e',
        tag: 'HybridStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Perform background synchronization
  void _backgroundSync() {
    // Don't await this - let it run in background
    _performBackgroundSync();
  }

  Future<void> _performBackgroundSync() async {
    try {
      if (await _syncService.isOnline) {
        final syncStatus = await _syncService.getSyncStatus('user_statistics');

        // Only sync if data is dirty or hasn't been synced recently
        if (syncStatus == null ||
            syncStatus.needsSync ||
            !syncStatus.isRecentlySync) {
          AppLogger.debug(
            'Performing background statistics sync',
            tag: 'HybridStatisticsRepository',
          );

          await _syncService.performFullSync();
        }
      }
    } catch (e) {
      AppLogger.debug(
        'Background sync failed (non-critical): $e',
        tag: 'HybridStatisticsRepository',
      );
      // Don't rethrow - background sync failures are non-critical
    }
  }

  /// Force synchronization with remote
  Future<void> forceSyncWithRemote() async {
    try {
      AppLogger.info(
        'Forcing sync with remote',
        tag: 'HybridStatisticsRepository',
      );

      if (!await _syncService.isOnline) {
        throw Exception('Cannot sync: device is offline');
      }

      await _syncService.performFullSync();

      AppLogger.info(
        'Successfully forced sync with remote',
        tag: 'HybridStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to force sync with remote: $e',
        tag: 'HybridStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Get sync status
  Future<bool> get isSynced async {
    try {
      final syncStatus = await _syncService.getSyncStatus('user_statistics');
      return syncStatus != null && !syncStatus.needsSync;
    } catch (e) {
      AppLogger.debug(
        'Failed to get sync status: $e',
        tag: 'HybridStatisticsRepository',
      );
      return false;
    }
  }

  /// Check if device is online
  Future<bool> get isOnline => _syncService.isOnline;

  /// Get remote repository for advanced operations
  SupabaseStatisticsRepository get remoteRepository => _remoteRepository;

  /// Get local repository for advanced operations
  GameRepository get localRepository => _localRepository;

  /// Migrate guest data to authenticated user
  Future<void> migrateGuestDataToUser(String guestId, String userId) async {
    try {
      AppLogger.info(
        'Migrating guest statistics data: $guestId -> $userId',
        tag: 'HybridStatisticsRepository',
      );

      // Migrate local data first
      // Note: Local repository doesn't need migration as it's device-specific

      // Migrate remote data if online
      if (await _syncService.isOnline) {
        await _remoteRepository.migrateGuestDataToUser(guestId, userId);
        AppLogger.info(
          'Successfully migrated remote statistics data',
          tag: 'HybridStatisticsRepository',
        );
      } else {
        AppLogger.warning(
          'Cannot migrate remote data: device is offline',
          tag: 'HybridStatisticsRepository',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to migrate guest statistics data: $e',
        tag: 'HybridStatisticsRepository',
      );
      rethrow;
    }
  }
}
