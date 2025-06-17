import '../entities/game_entity.dart';
import '../entities/powerup_entity.dart';
import '../repositories/game_repository.dart';
import '../../core/logging/app_logger.dart';

/// Use case for updating comprehensive game statistics
class UpdateComprehensiveStatisticsUseCase {
  final GameRepository _repository;

  UpdateComprehensiveStatisticsUseCase(this._repository);

  Future<void> execute({
    required GameEntity gameState,
    required bool gameCompleted,
    required bool gameWon,
    required Duration playTime,
    required String gameMode,
    required List<PowerupType> powerupsUsed,
  }) async {
    try {
      final currentStats = await _repository.getGameStatistics();

      // Calculate highest tile reached
      final highestTile = _getHighestTileValue(gameState);

      // Check for 2048 achievement
      final achieved2048 = _checkFor2048Achievement(gameState);

      // Update basic statistics
      final updatedStats = currentStats.copyWith(
        gamesPlayed: gameCompleted
            ? currentStats.gamesPlayed + 1
            : currentStats.gamesPlayed,
        gamesWon: gameWon ? currentStats.gamesWon + 1 : currentStats.gamesWon,
        bestScore: gameState.score > currentStats.bestScore
            ? gameState.score
            : currentStats.bestScore,
        totalScore: currentStats.totalScore + gameState.score,
        totalPlayTime: currentStats.totalPlayTime + playTime,
        lastPlayed: DateTime.now(),

        // Game mode statistics
        gameModeStats: _updateGameModeStats(
          currentStats.gameModeStats,
          gameMode,
          gameCompleted,
        ),
        gameModeWins: _updateGameModeWins(
          currentStats.gameModeWins,
          gameMode,
          gameWon,
        ),
        gameModeBestScores: _updateGameModeBestScores(
          currentStats.gameModeBestScores,
          gameMode,
          gameState.score,
        ),

        // Powerup statistics
        powerupUsageCount: _updatePowerupUsage(
          currentStats.powerupUsageCount,
          powerupsUsed,
        ),
        powerupSuccessCount: _updatePowerupSuccess(
          currentStats.powerupSuccessCount,
          powerupsUsed,
          gameWon,
        ),

        // Tile achievements
        highestTileValue: highestTile > currentStats.highestTileValue
            ? highestTile
            : currentStats.highestTileValue,
        total2048Achievements: achieved2048
            ? currentStats.total2048Achievements + 1
            : currentStats.total2048Achievements,
        tileValueAchievements: _updateTileAchievements(
          currentStats.tileValueAchievements,
          highestTile,
        ),

        // Recent games (keep last 10)
        recentGames: _updateRecentGames(
          currentStats.recentGames,
          gameState.score,
          gameWon,
          playTime,
          gameMode,
          highestTile,
          powerupsUsed.length,
        ),
      );

      await _repository.saveGameStatistics(updatedStats);

      AppLogger.info(
        '📊 Comprehensive statistics updated',
        tag: 'ComprehensiveStatistics',
        data: {
          'gameMode': gameMode,
          'score': gameState.score,
          'won': gameWon,
          'highestTile': highestTile,
          'powerupsUsed': powerupsUsed.length,
        },
      );
    } catch (error) {
      AppLogger.error(
        '❌ Failed to update comprehensive statistics',
        tag: 'ComprehensiveStatistics',
        error: error,
      );
    }
  }

  int _getHighestTileValue(GameEntity gameState) {
    int highest = 0;
    for (final tile in gameState.allTiles) {
      if (tile.value > highest) {
        highest = tile.value;
      }
    }
    return highest;
  }

  bool _checkFor2048Achievement(GameEntity gameState) {
    return gameState.allTiles.any((tile) => tile.value >= 2048);
  }

  Map<String, int> _updateGameModeStats(
    Map<String, int> current,
    String gameMode,
    bool gameCompleted,
  ) {
    if (!gameCompleted) return current;

    final updated = Map<String, int>.from(current);
    updated[gameMode] = (updated[gameMode] ?? 0) + 1;
    return updated;
  }

  Map<String, int> _updateGameModeWins(
    Map<String, int> current,
    String gameMode,
    bool gameWon,
  ) {
    if (!gameWon) return current;

    final updated = Map<String, int>.from(current);
    updated[gameMode] = (updated[gameMode] ?? 0) + 1;
    return updated;
  }

  Map<String, int> _updateGameModeBestScores(
    Map<String, int> current,
    String gameMode,
    int score,
  ) {
    final updated = Map<String, int>.from(current);
    final currentBest = updated[gameMode] ?? 0;
    if (score > currentBest) {
      updated[gameMode] = score;
    }
    return updated;
  }

  Map<String, int> _updatePowerupUsage(
    Map<String, int> current,
    List<PowerupType> powerupsUsed,
  ) {
    final updated = Map<String, int>.from(current);
    for (final powerup in powerupsUsed) {
      updated[powerup.name] = (updated[powerup.name] ?? 0) + 1;
    }
    return updated;
  }

