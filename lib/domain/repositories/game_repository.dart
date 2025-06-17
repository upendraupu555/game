import '../entities/game_entity.dart';
import '../entities/tile_entity.dart';

/// Abstract repository interface for game data operations
/// Following clean architecture principles - domain layer defines the contract
abstract class GameRepository {
  /// Initialize a new game
  Future<GameEntity> initializeGame();

  /// Save current game state
  Future<void> saveGameState(GameEntity gameState);

  /// Load saved game state
  Future<GameEntity?> loadGameState();

  /// Clear saved game state
  Future<void> clearGameState();

  /// Save best score
  Future<void> saveBestScore(int score);

  /// Load best score
  Future<int> loadBestScore();

  /// Move tiles in the specified direction
  GameEntity moveTiles(GameEntity currentState, MoveDirection direction);

  /// Add a random tile to the board
  GameEntity addRandomTile(GameEntity currentState);

  /// Check if the game is over
  bool isGameOver(GameEntity gameState);

  /// Check if the player has won
  bool hasPlayerWon(GameEntity gameState);

  /// Calculate score for a move
  int calculateMoveScore(GameEntity beforeState, GameEntity afterState);

  /// Get game statistics
  Future<GameStatistics> getGameStatistics();

  /// Save game statistics
  Future<void> saveGameStatistics(GameStatistics statistics);

  /// Reset all game data
  Future<void> resetAllData();
}

/// Individual game performance record for recent games tracking
class GamePerformance {
  final int score;
  final bool won;
  final Duration duration;
  final String gameMode;
  final DateTime datePlayed;
  final int highestTileReached;
  final int powerupsUsed;

  const GamePerformance({
    required this.score,
    required this.won,
    required this.duration,
    required this.gameMode,
    required this.datePlayed,
    required this.highestTileReached,
    required this.powerupsUsed,
  });

  factory GamePerformance.fromGame({
    required int score,
    required bool won,
    required Duration duration,
    required String gameMode,
    required int highestTileReached,
    required int powerupsUsed,
  }) {
    return GamePerformance(
      score: score,
      won: won,
      duration: duration,
      gameMode: gameMode,
      datePlayed: DateTime.now(),
      highestTileReached: highestTileReached,
      powerupsUsed: powerupsUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'won': won,
      'duration': duration.inSeconds,
      'gameMode': gameMode,
      'datePlayed': datePlayed.toIso8601String(),
      'highestTileReached': highestTileReached,
      'powerupsUsed': powerupsUsed,
    };
  }

  factory GamePerformance.fromJson(Map<String, dynamic> json) {
    return GamePerformance(
      score: json['score'] as int,
      won: json['won'] as bool,
      duration: Duration(seconds: json['duration'] as int),
      gameMode: json['gameMode'] as String,
      datePlayed: DateTime.parse(json['datePlayed'] as String),
      highestTileReached: json['highestTileReached'] as int,
      powerupsUsed: json['powerupsUsed'] as int,
    );
  }
}

/// Game statistics entity with comprehensive metrics
class GameStatistics {
  final int gamesPlayed;
  final int gamesWon;
  final int bestScore;
  final int totalScore;
  final Duration totalPlayTime;
  final DateTime lastPlayed;

  // Game mode performance
  final Map<String, int> gameModeStats; // gameMode -> games played
  final Map<String, int> gameModeWins; // gameMode -> games won
  final Map<String, int> gameModeBestScores; // gameMode -> best score

  // Powerup statistics
  final Map<String, int> powerupUsageCount; // powerupType -> usage count
  final Map<String, int> powerupSuccessCount; // powerupType -> successful uses

  // Tile achievements
  final int highestTileValue;
  final int total2048Achievements;
  final Map<int, int> tileValueAchievements; // tileValue -> times achieved

  // Recent performance (last 10 games)
  final List<GamePerformance> recentGames;

  const GameStatistics({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.bestScore,
    required this.totalScore,
    required this.totalPlayTime,
    required this.lastPlayed,
    this.gameModeStats = const {},
    this.gameModeWins = const {},
    this.gameModeBestScores = const {},
    this.powerupUsageCount = const {},
    this.powerupSuccessCount = const {},
    this.highestTileValue = 0,
    this.total2048Achievements = 0,
    this.tileValueAchievements = const {},
    this.recentGames = const [],
  });

