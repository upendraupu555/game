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

/// Game statistics entity
class GameStatistics {
  final int gamesPlayed;
  final int gamesWon;
  final int bestScore;
  final int totalScore;
  final Duration totalPlayTime;
  final DateTime lastPlayed;

  const GameStatistics({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.bestScore,
    required this.totalScore,
    required this.totalPlayTime,
    required this.lastPlayed,
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
  }) {
    return GameStatistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestScore: bestScore ?? this.bestScore,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayed: lastPlayed ?? this.lastPlayed,
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
