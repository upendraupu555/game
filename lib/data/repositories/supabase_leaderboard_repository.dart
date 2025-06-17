import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game/domain/entities/leaderboard_entity.dart';
import 'package:game/domain/repositories/leaderboard_repository.dart';
import 'package:game/data/models/supabase_leaderboard_model.dart';
import 'package:game/core/logging/app_logger.dart';
import 'package:game/core/constants/app_constants.dart';

/// Supabase implementation of the leaderboard repository
class SupabaseLeaderboardRepository implements LeaderboardRepository {
  final SupabaseClient _supabase;
  final String? _userId;
  final String? _guestId;

  static const String _tableName = 'leaderboard_entries';

  SupabaseLeaderboardRepository({
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

  @override
  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    try {
      AppLogger.debug(
        'Adding leaderboard entry: ${entry.score} - ${entry.gameMode}',
        tag: 'SupabaseLeaderboardRepository',
      );

      final model = SupabaseLeaderboardModel.fromEntity(
        entry,
        userId: _userId,
        guestId: _guestId,
      );

      final response = await _supabase
          .from(_tableName)
          .insert(model.toInsertJson())
          .select()
          .single();

      AppLogger.info(
        'Successfully added leaderboard entry with ID: ${response['id']}',
        tag: 'SupabaseLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to add leaderboard entry: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      AppLogger.debug(
        'Fetching leaderboard entries',
        tag: 'SupabaseLeaderboardRepository',
      );

      // Get user's entries with recency priority (last 50 entries)
      final response = await _supabase
          .from(_tableName)
          .select()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .order('date_played', ascending: false)
          .limit(AppConstants.maxLeaderboardEntries);

      final entries = (response as List)
          .map((json) => SupabaseLeaderboardModel.fromJson(json).toEntity())
          .toList();

      AppLogger.info(
        'Successfully fetched ${entries.length} leaderboard entries',
        tag: 'SupabaseLeaderboardRepository',
      );

      return entries;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch leaderboard entries: $e',
        tag: 'SupabaseLeaderboardRepository',
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
        'Fetching leaderboard entries for game mode: $gameMode',
        tag: 'SupabaseLeaderboardRepository',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .eq('game_mode', gameMode)
          .order('date_played', ascending: false)
          .limit(AppConstants.maxLeaderboardEntries);

      final entries = (response as List)
          .map((json) => SupabaseLeaderboardModel.fromJson(json).toEntity())
          .toList();

      AppLogger.info(
        'Successfully fetched ${entries.length} entries for game mode: $gameMode',
        tag: 'SupabaseLeaderboardRepository',
      );

      return entries;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch leaderboard entries for game mode $gameMode: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearLeaderboard() async {
    try {
      AppLogger.debug(
        'Clearing leaderboard entries',
        tag: 'SupabaseLeaderboardRepository',
      );

      await _supabase
          .from(_tableName)
          .delete()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId');

      AppLogger.info(
        'Successfully cleared leaderboard entries',
        tag: 'SupabaseLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to clear leaderboard entries: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }

  /// Get global leaderboard (all users)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    String? gameMode,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      AppLogger.debug(
        'Fetching global leaderboard (gameMode: $gameMode, limit: $limit)',
        tag: 'SupabaseLeaderboardRepository',
      );

      PostgrestFilterBuilder query = _supabase.from(_tableName).select();

      if (gameMode != null) {
        query = query.eq('game_mode', gameMode);
      }

      final response = await query
          .order('score', ascending: false)
          .order('date_played', ascending: false)
          .range(offset, offset + limit - 1);

      final entries = (response as List)
          .map((json) => SupabaseLeaderboardModel.fromJson(json).toEntity())
          .toList();

      AppLogger.info(
        'Successfully fetched ${entries.length} global leaderboard entries',
        tag: 'SupabaseLeaderboardRepository',
      );

      return entries;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch global leaderboard: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }

  /// Update an existing leaderboard entry
  Future<void> updateLeaderboardEntry(LeaderboardEntry entry) async {
    try {
      AppLogger.debug(
        'Updating leaderboard entry: ${entry.id}',
        tag: 'SupabaseLeaderboardRepository',
      );

      final model = SupabaseLeaderboardModel.fromEntity(
        entry,
        userId: _userId,
        guestId: _guestId,
      );

      await _supabase
          .from(_tableName)
          .update(model.toUpdateJson())
          .eq('id', entry.id);

      AppLogger.info(
        'Successfully updated leaderboard entry: ${entry.id}',
        tag: 'SupabaseLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to update leaderboard entry ${entry.id}: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }

  /// Delete a specific leaderboard entry
  Future<void> deleteLeaderboardEntry(String entryId) async {
    try {
      AppLogger.debug(
        'Deleting leaderboard entry: $entryId',
        tag: 'SupabaseLeaderboardRepository',
      );

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', entryId)
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId');

      AppLogger.info(
        'Successfully deleted leaderboard entry: $entryId',
        tag: 'SupabaseLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to delete leaderboard entry $entryId: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, List<LeaderboardEntry>>> getGroupedLeaderboard() async {
    try {
      AppLogger.debug(
        'Fetching grouped leaderboard entries',
        tag: 'SupabaseLeaderboardRepository',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .order('score', ascending: false)
          .order('date_played', ascending: false);

      final entries = (response as List)
          .map((json) => SupabaseLeaderboardModel.fromJson(json).toEntity())
          .toList();

      // Group entries by game mode
      final grouped = <String, List<LeaderboardEntry>>{};
      for (final entry in entries) {
        grouped.putIfAbsent(entry.gameMode, () => []).add(entry);
      }

      AppLogger.info(
        'Successfully fetched grouped leaderboard: ${grouped.keys.length} modes',
        tag: 'SupabaseLeaderboardRepository',
      );

      return grouped;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch grouped leaderboard: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      return {};
    }
  }

  @override
  Future<bool> isScoreEligible(int score) async {
    try {
      // For Supabase, we'll use a simple threshold approach
      // In a real implementation, you might want to check the 50th highest score
      return score > 0; // All positive scores are eligible
    } catch (e) {
      AppLogger.error(
        'Failed to check score eligibility: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      return false;
    }
  }

  @override
  Future<int?> getLowestLeaderboardScore() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('score')
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .order('score', ascending: true)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first['score'] as int;
      }
      return null;
    } catch (e) {
      AppLogger.error(
        'Failed to get lowest leaderboard score: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      return null;
    }
  }

  @override
  Future<int?> getScoreRank(int score) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('score')
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId')
          .gte('score', score)
          .order('score', ascending: false);

      return response.length;
    } catch (e) {
      AppLogger.error(
        'Failed to get score rank: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      return null;
    }
  }

  @override
  Future<bool> isLeaderboardEmpty() async {
    try {
      final count = await getLeaderboardCount();
      return count == 0;
    } catch (e) {
      AppLogger.error(
        'Failed to check if leaderboard is empty: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      return true;
    }
  }

  @override
  Future<int> getLeaderboardCount() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .or('user_id.eq.$_userId,guest_id.eq.$_guestId');

      return response.length;
    } catch (e) {
      AppLogger.error(
        'Failed to get leaderboard count: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      return 0;
    }
  }

  /// Migrate guest data to authenticated user
  Future<void> migrateGuestDataToUser(String guestId, String userId) async {
    try {
      AppLogger.debug(
        'Migrating guest leaderboard data: $guestId -> $userId',
        tag: 'SupabaseLeaderboardRepository',
      );

      await _supabase
          .from(_tableName)
          .update({'user_id': userId, 'guest_id': null})
          .eq('guest_id', guestId);

      AppLogger.info(
        'Successfully migrated guest leaderboard data',
        tag: 'SupabaseLeaderboardRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to migrate guest leaderboard data: $e',
        tag: 'SupabaseLeaderboardRepository',
      );
      rethrow;
    }
  }
}
