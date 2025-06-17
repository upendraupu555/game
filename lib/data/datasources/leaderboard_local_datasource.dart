import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Exception thrown when leaderboard data operations fail
class LeaderboardDataException implements Exception {
  final String message;
  const LeaderboardDataException(this.message);

  @override
  String toString() => 'LeaderboardDataException: $message';
}

/// Abstract interface for leaderboard local data source
abstract class LeaderboardLocalDataSource {
  Future<LeaderboardModel?> getLeaderboard();
  Future<void> saveLeaderboard(LeaderboardModel leaderboard);
  Future<void> clearLeaderboard();
}

/// Implementation of leaderboard local data source using SharedPreferences
class LeaderboardLocalDataSourceImpl implements LeaderboardLocalDataSource {
  final SharedPreferences _prefs;

  LeaderboardLocalDataSourceImpl(this._prefs);

  @override
  Future<LeaderboardModel?> getLeaderboard() async {
    try {
      final jsonString = _prefs.getString(AppConstants.leaderboardStorageKey);
      if (jsonString == null) {
        AppLogger.debug(
          '📊 No leaderboard data found in storage',
          tag: 'LeaderboardLocalDataSource',
        );
        return null;
      }

      final leaderboard = LeaderboardModel.fromJsonString(jsonString);
      AppLogger.debug(
        '📊 Loaded leaderboard with ${leaderboard.entries.length} entries',
        tag: 'LeaderboardLocalDataSource',
      );
      return leaderboard;
    } catch (e) {
      AppLogger.error(
        '❌ Failed to load leaderboard: $e',
        tag: 'LeaderboardLocalDataSource',
      );
      // If loading fails, clear corrupted data and return null
      await clearLeaderboard();
      return null;
    }
  }

  @override
  Future<void> saveLeaderboard(LeaderboardModel leaderboard) async {
    try {
      final jsonString = leaderboard.toJsonString();
      await _prefs.setString(AppConstants.leaderboardStorageKey, jsonString);
      
      AppLogger.debug(
        '💾 Saved leaderboard with ${leaderboard.entries.length} entries',
        tag: 'LeaderboardLocalDataSource',
      );
    } catch (e) {
      AppLogger.error(
        '❌ Failed to save leaderboard: $e',
        tag: 'LeaderboardLocalDataSource',
      );
      throw LeaderboardDataException('Failed to save leaderboard: $e');
    }
  }

  @override
  Future<void> clearLeaderboard() async {
    try {
      await _prefs.remove(AppConstants.leaderboardStorageKey);
      AppLogger.info(
        '🗑️ Cleared leaderboard data from storage',
        tag: 'LeaderboardLocalDataSource',
      );
    } catch (e) {
      AppLogger.error(
        '❌ Failed to clear leaderboard: $e',
        tag: 'LeaderboardLocalDataSource',
      );
      throw LeaderboardDataException('Failed to clear leaderboard: $e');
    }
  }
}
