import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_local_datasource.dart';
import '../models/leaderboard_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Implementation of leaderboard repository
/// Following clean architecture - data layer implements domain contracts
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardLocalDataSource _localDataSource;

  LeaderboardRepositoryImpl(this._localDataSource);

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final leaderboardModel = await _localDataSource.getLeaderboard();
      if (leaderboardModel == null) {
        return [];
      }

      final entries = leaderboardModel.toEntities();
      // Sort by score (highest first)
      entries.sort((a, b) => b.score.compareTo(a.score));

      return entries;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get leaderboard: $error',
        tag: 'LeaderboardRepository',
      );
      return [];
    }
  }

  @override
  Future<Map<String, List<LeaderboardEntry>>> getGroupedLeaderboard() async {
    try {
      final entries = await getLeaderboard();
      final Map<String, List<LeaderboardEntry>> groupedEntries = {};

      // Group entries by game mode
      for (final entry in entries) {
        if (!groupedEntries.containsKey(entry.gameMode)) {
          groupedEntries[entry.gameMode] = [];
        }
        groupedEntries[entry.gameMode]!.add(entry);
      }

      // Sort each group by score (highest first) - already sorted from getLeaderboard
      // but ensuring consistency
      for (final gameMode in groupedEntries.keys) {
        groupedEntries[gameMode]!.sort((a, b) => b.score.compareTo(a.score));
      }

      AppLogger.debug(
        '📊 Grouped leaderboard: ${groupedEntries.keys.length} game modes, ${entries.length} total entries',
        tag: 'LeaderboardRepository',
      );

      return groupedEntries;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get grouped leaderboard: $error',
        tag: 'LeaderboardRepository',
      );
      return {};
    }
  }

  @override
  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    try {
      // Get current leaderboard (this returns entries sorted by score)
      final leaderboardModel = await _localDataSource.getLeaderboard();
      final currentEntries = leaderboardModel?.toEntities() ?? [];

      // Add new entry
      final updatedEntries = List<LeaderboardEntry>.from(currentEntries);
      updatedEntries.add(entry);

      // Sort by date played (most recent first) to keep the 50 most recent games
      updatedEntries.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));

      // Keep only the most recent entries (up to maxLeaderboardEntries)
      if (updatedEntries.length > AppConstants.maxLeaderboardEntries) {
        updatedEntries.removeRange(
          AppConstants.maxLeaderboardEntries,
          updatedEntries.length,
        );
      }

      // Save updated leaderboard (entries are stored by recency, but getLeaderboard will sort by score)
      final leaderboardModelToSave = LeaderboardModel.fromEntities(
        updatedEntries,
      );
      await _localDataSource.saveLeaderboard(leaderboardModelToSave);

      AppLogger.info(
        '🏆 Added entry to leaderboard: Score ${entry.score}',
        tag: 'LeaderboardRepository',
        data: {
          'score': entry.score,
          'gameMode': entry.gameMode,
          'totalEntries': updatedEntries.length,
          'datePlayed': entry.datePlayed.toIso8601String(),
        },
      );
    } catch (error) {
      AppLogger.error(
        '❌ Failed to add leaderboard entry: $error',
        tag: 'LeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<bool> isScoreEligible(int score) async {
    try {
      // Check minimum threshold
      if (score < AppConstants.minScoreThreshold) {
        return false;
      }

      final entries = await getLeaderboard();

      // If leaderboard is not full, score is eligible
      if (entries.length < AppConstants.maxLeaderboardEntries) {
        return true;
      }

      // Check if score is higher than the lowest score
      final lowestScore = entries.last.score;
      return score > lowestScore;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to check score eligibility: $error',
        tag: 'LeaderboardRepository',
      );
      return false;
    }
  }

  @override
  Future<int?> getLowestLeaderboardScore() async {
    try {
      final entries = await getLeaderboard();
      if (entries.isEmpty) {
        return null;
      }
      return entries.last.score;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get lowest leaderboard score: $error',
        tag: 'LeaderboardRepository',
      );
      return null;
    }
  }

  @override
  Future<void> clearLeaderboard() async {
    try {
      await _localDataSource.clearLeaderboard();
      AppLogger.info('🗑️ Cleared leaderboard', tag: 'LeaderboardRepository');
    } catch (error) {
      AppLogger.error(
        '❌ Failed to clear leaderboard: $error',
        tag: 'LeaderboardRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboardByGameMode(
    String gameMode,
  ) async {
    try {
      final allEntries = await getLeaderboard();
      final filteredEntries = allEntries
          .where((entry) => entry.gameMode == gameMode)
          .toList();

      AppLogger.debug(
        '📊 Filtered leaderboard by game mode: $gameMode (${filteredEntries.length} entries)',
        tag: 'LeaderboardRepository',
      );

      return filteredEntries;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get leaderboard by game mode: $error',
        tag: 'LeaderboardRepository',
      );
      return [];
    }
  }

  @override
  Future<int?> getScoreRank(int score) async {
    try {
      final entries = await getLeaderboard();

      // Find the rank (1-based) of the score
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].score <= score) {
          return i + 1; // 1-based ranking
        }
      }

      // If score would be added to the end
      if (entries.length < AppConstants.maxLeaderboardEntries) {
        return entries.length + 1;
      }

      // Score doesn't qualify for leaderboard
      return null;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get score rank: $error',
        tag: 'LeaderboardRepository',
      );
      return null;
    }
  }

  @override
  Future<bool> isLeaderboardEmpty() async {
    try {
      final entries = await getLeaderboard();
      return entries.isEmpty;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to check if leaderboard is empty: $error',
        tag: 'LeaderboardRepository',
      );
      return true;
    }
  }

  @override
  Future<int> getLeaderboardCount() async {
    try {
      final entries = await getLeaderboard();
      return entries.length;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get leaderboard count: $error',
        tag: 'LeaderboardRepository',
      );
      return 0;
    }
  }
}