  Map<String, int> _updatePowerupSuccess(
    Map<String, int> current,
    List<PowerupType> powerupsUsed,
    bool gameWon,
  ) {
    if (!gameWon) return current;

    final updated = Map<String, int>.from(current);
    for (final powerup in powerupsUsed) {
      updated[powerup.name] = (updated[powerup.name] ?? 0) + 1;
    }
    return updated;
  }

  Map<int, int> _updateTileAchievements(
    Map<int, int> current,
    int highestTile,
  ) {
    final updated = Map<int, int>.from(current);

    // Track achievements for significant tile values
    final significantValues = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192];
    for (final value in significantValues) {
      if (highestTile >= value) {
        updated[value] = (updated[value] ?? 0) + 1;
      }
    }

    return updated;
  }

  List<GamePerformance> _updateRecentGames(
    List<GamePerformance> current,
    int score,
    bool won,
    Duration duration,
    String gameMode,
    int highestTile,
    int powerupsUsed,
  ) {
    final newGame = GamePerformance.fromGame(
      score: score,
      won: won,
      duration: duration,
      gameMode: gameMode,
      highestTileReached: highestTile,
      powerupsUsed: powerupsUsed,
    );

    final updated = List<GamePerformance>.from(current);
    updated.add(newGame);

    // Keep only the last 10 games
    if (updated.length > 10) {
      updated.removeAt(0);
    }

    return updated;
  }
}

/// Use case for getting comprehensive statistics with analytics
class GetComprehensiveStatisticsUseCase {
  final GameRepository _repository;

  GetComprehensiveStatisticsUseCase(this._repository);

  Future<GameStatistics> execute() async {
    return await _repository.getGameStatistics();
  }

  /// Get statistics analytics with computed insights
  Future<Map<String, dynamic>> getStatisticsAnalytics() async {
    final stats = await _repository.getGameStatistics();

    return {
      'overview': {
        'totalGames': stats.gamesPlayed,
        'winRate': stats.winRate,
        'averageScore': stats.averageScore,
        'totalPlayTime': stats.totalPlayTime.inMinutes,
        'averageGameDuration': stats.averageGameDuration.inMinutes,
      },
      'gameModesPerformance': _analyzeGameModePerformance(stats),
      'powerupAnalytics': _analyzePowerupUsage(stats),
      'achievements': _analyzeAchievements(stats),
      'recentTrend': _analyzeRecentTrend(stats),
    };
  }

  Map<String, dynamic> _analyzeGameModePerformance(GameStatistics stats) {
    final performance = <String, Map<String, dynamic>>{};

    for (final mode in stats.gameModeStats.keys) {
      final played = stats.gameModeStats[mode] ?? 0;
      final won = stats.gameModeWins[mode] ?? 0;
      final bestScore = stats.gameModeBestScores[mode] ?? 0;

      performance[mode] = {
        'gamesPlayed': played,
        'gamesWon': won,
        'winRate': played > 0 ? (won / played) * 100 : 0.0,
        'bestScore': bestScore,
      };
    }

    return performance;
  }

  Map<String, dynamic> _analyzePowerupUsage(GameStatistics stats) {
    final totalUsage = stats.powerupUsageCount.values.fold(0, (a, b) => a + b);
    final analytics = <String, dynamic>{};

    for (final powerup in stats.powerupUsageCount.keys) {
      final used = stats.powerupUsageCount[powerup] ?? 0;
      final successful = stats.powerupSuccessCount[powerup] ?? 0;

      analytics[powerup] = {
        'timesUsed': used,
        'successfulUses': successful,
        'successRate': used > 0 ? (successful / used) * 100 : 0.0,
        'usagePercentage': totalUsage > 0 ? (used / totalUsage) * 100 : 0.0,
      };
    }

    return analytics;
  }

  Map<String, dynamic> _analyzeAchievements(GameStatistics stats) {
    return {
      'highestTile': stats.highestTileValue,
      'total2048s': stats.total2048Achievements,
      'tileProgress': stats.tileValueAchievements,
      'achievementRate': stats.gamesPlayed > 0
          ? (stats.total2048Achievements / stats.gamesPlayed) * 100
          : 0.0,
    };
  }

  Map<String, dynamic> _analyzeRecentTrend(GameStatistics stats) {
    if (stats.recentGames.length < 2) {
      return {'trend': 'insufficient_data', 'direction': 0.0};
    }

    final trend = stats.recentPerformanceTrend;
    String trendDescription;

    if (trend > 10) {
      trendDescription = 'improving_significantly';
    } else if (trend > 0) {
      trendDescription = 'improving_slightly';
    } else if (trend > -10) {
      trendDescription = 'declining_slightly';
    } else {
      trendDescription = 'declining_significantly';
    }

    return {
      'trend': trendDescription,
      'direction': trend,
      'recentGamesCount': stats.recentGames.length,
    };
  }
}
