import '../entities/leaderboard_entity.dart';
import '../entities/game_entity.dart';
import '../repositories/leaderboard_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Use case for getting the leaderboard
class GetLeaderboardUseCase {
  final LeaderboardRepository _repository;

  GetLeaderboardUseCase(this._repository);

  Future<List<LeaderboardEntry>> execute() async {
    try {
      final leaderboard = await _repository.getLeaderboard();
      AppLogger.info(
        '📊 Retrieved leaderboard with ${leaderboard.length} entries',
        tag: 'GetLeaderboardUseCase',
      );
      return leaderboard;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get leaderboard: $error',
        tag: 'GetLeaderboardUseCase',
      );
      return [];
    }
  }
}

/// Use case for getting the leaderboard grouped by game mode
class GetGroupedLeaderboardUseCase {
  final LeaderboardRepository _repository;

  GetGroupedLeaderboardUseCase(this._repository);

  Future<Map<String, List<LeaderboardEntry>>> execute() async {
    try {
      final groupedLeaderboard = await _repository.getGroupedLeaderboard();
      final totalEntries = groupedLeaderboard.values.fold<int>(
        0,
        (sum, entries) => sum + entries.length,
      );

      AppLogger.info(
        '📊 Retrieved grouped leaderboard with ${groupedLeaderboard.keys.length} game modes, $totalEntries total entries',
        tag: 'GetGroupedLeaderboardUseCase',
      );
      return groupedLeaderboard;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get grouped leaderboard: $error',
        tag: 'GetGroupedLeaderboardUseCase',
      );
      return {};
    }
  }
}

/// Use case for adding a game to the leaderboard
class AddGameToLeaderboardUseCase {
  final LeaderboardRepository _repository;

  AddGameToLeaderboardUseCase(this._repository);

  Future<bool> execute({
    required GameEntity gameState,
    required Duration gameDuration,
  }) async {
    try {
      // Check if score meets minimum threshold
      if (gameState.score < AppConstants.minScoreThreshold) {
        AppLogger.debug(
          '📊 Score ${gameState.score} below threshold ${AppConstants.minScoreThreshold}',
          tag: 'AddGameToLeaderboardUseCase',
        );
        return false;
      }

      // Check if score is eligible for leaderboard
      final isEligible = await _repository.isScoreEligible(gameState.score);
      if (!isEligible) {
        AppLogger.debug(
          '📊 Score ${gameState.score} not eligible for leaderboard',
          tag: 'AddGameToLeaderboardUseCase',
        );
        return false;
      }

      // Determine game mode
      final gameMode = _determineGameMode(gameState);

      // Create leaderboard entry
      final entry = LeaderboardEntry.fromGame(
        score: gameState.score,
        gameMode: gameMode,
        gameDuration: gameDuration,
        gameBoard: gameState.board,
        customBaseNumber: _getCustomBaseNumber(gameState),
        timeLimit: gameState.timeLimit,
      );

      // Add to leaderboard
      await _repository.addLeaderboardEntry(entry);

      AppLogger.info(
        '🏆 Added game to leaderboard: Score ${gameState.score}, Mode: $gameMode',
        tag: 'AddGameToLeaderboardUseCase',
        data: {
          'score': gameState.score,
          'gameMode': gameMode,
          'duration': gameDuration.inSeconds,
        },
      );

      return true;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to add game to leaderboard: $error',
        tag: 'AddGameToLeaderboardUseCase',
      );
      return false;
    }
  }

  /// Determine game mode from game state
  String _determineGameMode(GameEntity gameState) {
    if (gameState.isTimeAttackMode) {
      return AppConstants.gameModeTimeAttack;
    } else if (gameState.isScenicMode) {
      return AppConstants.gameModeScenicMode;
    } else {
      return AppConstants.gameModeClassic;
    }
  }

  /// Get custom base number if applicable
  int? _getCustomBaseNumber(GameEntity gameState) {
    // Custom base number extraction logic would go here
    // This can be enhanced when custom mode is implemented
    return null;
  }
}

/// Use case for checking if a score qualifies for leaderboard
class CheckLeaderboardEligibilityUseCase {
  final LeaderboardRepository _repository;

  CheckLeaderboardEligibilityUseCase(this._repository);

  Future<bool> execute(int score) async {
    try {
      // Check minimum threshold
      if (score < AppConstants.minScoreThreshold) {
        return false;
      }

      // Check if eligible for leaderboard
      return await _repository.isScoreEligible(score);
    } catch (error) {
      AppLogger.error(
        '❌ Failed to check leaderboard eligibility: $error',
        tag: 'CheckLeaderboardEligibilityUseCase',
      );
      return false;
    }
  }
}

/// Use case for getting leaderboard by game mode
class GetLeaderboardByGameModeUseCase {
  final LeaderboardRepository _repository;

  GetLeaderboardByGameModeUseCase(this._repository);

  Future<List<LeaderboardEntry>> execute(String gameMode) async {
    try {
      final entries = await _repository.getLeaderboardByGameMode(gameMode);
      AppLogger.debug(
        '📊 Retrieved ${entries.length} entries for game mode: $gameMode',
        tag: 'GetLeaderboardByGameModeUseCase',
      );
      return entries;
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get leaderboard by game mode: $error',
        tag: 'GetLeaderboardByGameModeUseCase',
      );
      return [];
    }
  }
}

/// Use case for clearing the leaderboard
class ClearLeaderboardUseCase {
  final LeaderboardRepository _repository;

  ClearLeaderboardUseCase(this._repository);

  Future<void> execute() async {
    try {
      await _repository.clearLeaderboard();
      AppLogger.info(
        '🗑️ Leaderboard cleared successfully',
        tag: 'ClearLeaderboardUseCase',
      );
    } catch (error) {
      AppLogger.error(
        '❌ Failed to clear leaderboard: $error',
        tag: 'ClearLeaderboardUseCase',
      );
      rethrow;
    }
  }
}

/// Use case for getting score rank
class GetScoreRankUseCase {
  final LeaderboardRepository _repository;

  GetScoreRankUseCase(this._repository);

  Future<int?> execute(int score) async {
    try {
      return await _repository.getScoreRank(score);
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get score rank: $error',
        tag: 'GetScoreRankUseCase',
      );
      return null;
    }
  }
}
