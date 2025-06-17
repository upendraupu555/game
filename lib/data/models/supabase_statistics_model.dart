import 'package:game/domain/repositories/game_repository.dart';

/// Supabase model for comprehensive user statistics
class SupabaseStatisticsModel {
  final String id;
  final String? userId;
  final String? guestId;
  final int gamesPlayed;
  final int gamesWon;
  final int bestScore;
  final int totalScore;
  final int totalPlayTimeSeconds;
  final DateTime? lastPlayed;
  final Map<String, dynamic> gameModeStats;
  final Map<String, dynamic> gameModeWins;
  final Map<String, dynamic> gameModeBestScores;
  final Map<String, dynamic> powerupUsageCount;
  final Map<String, dynamic> powerupSuccessCount;
  final int highestTileValue;
  final int total2048Achievements;
  final Map<String, dynamic> tileValueAchievements;
  final List<dynamic> recentGames;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupabaseStatisticsModel({
    required this.id,
    this.userId,
    this.guestId,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.bestScore,
    required this.totalScore,
    required this.totalPlayTimeSeconds,
    this.lastPlayed,
    required this.gameModeStats,
    required this.gameModeWins,
    required this.gameModeBestScores,
    required this.powerupUsageCount,
    required this.powerupSuccessCount,
    required this.highestTileValue,
    required this.total2048Achievements,
    required this.tileValueAchievements,
    required this.recentGames,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from Supabase JSON response
  factory SupabaseStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SupabaseStatisticsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      guestId: json['guest_id'] as String?,
      gamesPlayed: json['games_played'] as int,
      gamesWon: json['games_won'] as int,
      bestScore: json['best_score'] as int,
      totalScore: json['total_score'] as int,
      totalPlayTimeSeconds: json['total_play_time_seconds'] as int,
      lastPlayed: json['last_played'] != null
          ? DateTime.parse(json['last_played'] as String)
          : null,
      gameModeStats: json['game_mode_stats'] as Map<String, dynamic>,
      gameModeWins: json['game_mode_wins'] as Map<String, dynamic>,
      gameModeBestScores: json['game_mode_best_scores'] as Map<String, dynamic>,
      powerupUsageCount: json['powerup_usage_count'] as Map<String, dynamic>,
      powerupSuccessCount:
          json['powerup_success_count'] as Map<String, dynamic>,
      highestTileValue: json['highest_tile_value'] as int,
      total2048Achievements: json['total_2048_achievements'] as int,
      tileValueAchievements:
          json['tile_value_achievements'] as Map<String, dynamic>,
      recentGames: json['recent_games'] as List<dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to Supabase JSON for insertion/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'guest_id': guestId,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'best_score': bestScore,
      'total_score': totalScore,
      'total_play_time_seconds': totalPlayTimeSeconds,
      'last_played': lastPlayed?.toIso8601String(),
      'game_mode_stats': gameModeStats,
      'game_mode_wins': gameModeWins,
      'game_mode_best_scores': gameModeBestScores,
      'powerup_usage_count': powerupUsageCount,
      'powerup_success_count': powerupSuccessCount,
      'highest_tile_value': highestTileValue,
      'total_2048_achievements': total2048Achievements,
      'tile_value_achievements': tileValueAchievements,
      'recent_games': recentGames,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  GameStatistics toEntity() {
    return GameStatistics(
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      bestScore: bestScore,
      totalScore: totalScore,
      totalPlayTime: Duration(seconds: totalPlayTimeSeconds),
      lastPlayed: lastPlayed ?? DateTime.now(),
      gameModeStats: Map<String, int>.from(gameModeStats),
      gameModeWins: Map<String, int>.from(gameModeWins),
      gameModeBestScores: Map<String, int>.from(gameModeBestScores),
      powerupUsageCount: Map<String, int>.from(powerupUsageCount),
      powerupSuccessCount: Map<String, int>.from(powerupSuccessCount),
      highestTileValue: highestTileValue,
      total2048Achievements: total2048Achievements,
      tileValueAchievements: _convertTileAchievements(tileValueAchievements),
      recentGames: _convertRecentGames(recentGames),
    );
  }

  /// Create from domain entity
  factory SupabaseStatisticsModel.fromEntity(
    GameStatistics entity, {
    String? id,
    String? userId,
    String? guestId,
  }) {
    final now = DateTime.now();
    return SupabaseStatisticsModel(
      id: id ?? '',
      userId: userId,
      guestId: guestId,
      gamesPlayed: entity.gamesPlayed,
      gamesWon: entity.gamesWon,
      bestScore: entity.bestScore,
      totalScore: entity.totalScore,
      totalPlayTimeSeconds: entity.totalPlayTime.inSeconds,
      lastPlayed: entity.lastPlayed,
      gameModeStats: entity.gameModeStats,
      gameModeWins: entity.gameModeWins,
      gameModeBestScores: entity.gameModeBestScores,
      powerupUsageCount: entity.powerupUsageCount,
      powerupSuccessCount: entity.powerupSuccessCount,
      highestTileValue: entity.highestTileValue,
      total2048Achievements: entity.total2048Achievements,
      tileValueAchievements: _convertTileAchievementsToJson(
        entity.tileValueAchievements,
      ),
      recentGames: _convertRecentGamesToJson(entity.recentGames),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create for insertion (without ID and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'guest_id': guestId,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'best_score': bestScore,
      'total_score': totalScore,
      'total_play_time_seconds': totalPlayTimeSeconds,
      'last_played': lastPlayed?.toIso8601String(),
      'game_mode_stats': gameModeStats,
      'game_mode_wins': gameModeWins,
      'game_mode_best_scores': gameModeBestScores,
      'powerup_usage_count': powerupUsageCount,
      'powerup_success_count': powerupSuccessCount,
      'highest_tile_value': highestTileValue,
      'total_2048_achievements': total2048Achievements,
      'tile_value_achievements': tileValueAchievements,
      'recent_games': recentGames,
    };
  }

  /// Create for update (only updatable fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'best_score': bestScore,
      'total_score': totalScore,
      'total_play_time_seconds': totalPlayTimeSeconds,
      'last_played': lastPlayed?.toIso8601String(),
      'game_mode_stats': gameModeStats,
      'game_mode_wins': gameModeWins,
      'game_mode_best_scores': gameModeBestScores,
      'powerup_usage_count': powerupUsageCount,
      'powerup_success_count': powerupSuccessCount,
      'highest_tile_value': highestTileValue,
      'total_2048_achievements': total2048Achievements,
      'tile_value_achievements': tileValueAchievements,
      'recent_games': recentGames,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copy with new values
  SupabaseStatisticsModel copyWith({
    String? id,
    String? userId,
    String? guestId,
    int? gamesPlayed,
    int? gamesWon,
    int? bestScore,
    int? totalScore,
    int? totalPlayTimeSeconds,
    DateTime? lastPlayed,
    Map<String, dynamic>? gameModeStats,
    Map<String, dynamic>? gameModeWins,
    Map<String, dynamic>? gameModeBestScores,
    Map<String, dynamic>? powerupUsageCount,
    Map<String, dynamic>? powerupSuccessCount,
    int? highestTileValue,
    int? total2048Achievements,
    Map<String, dynamic>? tileValueAchievements,
    List<dynamic>? recentGames,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseStatisticsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      guestId: guestId ?? this.guestId,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestScore: bestScore ?? this.bestScore,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SupabaseStatisticsModel('
        'id: $id, '
        'userId: $userId, '
        'guestId: $guestId, '
        'gamesPlayed: $gamesPlayed, '
        'gamesWon: $gamesWon, '
        'bestScore: $bestScore'
        ')';
  }

  /// Convert tile achievements from JSON to Map<int, int>
  static Map<int, int> _convertTileAchievements(Map<String, dynamic> json) {
    try {
      final result = <int, int>{};
      for (final entry in json.entries) {
        final key = int.tryParse(entry.key);
        final value = entry.value;
        if (key != null && value is int) {
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      return <int, int>{};
    }
  }

  /// Convert tile achievements from Map<int, int> to JSON
  static Map<String, dynamic> _convertTileAchievementsToJson(
    Map<int, int> achievements,
  ) {
    try {
      final result = <String, dynamic>{};
      for (final entry in achievements.entries) {
        result[entry.key.toString()] = entry.value;
      }
      return result;
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// Convert recent games from JSON to List<GamePerformance>
  static List<GamePerformance> _convertRecentGames(List<dynamic> json) {
    try {
      return json.map((game) {
        if (game is Map<String, dynamic>) {
          return GamePerformance(
            score: game['score'] ?? 0,
            gameMode: game['gameMode'] ?? 'Classic',
            duration: Duration(seconds: game['durationSeconds'] ?? 0),
            datePlayed:
                DateTime.tryParse(game['datePlayed'] ?? '') ?? DateTime.now(),
            won: game['won'] ?? false,
            highestTileReached: game['highestTileReached'] ?? 2,
            powerupsUsed: game['powerupsUsed'] ?? 0,
          );
        }
        return GamePerformance(
          score: 0,
          gameMode: 'Classic',
          duration: Duration.zero,
          datePlayed: DateTime.now(),
          won: false,
          highestTileReached: 2,
          powerupsUsed: 0,
        );
      }).toList();
    } catch (e) {
      return <GamePerformance>[];
    }
  }

  /// Convert recent games from List<GamePerformance> to JSON
  static List<dynamic> _convertRecentGamesToJson(List<GamePerformance> games) {
    try {
      return games
          .map(
            (game) => {
              'score': game.score,
              'gameMode': game.gameMode,
              'durationSeconds': game.duration.inSeconds,
              'datePlayed': game.datePlayed.toIso8601String(),
              'won': game.won,
              'highestTileReached': game.highestTileReached,
              'powerupsUsed': game.powerupsUsed,
            },
          )
          .toList();
    } catch (e) {
      return <dynamic>[];
    }
  }
}
