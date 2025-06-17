import 'package:game/domain/entities/leaderboard_entity.dart';
import 'package:game/domain/repositories/leaderboard_repository.dart';
import 'package:game/data/repositories/supabase_leaderboard_repository.dart';
import 'package:game/data/services/supabase_sync_service.dart';
import 'package:game/core/logging/app_logger.dart';

/// Hybrid repository that uses both local storage and Supabase
/// Implements offline-first strategy with background synchronization
class HybridLeaderboardRepository implements LeaderboardRepository {
  final LeaderboardRepository _localRepository;
  final SupabaseLeaderboardRepository _remoteRepository;
  final SupabaseSyncService _syncService;

  HybridLeaderboardRepository({
    required LeaderboardRepository localRepository,
    required SupabaseLeaderboardRepository remoteRepository,
    required SupabaseSyncService syncService,
  }) : _localRepository = localRepository,
       _remoteRepository = remoteRepository,
       _syncService = syncService;

  @override
  Future<Map<String, List<LeaderboardEntry>>> getGroupedLeaderboard() async {
    try {
      AppLogger.debug(
        'Getting grouped leaderboard entries (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );

      // Always return local data first (offline-first)
      final localEntries = await _localRepository.getGroupedLeaderboard();

      // Try to sync with remote in background if online
      _backgroundSync();

      AppLogger.info(
        'Successfully retrieved grouped leaderboard entries (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );

      return localEntries;
    } catch (e) {
      AppLogger.error(
        'Failed to get grouped leaderboard entries (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<bool> isScoreEligible(int score) async {
    try {
      return await _localRepository.isScoreEligible(score);
    } catch (e) {
      AppLogger.error(
        'Failed to check score eligibility (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      return false;
    }
  }

  @override
  Future<int?> getLowestLeaderboardScore() async {
    try {
      return await _localRepository.getLowestLeaderboardScore();
    } catch (e) {
      AppLogger.error(
        'Failed to get lowest leaderboard score (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      return null;
    }
  }

  @override
  Future<int?> getScoreRank(int score) async {
    try {
      return await _localRepository.getScoreRank(score);
    } catch (e) {
      AppLogger.error(
        'Failed to get score rank (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      return null;
    }
  }

  @override
  Future<bool> isLeaderboardEmpty() async {
    try {
      return await _localRepository.isLeaderboardEmpty();
    } catch (e) {
      AppLogger.error(
        'Failed to check if leaderboard is empty (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      return true;
    }
  }

  @override
  Future<int> getLeaderboardCount() async {
    try {
      return await _localRepository.getLeaderboardCount();
    } catch (e) {
      AppLogger.error(
        'Failed to get leaderboard count (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      return 0;
    }
  }

  @override
  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    try {
      AppLogger.debug(
        'Adding leaderboard entry (hybrid): ${entry.score} - ${entry.gameMode}',
        tag: 'HybridLeaderboardRepository',
      );

      // Always add to local storage first (offline-first)
      await _localRepository.addLeaderboardEntry(entry);

      // Try to sync to remote if online
      try {
        if (await _syncService.isOnline) {
          await _remoteRepository.addLeaderboardEntry(entry);
          AppLogger.debug(
            'Successfully synced leaderboard entry to remote',
            tag: 'HybridLeaderboardRepository',
          );
        } else {
          // Mark as dirty for later sync
          await _syncService.markTableDirty('leaderboard_entries');
          AppLogger.debug(
            'Offline: marked leaderboard for sync',
            tag: 'HybridLeaderboardRepository',
          );
        }
      } catch (e) {
        // Remote sync failed, mark as dirty for later sync
        await _syncService.markTableDirty('leaderboard_entries');
        AppLogger.warning(
          'Remote sync failed, marked for later: $e',
          tag: 'HybridLeaderboardRepository',
        );
      }

      AppLogger.info(
        'Successfully added leaderboard entry (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to add leaderboard entry (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      AppLogger.debug(
        'Getting leaderboard entries (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );

      // Always return local data first (offline-first)
      final localEntries = await _localRepository.getLeaderboard();

      // Try to sync with remote in background if online
      _backgroundSync();

      AppLogger.info(
        'Successfully retrieved ${localEntries.length} leaderboard entries (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );

      return localEntries;
    } catch (e) {
      AppLogger.error(
        'Failed to get leaderboard entries (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboardByGameMode(
    String gameMode,
  ) async {
    try {
      AppLogger.debug(
        'Getting leaderboard entries by game mode (hybrid): $gameMode',
        tag: 'HybridLeaderboardRepository',
      );

      // Always return local data first (offline-first)
      final localEntries = await _localRepository.getLeaderboardByGameMode(
        gameMode,
      );

      // Try to sync with remote in background if online
      _backgroundSync();

      AppLogger.info(
        'Successfully retrieved ${localEntries.length} entries for $gameMode (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );

      return localEntries;
    } catch (e) {
      AppLogger.error(
        'Failed to get leaderboard entries by game mode (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearLeaderboard() async {
    try {
      AppLogger.debug(
        'Clearing leaderboard (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );

      // Clear local data first
      await _localRepository.clearLeaderboard();

      // Try to clear remote data if online
      try {
        if (await _syncService.isOnline) {
          await _remoteRepository.clearLeaderboard();
          AppLogger.debug(
            'Successfully cleared remote leaderboard',
            tag: 'HybridLeaderboardRepository',
          );
        } else {
          // Mark as dirty for later sync
          await _syncService.markTableDirty('leaderboard_entries');
          AppLogger.debug(
            'Offline: marked leaderboard clear for sync',
            tag: 'HybridLeaderboardRepository',
          );
        }
      } catch (e) {
        // Remote clear failed, mark as dirty for later sync
        await _syncService.markTableDirty('leaderboard_entries');
        AppLogger.warning(
          'Remote clear failed, marked for later: $e',
          tag: 'HybridLeaderboardRepository',
        );
      }

      AppLogger.info(
        'Successfully cleared leaderboard (hybrid)',
        tag: 'HybridLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to clear leaderboard (hybrid): $e',
        tag: 'HybridLeaderboardRepository',
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
        final syncStatus = await _syncService.getSyncStatus(
          'leaderboard_entries',
        );

        // Only sync if data is dirty or hasn't been synced recently
        if (syncStatus == null ||
            syncStatus.needsSync ||
            !syncStatus.isRecentlySync) {
          AppLogger.debug(
            'Performing background leaderboard sync',
            tag: 'HybridLeaderboardRepository',
          );

          await _syncService.performFullSync();
        }
      }
    } catch (e) {
      AppLogger.debug(
        'Background sync failed (non-critical): $e',
        tag: 'HybridLeaderboardRepository',
      );
      // Don't rethrow - background sync failures are non-critical
    }
  }

  /// Force synchronization with remote
  Future<void> forceSyncWithRemote() async {
    try {
      AppLogger.info(
        'Forcing sync with remote',
        tag: 'HybridLeaderboardRepository',
      );

      if (!await _syncService.isOnline) {
        throw Exception('Cannot sync: device is offline');
      }

      await _syncService.performFullSync();

      AppLogger.info(
        'Successfully forced sync with remote',
        tag: 'HybridLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to force sync with remote: $e',
        tag: 'HybridLeaderboardRepository',
      );
      rethrow;
    }
  }

  /// Get sync status
  Future<bool> get isSynced async {
    try {
      final syncStatus = await _syncService.getSyncStatus(
        'leaderboard_entries',
      );
      return syncStatus != null && !syncStatus.needsSync;
    } catch (e) {
      AppLogger.debug(
        'Failed to get sync status: $e',
        tag: 'HybridLeaderboardRepository',
      );
      return false;
    }
  }

  /// Check if device is online
  Future<bool> get isOnline => _syncService.isOnline;

  /// Get remote repository for advanced operations
  SupabaseLeaderboardRepository get remoteRepository => _remoteRepository;

  /// Get local repository for advanced operations
  LeaderboardRepository get localRepository => _localRepository;
}
