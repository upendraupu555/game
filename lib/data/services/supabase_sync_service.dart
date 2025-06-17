import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game/data/models/sync_status_model.dart';
import 'package:game/data/repositories/supabase_leaderboard_repository.dart';
import 'package:game/data/repositories/supabase_statistics_repository.dart';
import 'package:game/domain/repositories/leaderboard_repository.dart';
import 'package:game/domain/repositories/game_repository.dart';
import 'package:game/core/logging/app_logger.dart';

/// Service for synchronizing data between local storage and Supabase
class SupabaseSyncService {
  final SupabaseClient _supabase;
  final LeaderboardRepository _localLeaderboard;
  final GameRepository _localStatistics;
  final SupabaseLeaderboardRepository _remoteLeaderboard;
  final SupabaseStatisticsRepository _remoteStatistics;
  final String? _userId;
  final String? _guestId;

  static const String _syncTableName = 'sync_status';
  static const String _leaderboardTable = 'leaderboard_entries';
  static const String _statisticsTable = 'user_statistics';

  final StreamController<OverallSyncStatus> _syncStatusController =
      StreamController<OverallSyncStatus>.broadcast();

  SupabaseSyncService({
    required SupabaseClient supabase,
    required LeaderboardRepository localLeaderboard,
    required GameRepository localStatistics,
    required SupabaseLeaderboardRepository remoteLeaderboard,
    required SupabaseStatisticsRepository remoteStatistics,
    String? userId,
    String? guestId,
  }) : _supabase = supabase,
       _localLeaderboard = localLeaderboard,
       _localStatistics = localStatistics,
       _remoteLeaderboard = remoteLeaderboard,
       _remoteStatistics = remoteStatistics,
       _userId = userId,
       _guestId = guestId {
    assert(
      userId != null || guestId != null,
      'Either userId or guestId must be provided',
    );
  }

  /// Stream of sync status updates
  Stream<OverallSyncStatus> get syncStatusStream =>
      _syncStatusController.stream;

