import 'dart:convert';
import 'package:game/domain/repositories/game_repository.dart';

import '../../domain/entities/game_entity.dart';
import '../../domain/entities/powerup_entity.dart';
import 'tile_model.dart';
import 'powerup_model.dart';

/// Data model for game state serialization/deserialization
/// Following clean architecture - data layer model
class GameModel {
  final List<List<TileModel?>> board;
  final int score;
  final int bestScore;
  final bool isGameOver;
  final bool hasWon;
  final bool canUndo;
  final bool isPaused;
  final String lastPlayed;
  final List<PowerupModel> availablePowerups;
  final List<PowerupModel> activePowerups;
  final List<String> usedPowerupTypes;

  const GameModel({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.isGameOver,
    required this.hasWon,
    required this.canUndo,
    required this.isPaused,
    required this.lastPlayed,
    required this.availablePowerups,
    required this.activePowerups,
    required this.usedPowerupTypes,
  });

  /// Convert from domain entity
  factory GameModel.fromEntity(GameEntity entity) {
    final boardModel = List.generate(4, (row) {
      return List.generate(4, (col) {
        final tile = entity.board[row][col];
        return tile != null ? TileModel.fromEntity(tile) : null;
      });
    });

    final availablePowerupsModel = entity.availablePowerups
        .map((powerup) => PowerupModel.fromEntity(powerup))
        .toList();

    final activePowerupsModel = entity.activePowerups
        .map((powerup) => PowerupModel.fromEntity(powerup))
        .toList();

    final usedPowerupTypesModel = entity.usedPowerupTypes
        .map((type) => type.name)
        .toList();

    return GameModel(
      board: boardModel,
      score: entity.score,
      bestScore: entity.bestScore,
      isGameOver: entity.isGameOver,
      hasWon: entity.hasWon,
      canUndo: entity.canUndo,
      isPaused: entity.isPaused,
      lastPlayed: entity.lastPlayed.toIso8601String(),
      availablePowerups: availablePowerupsModel,
      activePowerups: activePowerupsModel,
      usedPowerupTypes: usedPowerupTypesModel,
    );
  }

  /// Convert to domain entity
  GameEntity toEntity() {
    final boardEntity = List.generate(4, (row) {
      return List.generate(4, (col) {
        final tile = board[row][col];
        return tile?.toEntity();
      });
    });

    final availablePowerupsEntity = availablePowerups
        .map((powerup) => powerup.toEntity())
        .toList();

    final activePowerupsEntity = activePowerups
        .map((powerup) => powerup.toEntity())
        .toList();

    final usedPowerupTypesEntity = usedPowerupTypes
        .map(
          (typeName) =>
              PowerupType.values.firstWhere((t) => t.name == typeName),
        )
        .toSet();

    return GameEntity(
      board: boardEntity,
      score: score,
      bestScore: bestScore,
      isGameOver: isGameOver,
      hasWon: hasWon,
      canUndo: canUndo,
      isPaused: isPaused,
      lastPlayed: DateTime.parse(lastPlayed),
      availablePowerups: availablePowerupsEntity,
      activePowerups: activePowerupsEntity,
      usedPowerupTypes: usedPowerupTypesEntity,
    );
  }

  /// Convert from JSON
  factory GameModel.fromJson(Map<String, dynamic> json) {
    final boardJson = json['board'] as List<dynamic>;
    final board = List.generate(4, (row) {
      final rowData = boardJson[row] as List<dynamic>;
      return List.generate(4, (col) {
        final tileData = rowData[col];
        return tileData != null ? TileModel.fromJson(tileData) : null;
      });
    });

    final availablePowerupsJson =
        json['availablePowerups'] as List<dynamic>? ?? [];
    final availablePowerups = availablePowerupsJson
        .map((powerupData) => PowerupModel.fromJson(powerupData))
        .toList();

    final activePowerupsJson = json['activePowerups'] as List<dynamic>? ?? [];
    final activePowerups = activePowerupsJson
        .map((powerupData) => PowerupModel.fromJson(powerupData))
        .toList();

    final usedPowerupTypesJson =
        json['usedPowerupTypes'] as List<dynamic>? ?? [];
    final usedPowerupTypes = usedPowerupTypesJson
        .map((typeName) => typeName as String)
        .toList();

    return GameModel(
      board: board,
      score: json['score'] as int,
      bestScore: json['bestScore'] as int,
      isGameOver: json['isGameOver'] as bool,
      hasWon: json['hasWon'] as bool,
      canUndo: json['canUndo'] as bool,
      isPaused: json['isPaused'] as bool? ?? false,
      lastPlayed: json['lastPlayed'] as String,
      availablePowerups: availablePowerups,
      activePowerups: activePowerups,
      usedPowerupTypes: usedPowerupTypes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final boardJson = List.generate(4, (row) {
      return List.generate(4, (col) {
        final tile = board[row][col];
        return tile?.toJson();
      });
    });

    final availablePowerupsJson = availablePowerups
        .map((powerup) => powerup.toJson())
        .toList();

    final activePowerupsJson = activePowerups
        .map((powerup) => powerup.toJson())
        .toList();

    return {
      'board': boardJson,
      'score': score,
      'bestScore': bestScore,
      'isGameOver': isGameOver,
      'hasWon': hasWon,
      'canUndo': canUndo,
      'isPaused': isPaused,
      'lastPlayed': lastPlayed,
      'availablePowerups': availablePowerupsJson,
      'activePowerups': activePowerupsJson,
      'usedPowerupTypes': usedPowerupTypes,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory GameModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GameModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameModel) return false;

    // Compare board contents
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] != other.board[row][col]) return false;
      }
    }

    return score == other.score &&
        bestScore == other.bestScore &&
        isGameOver == other.isGameOver &&
        hasWon == other.hasWon &&
        canUndo == other.canUndo &&
        lastPlayed == other.lastPlayed;
  }

  @override
  int get hashCode {
    return Object.hash(
      board.toString(),
      score,
      bestScore,
      isGameOver,
      hasWon,
      canUndo,
      lastPlayed,
    );
  }

  @override
  String toString() {
    return 'GameModel(score: $score, bestScore: $bestScore, isGameOver: $isGameOver, hasWon: $hasWon)';
  }
}

