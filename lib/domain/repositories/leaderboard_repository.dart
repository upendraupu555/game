import '../entities/leaderboard_entity.dart';

/// Repository interface for leaderboard operations
/// Following clean architecture principles - domain layer defines contracts
abstract class LeaderboardRepository {
  /// Get all leaderboard entries sorted by score (highest first)
  Future<List<LeaderboardEntry>> getLeaderboard();

  /// Get leaderboard entries grouped by game mode, sorted by score within each group
  /// Returns a map where keys are game modes and values are lists of entries
  Future<Map<String, List<LeaderboardEntry>>> getGroupedLeaderboard();

  /// Add a new leaderboard entry
  /// Automatically maintains top 50 most recent entries
  Future<void> addLeaderboardEntry(LeaderboardEntry entry);

  /// Check if a score qualifies for the leaderboard (top 50 most recent games)
  Future<bool> isScoreEligible(int score);

  /// Get the lowest score currently in the leaderboard
  Future<int?> getLowestLeaderboardScore();

  /// Clear all leaderboard entries
  Future<void> clearLeaderboard();

  /// Get leaderboard entries filtered by game mode
  Future<List<LeaderboardEntry>> getLeaderboardByGameMode(String gameMode);

  /// Get the rank of a specific score (1-based ranking)
  Future<int?> getScoreRank(int score);

  /// Check if leaderboard is empty
  Future<bool> isLeaderboardEmpty();

  /// Get total number of entries in leaderboard
  Future<int> getLeaderboardCount();
}