  factory GameStatistics.empty() {
    return GameStatistics(
      gamesPlayed: 0,
      gamesWon: 0,
      bestScore: 0,
      totalScore: 0,
      totalPlayTime: Duration.zero,
      lastPlayed: DateTime.now(),
    );
  }

  GameStatistics copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? bestScore,
    int? totalScore,
    Duration? totalPlayTime,
    DateTime? lastPlayed,
    Map<String, int>? gameModeStats,
    Map<String, int>? gameModeWins,
    Map<String, int>? gameModeBestScores,
    Map<String, int>? powerupUsageCount,
    Map<String, int>? powerupSuccessCount,
    int? highestTileValue,
    int? total2048Achievements,
    Map<int, int>? tileValueAchievements,
    List<GamePerformance>? recentGames,
  }) {
    return GameStatistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestScore: bestScore ?? this.bestScore,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      gameModeStats: gameModeStats ?? this.gameModeStats,
      gameModeWins: gameModeWins ?? this.gameModeWins,
      gameModeBestScores: gameModeBestScores ?? this.gameModeBestScores,
      powerupUsageCount: powerupUsageCount ?? this.powerupUsageCount,
      powerupSuccessCount: powerupSuccessCount ?? this.powerupSuccessCount,
      highestTileValue: highestTileValue ?? this.highestTileValue,
      total2048Achievements:
          total2048Achievements ?? this.total2048Achievements,
      tileValueAchievements:
          tileValueAchievements ?? this.tileValueAchievements,
      recentGames: recentGames ?? this.recentGames,
    );
  }

  /// Calculate win rate as percentage
  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (gamesWon / gamesPlayed) * 100;
  }

  /// Calculate average score
  double get averageScore {
    if (gamesPlayed == 0) return 0.0;
    return totalScore / gamesPlayed;
  }

  /// Calculate average game duration
  Duration get averageGameDuration {
    if (gamesPlayed == 0) return Duration.zero;
    return Duration(seconds: totalPlayTime.inSeconds ~/ gamesPlayed);
  }

  /// Get win rate for specific game mode
  double getGameModeWinRate(String gameMode) {
    final played = gameModeStats[gameMode] ?? 0;
    final won = gameModeWins[gameMode] ?? 0;
    if (played == 0) return 0.0;
    return (won / played) * 100;
  }

  /// Get most used powerup
  String? get mostUsedPowerup {
    if (powerupUsageCount.isEmpty) return null;
    return powerupUsageCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get powerup success rate
  double getPowerupSuccessRate(String powerupType) {
    final used = powerupUsageCount[powerupType] ?? 0;
    final successful = powerupSuccessCount[powerupType] ?? 0;
    if (used == 0) return 0.0;
    return (successful / used) * 100;
  }

  /// Get recent performance trend (positive = improving, negative = declining)
  double get recentPerformanceTrend {
    if (recentGames.length < 2) return 0.0;

    final recentScores = recentGames.map((g) => g.score).toList();
    final firstHalf = recentScores.take(recentScores.length ~/ 2).toList();
    final secondHalf = recentScores.skip(recentScores.length ~/ 2).toList();

    if (firstHalf.isEmpty || secondHalf.isEmpty) return 0.0;

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    return ((secondAvg - firstAvg) / firstAvg) * 100;
  }

  /// Format total play time as human readable string
  String get formattedPlayTime {
    final hours = totalPlayTime.inHours;
    final minutes = totalPlayTime.inMinutes % 60;
    final seconds = totalPlayTime.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStatistics &&
        other.gamesPlayed == gamesPlayed &&
        other.gamesWon == gamesWon &&
        other.bestScore == bestScore &&
        other.totalScore == totalScore &&
        other.totalPlayTime == totalPlayTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      gamesPlayed,
      gamesWon,
      bestScore,
      totalScore,
      totalPlayTime,
    );
  }

  @override
  String toString() {
    return 'GameStatistics(played: $gamesPlayed, won: $gamesWon, bestScore: $bestScore, winRate: ${winRate.toStringAsFixed(1)}%)';
  }
}
