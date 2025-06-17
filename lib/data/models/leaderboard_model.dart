import 'dart:convert';
import '../../domain/entities/leaderboard_entity.dart';

/// Data model for leaderboard entry
/// Following clean architecture - data layer models for persistence
class LeaderboardEntryModel {
  final String id;
  final int score;
  final String datePlayed; // ISO 8601 string
  final String gameMode;
  final int gameDurationSeconds;
  final List<List<TileSnapshotModel?>> boardSnapshot;
  final int? customBaseNumber;
  final int? timeLimit;

  const LeaderboardEntryModel({
    required this.id,
    required this.score,
    required this.datePlayed,
    required this.gameMode,
    required this.gameDurationSeconds,
    required this.boardSnapshot,
    this.customBaseNumber,
    this.timeLimit,
  });

  /// Convert from domain entity
  factory LeaderboardEntryModel.fromEntity(LeaderboardEntry entity) {
    final boardSnapshot = entity.boardSnapshot.map((row) {
      return row.map((tile) {
        if (tile == null) return null;
        return TileSnapshotModel.fromEntity(tile);
      }).toList();
    }).toList();

    return LeaderboardEntryModel(
      id: entity.id,
      score: entity.score,
      datePlayed: entity.datePlayed.toIso8601String(),
      gameMode: entity.gameMode,
      gameDurationSeconds: entity.gameDuration.inSeconds,
      boardSnapshot: boardSnapshot,
      customBaseNumber: entity.customBaseNumber,
      timeLimit: entity.timeLimit,
    );
  }

  /// Convert to domain entity
  LeaderboardEntry toEntity() {
    final boardSnapshot = this.boardSnapshot.map((row) {
      return row.map((tile) {
        if (tile == null) return null;
        return tile.toEntity();
      }).toList();
    }).toList();

    return LeaderboardEntry(
      id: id,
      score: score,
      datePlayed: DateTime.parse(datePlayed),
      gameMode: gameMode,
      gameDuration: Duration(seconds: gameDurationSeconds),
      boardSnapshot: boardSnapshot,
      customBaseNumber: customBaseNumber,
      timeLimit: timeLimit,
    );
  }

  /// Convert from JSON
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    final boardSnapshotJson = json['boardSnapshot'] as List<dynamic>;
    final boardSnapshot = boardSnapshotJson.map((rowJson) {
      final row = rowJson as List<dynamic>;
      return row.map((tileJson) {
        if (tileJson == null) return null;
        return TileSnapshotModel.fromJson(tileJson as Map<String, dynamic>);
      }).toList();
    }).toList();

    return LeaderboardEntryModel(
      id: json['id'] as String,
      score: json['score'] as int,
      datePlayed: json['datePlayed'] as String,
      gameMode: json['gameMode'] as String,
      gameDurationSeconds: json['gameDurationSeconds'] as int,
      boardSnapshot: boardSnapshot,
      customBaseNumber: json['customBaseNumber'] as int?,
      timeLimit: json['timeLimit'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final boardSnapshotJson = boardSnapshot.map((row) {
      return row.map((tile) => tile?.toJson()).toList();
    }).toList();

    return {
      'id': id,
      'score': score,
      'datePlayed': datePlayed,
      'gameMode': gameMode,
      'gameDurationSeconds': gameDurationSeconds,
      'boardSnapshot': boardSnapshotJson,
      'customBaseNumber': customBaseNumber,
      'timeLimit': timeLimit,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory LeaderboardEntryModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LeaderboardEntryModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntryModel &&
        other.id == id &&
        other.score == score &&
        other.datePlayed == datePlayed &&
        other.gameMode == gameMode &&
        other.gameDurationSeconds == gameDurationSeconds &&
        other.customBaseNumber == customBaseNumber &&
        other.timeLimit == timeLimit;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      score,
      datePlayed,
      gameMode,
      gameDurationSeconds,
      customBaseNumber,
      timeLimit,
    );
  }

  @override
  String toString() {
    return 'LeaderboardEntryModel(id: $id, score: $score, gameMode: $gameMode)';
  }
}

/// Data model for tile snapshot
class TileSnapshotModel {
  final int value;
  final bool isBlocker;

  const TileSnapshotModel({required this.value, required this.isBlocker});

  /// Convert from domain entity
  factory TileSnapshotModel.fromEntity(TileSnapshot entity) {
    return TileSnapshotModel(value: entity.value, isBlocker: entity.isBlocker);
  }

  /// Convert to domain entity
  TileSnapshot toEntity() {
    return TileSnapshot(value: value, isBlocker: isBlocker);
  }

  /// Convert from JSON
  factory TileSnapshotModel.fromJson(Map<String, dynamic> json) {
    // Use safe parsing to handle potential type mismatches
    try {
      return TileSnapshotModel(
        value: json['value'] as int,
        isBlocker: json['isBlocker'] as bool,
      );
    } catch (e) {
      // Fallback to safe parsing if direct casting fails
      return TileSnapshotModel(
        value: _safeParseInt(json['value']),
        isBlocker: _safeParseBool(json['isBlocker']),
      );
    }
  }

  /// Safely parse integer from dynamic value
  static int _safeParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 2;
    if (value is double) return value.round();
    return 2; // Default fallback
  }

  /// Safely parse boolean from dynamic value
  static bool _safeParseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false; // Default fallback
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'value': value, 'isBlocker': isBlocker};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileSnapshotModel &&
        other.value == value &&
        other.isBlocker == isBlocker;
  }

  @override
  int get hashCode => Object.hash(value, isBlocker);

  @override
  String toString() {
    return 'TileSnapshotModel(value: $value, isBlocker: $isBlocker)';
  }
}

/// Data model for leaderboard collection
class LeaderboardModel {
  final List<LeaderboardEntryModel> entries;

  const LeaderboardModel({required this.entries});

  /// Convert from domain entities
  factory LeaderboardModel.fromEntities(List<LeaderboardEntry> entities) {
    final entries = entities.map(LeaderboardEntryModel.fromEntity).toList();
    return LeaderboardModel(entries: entries);
  }

  /// Convert to domain entities
  List<LeaderboardEntry> toEntities() {
    return entries.map((model) => model.toEntity()).toList();
  }

  /// Convert from JSON
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['entries'] as List<dynamic>;
    final entries = entriesJson
        .map(
          (entryJson) =>
              LeaderboardEntryModel.fromJson(entryJson as Map<String, dynamic>),
        )
        .toList();

    return LeaderboardModel(entries: entries);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'entries': entries.map((entry) => entry.toJson()).toList()};
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory LeaderboardModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LeaderboardModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardModel &&
        other.entries.length == entries.length &&
        other.entries.every((entry) => entries.contains(entry));
  }

  @override
  int get hashCode => Object.hashAll(entries);

  @override
  String toString() {
    return 'LeaderboardModel(entries: ${entries.length})';
  }
}