/// Data model for game statistics with comprehensive metrics
class GameStatisticsModel {
  final int gamesPlayed;
  final int gamesWon;
  final int bestScore;
  final int totalScore;
  final int totalPlayTimeSeconds;
  final String lastPlayed;

  // Game mode performance
  final Map<String, int> gameModeStats;
  final Map<String, int> gameModeWins;
  final Map<String, int> gameModeBestScores;

  // Powerup statistics
  final Map<String, int> powerupUsageCount;
  final Map<String, int> powerupSuccessCount;

  // Tile achievements
  final int highestTileValue;
  final int total2048Achievements;
  final Map<String, int>
  tileValueAchievements; // String keys for JSON compatibility

  // Recent performance (last 10 games)
  final List<Map<String, dynamic>> recentGames;

  const GameStatisticsModel({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.bestScore,
    required this.totalScore,
    required this.totalPlayTimeSeconds,
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

  /// Convert from domain entity
  factory GameStatisticsModel.fromEntity(GameStatistics entity) {
    return GameStatisticsModel(
      gamesPlayed: entity.gamesPlayed,
      gamesWon: entity.gamesWon,
      bestScore: entity.bestScore,
      totalScore: entity.totalScore,
      totalPlayTimeSeconds: entity.totalPlayTime.inSeconds,
      lastPlayed: entity.lastPlayed.toIso8601String(),
      gameModeStats: entity.gameModeStats,
      gameModeWins: entity.gameModeWins,
      gameModeBestScores: entity.gameModeBestScores,
      powerupUsageCount: entity.powerupUsageCount,
      powerupSuccessCount: entity.powerupSuccessCount,
      highestTileValue: entity.highestTileValue,
      total2048Achievements: entity.total2048Achievements,
      tileValueAchievements: entity.tileValueAchievements.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      recentGames: entity.recentGames.map((game) => game.toJson()).toList(),
    );
  }

  /// Convert to domain entity
  GameStatistics toEntity() {
    return GameStatistics(
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      bestScore: bestScore,
      totalScore: totalScore,
      totalPlayTime: Duration(seconds: totalPlayTimeSeconds),
      lastPlayed: DateTime.parse(lastPlayed),
      gameModeStats: gameModeStats,
      gameModeWins: gameModeWins,
      gameModeBestScores: gameModeBestScores,
      powerupUsageCount: powerupUsageCount,
      powerupSuccessCount: powerupSuccessCount,
      highestTileValue: highestTileValue,
      total2048Achievements: total2048Achievements,
      tileValueAchievements: tileValueAchievements.map(
        (key, value) => MapEntry(int.parse(key), value),
      ),
      recentGames: recentGames
          .map((json) => GamePerformance.fromJson(json))
          .toList(),
    );
  }

  /// Convert from JSON
  factory GameStatisticsModel.fromJson(Map<String, dynamic> json) {
    return GameStatisticsModel(
      gamesPlayed: json['gamesPlayed'] as int,
      gamesWon: json['gamesWon'] as int,
      bestScore: json['bestScore'] as int,
      totalScore: json['totalScore'] as int,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] as int,
      lastPlayed: json['lastPlayed'] as String,
      gameModeStats: Map<String, int>.from(json['gameModeStats'] ?? {}),
      gameModeWins: Map<String, int>.from(json['gameModeWins'] ?? {}),
      gameModeBestScores: Map<String, int>.from(
        json['gameModeBestScores'] ?? {},
      ),
      powerupUsageCount: Map<String, int>.from(json['powerupUsageCount'] ?? {}),
      powerupSuccessCount: Map<String, int>.from(
        json['powerupSuccessCount'] ?? {},
      ),
      highestTileValue: json['highestTileValue'] as int? ?? 0,
      total2048Achievements: json['total2048Achievements'] as int? ?? 0,
      tileValueAchievements: Map<String, int>.from(
        json['tileValueAchievements'] ?? {},
      ),
      recentGames:
          (json['recentGames'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'bestScore': bestScore,
      'totalScore': totalScore,
      'totalPlayTimeSeconds': totalPlayTimeSeconds,
      'lastPlayed': lastPlayed,
      'gameModeStats': gameModeStats,
      'gameModeWins': gameModeWins,
      'gameModeBestScores': gameModeBestScores,
      'powerupUsageCount': powerupUsageCount,
      'powerupSuccessCount': powerupSuccessCount,
      'highestTileValue': highestTileValue,
      'total2048Achievements': total2048Achievements,
      'tileValueAchievements': tileValueAchievements,
      'recentGames': recentGames,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory GameStatisticsModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GameStatisticsModel.fromJson(json);
  }
}
