import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game/domain/repositories/game_repository.dart';
import 'package:game/data/models/supabase_statistics_model.dart';
import 'package:game/core/logging/app_logger.dart';

/// Supabase implementation of the statistics repository
class SupabaseStatisticsRepository {
  final SupabaseClient _supabase;
  final String? _userId;
  final String? _guestId;

  static const String _tableName = 'user_statistics';

  SupabaseStatisticsRepository({
    required SupabaseClient supabase,
    String? userId,
    String? guestId,
  }) : _supabase = supabase,
       _userId = userId,
       _guestId = guestId {
    assert(
      userId != null || guestId != null,
      'Either userId or guestId must be provided',
    );
  }

  /// Get comprehensive statistics for the user
  Future<GameStatistics> getComprehensiveStatistics() async {
    try {
      AppLogger.debug(
        'Fetching comprehensive statistics',
        tag: 'SupabaseStatisticsRepository',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .maybeSingle();

      if (response == null) {
        // Return default statistics if none exist
        AppLogger.info(
          'No statistics found, returning default',
          tag: 'SupabaseStatisticsRepository',
        );
        return GameStatistics.empty();
      }

      final model = SupabaseStatisticsModel.fromJson(response);
      final statistics = model.toEntity();

      AppLogger.info(
        'Successfully fetched statistics: ${statistics.gamesPlayed} games played',
        tag: 'SupabaseStatisticsRepository',
      );

      return statistics;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch comprehensive statistics: $e',
        tag: 'SupabaseStatisticsRepository',
      );
      // Return default statistics on error
      return GameStatistics.empty();
    }
  }

