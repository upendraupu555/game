import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';

/// Local data source for game state persistence
/// Following clean architecture - data layer
abstract class GameLocalDataSource {
  Future<void> saveGameState(GameModel gameState);
  Future<GameModel?> loadGameState();
  Future<void> clearGameState();
  Future<void> saveBestScore(int score);
  Future<int> loadBestScore();
  Future<void> saveGameStatistics(GameStatisticsModel statistics);
  Future<GameStatisticsModel?> loadGameStatistics();
  Future<void> clearAllData();
}

/// Implementation of game local data source using SharedPreferences
class GameLocalDataSourceImpl implements GameLocalDataSource {
  final SharedPreferences _prefs;

  // Storage keys
  static const String _gameStateKey = 'game_state';
  static const String _bestScoreKey = 'best_score';
  static const String _gameStatisticsKey = 'game_statistics';

  GameLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveGameState(GameModel gameState) async {
    try {
      final jsonString = gameState.toJsonString();
      await _prefs.setString(_gameStateKey, jsonString);
    } catch (e) {
      throw GameDataException('Failed to save game state: $e');
    }
  }

  @override
  Future<GameModel?> loadGameState() async {
    try {
      final jsonString = _prefs.getString(_gameStateKey);
      if (jsonString == null) return null;

      return GameModel.fromJsonString(jsonString);
    } catch (e) {
      // If loading fails, clear corrupted data
      await clearGameState();
      return null;
    }
  }

  @override
  Future<void> clearGameState() async {
    try {
      await _prefs.remove(_gameStateKey);
    } catch (e) {
      throw GameDataException('Failed to clear game state: $e');
    }
  }

  @override
  Future<void> saveBestScore(int score) async {
    try {
      final currentBest = await loadBestScore();
      if (score > currentBest) {
        await _prefs.setInt(_bestScoreKey, score);
      }
    } catch (e) {
      throw GameDataException('Failed to save best score: $e');
    }
  }

  @override
  Future<int> loadBestScore() async {
    try {
      return _prefs.getInt(_bestScoreKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> saveGameStatistics(GameStatisticsModel statistics) async {
    try {
      final jsonString = statistics.toJsonString();
      await _prefs.setString(_gameStatisticsKey, jsonString);
    } catch (e) {
      throw GameDataException('Failed to save game statistics: $e');
    }
  }

  @override
  Future<GameStatisticsModel?> loadGameStatistics() async {
    try {
      final jsonString = _prefs.getString(_gameStatisticsKey);
      if (jsonString == null) {
        // Return empty statistics if none exist
        return GameStatisticsModel(
          gamesPlayed: 0,
          gamesWon: 0,
          bestScore: 0,
          totalScore: 0,
          totalPlayTimeSeconds: 0,
          lastPlayed: DateTime.now().toIso8601String(),
        );
      }

      return GameStatisticsModel.fromJsonString(jsonString);
    } catch (e) {
      // Return empty statistics if loading fails
      return GameStatisticsModel(
        gamesPlayed: 0,
        gamesWon: 0,
        bestScore: 0,
        totalScore: 0,
        totalPlayTimeSeconds: 0,
        lastPlayed: DateTime.now().toIso8601String(),
      );
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await Future.wait([
        _prefs.remove(_gameStateKey),
        _prefs.remove(_bestScoreKey),
        _prefs.remove(_gameStatisticsKey),
      ]);
    } catch (e) {
      throw GameDataException('Failed to clear all data: $e');
    }
  }
}

/// Exception for game data operations
class GameDataException implements Exception {
  final String message;

  const GameDataException(this.message);

  @override
  String toString() => 'GameDataException: $message';
}