  /// Check if device is online
  Future<bool> get isOnline async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check by trying to reach Supabase
      final result = await InternetAddress.lookup('supabase.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      AppLogger.debug(
        'Internet connectivity check failed: $e',
        tag: 'SyncService',
      );
      return false;
    }
  }

  /// Perform full synchronization
  Future<OverallSyncStatus> performFullSync() async {
    if (!await isOnline) {
      final status = OverallSyncStatus.offline();
      _syncStatusController.add(status);
      return status;
    }

    _syncStatusController.add(
      OverallSyncStatus.syncing(message: 'Starting sync...'),
    );

    try {
      final results = <String, SyncResult>{};

      // Sync leaderboard data
      _syncStatusController.add(
        OverallSyncStatus.syncing(message: 'Syncing leaderboard...'),
      );
      final leaderboardResult = await _syncLeaderboard();
      results[_leaderboardTable] = leaderboardResult;

      // Sync statistics data
      _syncStatusController.add(
        OverallSyncStatus.syncing(message: 'Syncing statistics...'),
      );
      final statisticsResult = await _syncStatistics();
      results[_statisticsTable] = statisticsResult;

      // Check if all syncs were successful
      final allSuccessful = results.values.every((result) => result.success);

      final status = allSuccessful
          ? OverallSyncStatus.success(
              message: 'All data synchronized successfully',
              tableResults: results,
            )
          : OverallSyncStatus.error(
              message: 'Some data failed to synchronize',
              tableResults: results,
            );

      _syncStatusController.add(status);
      return status;
    } catch (e) {
      AppLogger.error('Full sync failed: $e', tag: 'SyncService');
      final status = OverallSyncStatus.error(message: 'Sync failed: $e');
      _syncStatusController.add(status);
      return status;
    }
  }

  /// Sync leaderboard data
  Future<SyncResult> _syncLeaderboard() async {
    try {
      AppLogger.debug('Starting leaderboard sync', tag: 'SyncService');

      // Get local and remote data
      final localEntries = await _localLeaderboard.getLeaderboard();
      final remoteEntries = await _remoteLeaderboard.getLeaderboard();

      // Create maps for easier comparison
      final localMap = {for (var entry in localEntries) entry.id: entry};
      final remoteMap = {for (var entry in remoteEntries) entry.id: entry};

      int itemsProcessed = 0;

      // Upload local entries that don't exist remotely
      for (final localEntry in localEntries) {
        if (!remoteMap.containsKey(localEntry.id)) {
          await _remoteLeaderboard.addLeaderboardEntry(localEntry);
          itemsProcessed++;
          AppLogger.debug(
            'Uploaded leaderboard entry: ${localEntry.id}',
            tag: 'SyncService',
          );
        }
      }

      // Download remote entries that don't exist locally
      for (final remoteEntry in remoteEntries) {
        if (!localMap.containsKey(remoteEntry.id)) {
          await _localLeaderboard.addLeaderboardEntry(remoteEntry);
          itemsProcessed++;
          AppLogger.debug(
            'Downloaded leaderboard entry: ${remoteEntry.id}',
            tag: 'SyncService',
          );
        }
      }

      // Update sync status
      await _updateSyncStatus(_leaderboardTable);

      AppLogger.info(
        'Leaderboard sync completed: $itemsProcessed items processed',
        tag: 'SyncService',
      );
      return SyncResult.success(
        itemsProcessed: itemsProcessed,
        operation: SyncOperation.fetch,
      );
    } catch (e) {
      AppLogger.error('Leaderboard sync failed: $e', tag: 'SyncService');
      return SyncResult.failure(
        error: e.toString(),
        operation: SyncOperation.fetch,
      );
    }
  }

  /// Sync statistics data
  Future<SyncResult> _syncStatistics() async {
    try {
      AppLogger.debug('Starting statistics sync', tag: 'SyncService');

      // Get local and remote statistics
      final localStats = await _localStatistics.getGameStatistics();
      final remoteStats = await _remoteStatistics.getComprehensiveStatistics();

      // Determine which is more recent and merge if necessary
      final mergedStats = _mergeStatistics(localStats, remoteStats);

      // Update both local and remote with merged data
      await _localStatistics.saveGameStatistics(mergedStats);
      await _remoteStatistics.updateComprehensiveStatistics(mergedStats);

      // Update sync status
      await _updateSyncStatus(_statisticsTable);

      AppLogger.info('Statistics sync completed', tag: 'SyncService');
      return SyncResult.success(
        itemsProcessed: 1,
        operation: SyncOperation.update,
      );
    } catch (e) {
      AppLogger.error('Statistics sync failed: $e', tag: 'SyncService');
      return SyncResult.failure(
        error: e.toString(),
        operation: SyncOperation.update,
      );
    }
  }

  /// Merge local and remote statistics
  GameStatistics _mergeStatistics(GameStatistics local, GameStatistics remote) {
    // Use the statistics with more games played as the primary source
    // This is a simple conflict resolution strategy
    if (local.gamesPlayed >= remote.gamesPlayed) {
      return local;
    } else {
      return remote;
    }
  }

  /// Update sync status in database
  Future<void> _updateSyncStatus(String tableName) async {
    try {
      final now = DateTime.now();
      final syncStatus = {
        'user_id': _userId,
        'guest_id': _guestId,
        'table_name': tableName,
        'last_sync_at': now.toIso8601String(),
        'sync_version': 1,
        'is_dirty': false,
      };

      await _supabase
          .from(_syncTableName)
          .upsert(
            syncStatus,
            onConflict: _userId != null
                ? 'user_id,table_name'
                : 'guest_id,table_name',
          );

      AppLogger.debug('Updated sync status for $tableName', tag: 'SyncService');
    } catch (e) {
      AppLogger.error(
        'Failed to update sync status for $tableName: $e',
        tag: 'SyncService',
      );
    }
  }

  /// Get sync status for a table
  Future<SyncStatusModel?> getSyncStatus(String tableName) async {
    try {
      final response = await _supabase
          .from(_syncTableName)
          .select()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .eq('table_name', tableName)
          .maybeSingle();

      if (response == null) return null;

      return SyncStatusModel.fromJson(response);
    } catch (e) {
      AppLogger.error(
        'Failed to get sync status for $tableName: $e',
        tag: 'SyncService',
      );
      return null;
    }
  }

  /// Mark table as dirty (needs sync)
  Future<void> markTableDirty(String tableName) async {
    try {
      final syncStatus = {
        'user_id': _userId,
        'guest_id': _guestId,
        'table_name': tableName,
        'is_dirty': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_syncTableName)
          .upsert(
            syncStatus,
            onConflict: _userId != null
                ? 'user_id,table_name'
                : 'guest_id,table_name',
          );

      AppLogger.debug('Marked $tableName as dirty', tag: 'SyncService');
    } catch (e) {
      AppLogger.error(
        'Failed to mark $tableName as dirty: $e',
        tag: 'SyncService',
      );
    }
  }

  /// Migrate guest data to authenticated user
  Future<void> migrateGuestDataToUser(String guestId, String userId) async {
    try {
      AppLogger.info(
        'Starting data migration: $guestId -> $userId',
        tag: 'SyncService',
      );

      // Migrate leaderboard data
      await _remoteLeaderboard.migrateGuestDataToUser(guestId, userId);

      // Migrate statistics data
      await _remoteStatistics.migrateGuestDataToUser(guestId, userId);

      // Update sync status
      await _supabase
          .from(_syncTableName)
          .update({'user_id': userId, 'guest_id': null})
          .eq('guest_id', guestId);

      AppLogger.info(
        'Data migration completed successfully',
        tag: 'SyncService',
      );
    } catch (e) {
      AppLogger.error('Data migration failed: $e', tag: 'SyncService');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _syncStatusController.close();
  }
}