  /// Update comprehensive statistics
  Future<void> updateComprehensiveStatistics(GameStatistics statistics) async {
    try {
      AppLogger.debug(
        'Updating comprehensive statistics: ${statistics.gamesPlayed} games',
        tag: 'SupabaseStatisticsRepository',
      );

      final model = SupabaseStatisticsModel.fromEntity(
        statistics,
        userId: _userId,
        guestId: _guestId,
      );

      // Try to update existing record first
      final updateResponse = await _supabase
          .from(_tableName)
          .update(model.toUpdateJson())
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .select();

      if (updateResponse.isEmpty) {
        // No existing record, insert new one
        AppLogger.debug(
          'No existing statistics found, inserting new record',
          tag: 'SupabaseStatisticsRepository',
        );

        await _supabase
            .from(_tableName)
            .insert(model.toInsertJson())
            .select()
            .single();
      }

      AppLogger.info(
        'Successfully updated comprehensive statistics',
        tag: 'SupabaseStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to update comprehensive statistics: $e',
        tag: 'SupabaseStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Clear all statistics
  Future<void> clearStatistics() async {
    try {
      AppLogger.debug(
        'Clearing statistics',
        tag: 'SupabaseStatisticsRepository',
      );

      await _supabase
          .from(_tableName)
          .delete()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId');

      AppLogger.info(
        'Successfully cleared statistics',
        tag: 'SupabaseStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to clear statistics: $e',
        tag: 'SupabaseStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Initialize statistics for a new user
  Future<void> initializeStatistics() async {
    try {
      AppLogger.debug(
        'Initializing statistics',
        tag: 'SupabaseStatisticsRepository',
      );

      final emptyStats = GameStatistics.empty();
      final model = SupabaseStatisticsModel.fromEntity(
        emptyStats,
        userId: _userId,
        guestId: _guestId,
      );

      await _supabase
          .from(_tableName)
          .insert(model.toInsertJson())
          .select()
          .single();

      AppLogger.info(
        'Successfully initialized statistics',
        tag: 'SupabaseStatisticsRepository',
      );
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        // Statistics already exist, this is fine
        AppLogger.debug(
          'Statistics already exist, skipping initialization',
          tag: 'SupabaseStatisticsRepository',
        );
        return;
      }

      AppLogger.error(
        'Failed to initialize statistics: $e',
        tag: 'SupabaseStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Migrate guest data to authenticated user
  Future<void> migrateGuestDataToUser(String guestId, String userId) async {
    try {
      AppLogger.debug(
        'Migrating guest statistics data: $guestId -> $userId',
        tag: 'SupabaseStatisticsRepository',
      );

      // Check if user already has statistics
      final existingUserStats = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final guestStats = await _supabase
          .from(_tableName)
          .select()
          .eq('guest_id', guestId)
          .maybeSingle();

      if (guestStats == null) {
        AppLogger.debug(
          'No guest statistics to migrate',
          tag: 'SupabaseStatisticsRepository',
        );
        return;
      }

      if (existingUserStats != null) {
        // Merge guest stats with existing user stats
        final guestModel = SupabaseStatisticsModel.fromJson(guestStats);
        final userModel = SupabaseStatisticsModel.fromJson(existingUserStats);

        final mergedStats = _mergeStatistics(
          userModel.toEntity(),
          guestModel.toEntity(),
        );
        final mergedModel = SupabaseStatisticsModel.fromEntity(
          mergedStats,
          id: userModel.id,
          userId: userId,
        );

        await _supabase
            .from(_tableName)
            .update(mergedModel.toUpdateJson())
            .eq('user_id', userId);

        // Delete guest statistics
        await _supabase.from(_tableName).delete().eq('guest_id', guestId);
      } else {
        // Simply transfer guest stats to user
        await _supabase
            .from(_tableName)
            .update({'user_id': userId, 'guest_id': null})
            .eq('guest_id', guestId);
      }

      AppLogger.info(
        'Successfully migrated guest statistics data',
        tag: 'SupabaseStatisticsRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to migrate guest statistics data: $e',
        tag: 'SupabaseStatisticsRepository',
      );
      rethrow;
    }
  }

  /// Merge two statistics objects
  GameStatistics _mergeStatistics(GameStatistics user, GameStatistics guest) {
    return GameStatistics(
      gamesPlayed: user.gamesPlayed + guest.gamesPlayed,
      gamesWon: user.gamesWon + guest.gamesWon,
      bestScore: user.bestScore > guest.bestScore
          ? user.bestScore
          : guest.bestScore,
      totalScore: user.totalScore + guest.totalScore,
      totalPlayTime: user.totalPlayTime + guest.totalPlayTime,
      lastPlayed: user.lastPlayed.isAfter(guest.lastPlayed)
          ? user.lastPlayed
          : guest.lastPlayed,
      gameModeStats: _mergeMaps(user.gameModeStats, guest.gameModeStats),
      gameModeWins: _mergeMaps(user.gameModeWins, guest.gameModeWins),
      gameModeBestScores: _mergeMaxMaps(
        user.gameModeBestScores,
        guest.gameModeBestScores,
      ),
      powerupUsageCount: _mergeMaps(
        user.powerupUsageCount,
        guest.powerupUsageCount,
      ),
      powerupSuccessCount: _mergeMaps(
        user.powerupSuccessCount,
        guest.powerupSuccessCount,
      ),
      highestTileValue: user.highestTileValue > guest.highestTileValue
          ? user.highestTileValue
          : guest.highestTileValue,
      total2048Achievements:
          user.total2048Achievements + guest.total2048Achievements,
      tileValueAchievements: _mergeTileAchievements(
        user.tileValueAchievements,
        guest.tileValueAchievements,
      ),
      recentGames: [
        ...user.recentGames,
        ...guest.recentGames,
      ].take(10).toList(),
    );
  }

  /// Merge two maps by adding values
  Map<String, int> _mergeMaps(Map<String, int> map1, Map<String, int> map2) {
    final result = Map<String, int>.from(map1);
    for (final entry in map2.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
    return result;
  }

  /// Merge two maps by taking maximum values
  Map<String, int> _mergeMaxMaps(Map<String, int> map1, Map<String, int> map2) {
    final result = Map<String, int>.from(map1);
    for (final entry in map2.entries) {
      result[entry.key] = result[entry.key] != null
          ? (result[entry.key]! > entry.value
                ? result[entry.key]!
                : entry.value)
          : entry.value;
    }
    return result;
  }

  /// Merge two tile achievement maps (Map<int, int>)
  Map<int, int> _mergeTileAchievements(Map<int, int> map1, Map<int, int> map2) {
    final result = Map<int, int>.from(map1);
    for (final entry in map2.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
    return result;
  }
}
