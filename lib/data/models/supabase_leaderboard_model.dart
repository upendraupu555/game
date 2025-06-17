import 'package:game/domain/entities/leaderboard_entity.dart';

/// Supabase model for leaderboard entries
class SupabaseLeaderboardModel {
  final String id;
  final String? userId;
  final String? guestId;
  final int score;
  final String gameMode;
  final int gameDurationSeconds;
  final Map<String, dynamic> boardSnapshot;
  final int? customBaseNumber;
  final int? timeLimit;
  final DateTime datePlayed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupabaseLeaderboardModel({
    required this.id,
    this.userId,
    this.guestId,
    required this.score,
    required this.gameMode,
    required this.gameDurationSeconds,
    required this.boardSnapshot,
    this.customBaseNumber,
    this.timeLimit,
    required this.datePlayed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from Supabase JSON response
  factory SupabaseLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return SupabaseLeaderboardModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      guestId: json['guest_id'] as String?,
      score: json['score'] as int,
      gameMode: json['game_mode'] as String,
      gameDurationSeconds: json['game_duration_seconds'] as int,
      boardSnapshot: json['board_snapshot'] as Map<String, dynamic>,
      customBaseNumber: json['custom_base_number'] as int?,
      timeLimit: json['time_limit'] as int?,
      datePlayed: DateTime.parse(json['date_played'] as String),
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
      'score': score,
      'game_mode': gameMode,
      'game_duration_seconds': gameDurationSeconds,
      'board_snapshot': boardSnapshot,
      'custom_base_number': customBaseNumber,
      'time_limit': timeLimit,
      'date_played': datePlayed.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  LeaderboardEntry toEntity() {
    return LeaderboardEntry(
      id: id,
      score: score,
      gameMode: gameMode,
      gameDuration: Duration(seconds: gameDurationSeconds),
      datePlayed: datePlayed,
      customBaseNumber: customBaseNumber,
      timeLimit: timeLimit,
      boardSnapshot: _convertBoardSnapshotFromJson(boardSnapshot),
    );
  }

  /// Create from domain entity
  factory SupabaseLeaderboardModel.fromEntity(
    LeaderboardEntry entity, {
    String? userId,
    String? guestId,
  }) {
    final now = DateTime.now();
    return SupabaseLeaderboardModel(
      id: entity.id,
      userId: userId,
      guestId: guestId,
      score: entity.score,
      gameMode: entity.gameMode,
      gameDurationSeconds: entity.gameDuration.inSeconds,
      boardSnapshot: _convertBoardSnapshotToJson(entity.boardSnapshot),
      customBaseNumber: entity.customBaseNumber,
      timeLimit: entity.timeLimit,
      datePlayed: entity.datePlayed,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create for insertion (without timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'guest_id': guestId,
      'score': score,
      'game_mode': gameMode,
      'game_duration_seconds': gameDurationSeconds,
      'board_snapshot': boardSnapshot,
      'custom_base_number': customBaseNumber,
      'time_limit': timeLimit,
      'date_played': datePlayed.toIso8601String(),
    };
  }

  /// Create for update (only updatable fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'score': score,
      'game_mode': gameMode,
      'game_duration_seconds': gameDurationSeconds,
      'board_snapshot': boardSnapshot,
      'custom_base_number': customBaseNumber,
      'time_limit': timeLimit,
      'date_played': datePlayed.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copy with new values
  SupabaseLeaderboardModel copyWith({
    String? id,
    String? userId,
    String? guestId,
    int? score,
    String? gameMode,
    int? gameDurationSeconds,
    Map<String, dynamic>? boardSnapshot,
    int? customBaseNumber,
    int? timeLimit,
    DateTime? datePlayed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseLeaderboardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      guestId: guestId ?? this.guestId,
      score: score ?? this.score,
      gameMode: gameMode ?? this.gameMode,
      gameDurationSeconds: gameDurationSeconds ?? this.gameDurationSeconds,
      boardSnapshot: boardSnapshot ?? this.boardSnapshot,
      customBaseNumber: customBaseNumber ?? this.customBaseNumber,
      timeLimit: timeLimit ?? this.timeLimit,
      datePlayed: datePlayed ?? this.datePlayed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseLeaderboardModel &&
        other.id == id &&
        other.userId == userId &&
        other.guestId == guestId &&
        other.score == score &&
        other.gameMode == gameMode &&
        other.gameDurationSeconds == gameDurationSeconds &&
        other.customBaseNumber == customBaseNumber &&
        other.timeLimit == timeLimit &&
        other.datePlayed == datePlayed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      guestId,
      score,
      gameMode,
      gameDurationSeconds,
      customBaseNumber,
      timeLimit,
      datePlayed,
    );
  }

  @override
  String toString() {
    return 'SupabaseLeaderboardModel('
        'id: $id, '
        'userId: $userId, '
        'guestId: $guestId, '
        'score: $score, '
        'gameMode: $gameMode, '
        'gameDurationSeconds: $gameDurationSeconds, '
        'datePlayed: $datePlayed'
        ')';
  }

  /// Convert board snapshot from JSON to TileSnapshot list
  static List<List<TileSnapshot?>> _convertBoardSnapshotFromJson(
    Map<String, dynamic> json,
  ) {
    try {
      if (json.containsKey('board') && json['board'] is List) {
        final boardList = json['board'] as List;
        return boardList.map<List<TileSnapshot?>>((row) {
          if (row is List) {
            return row.map<TileSnapshot?>((tile) {
              if (tile == null) return null;
              if (tile is Map<String, dynamic>) {
                return TileSnapshot.safe(
                  value: tile['value'] ?? 2,
                  isBlocker: tile['isBlocker'] ?? false,
                );
              }
              return null;
            }).toList();
          }
          return <TileSnapshot?>[];
        }).toList();
      }

      // Fallback: create empty 5x5 board
      return List.generate(5, (_) => List.generate(5, (_) => null));
    } catch (e) {
      // Fallback: create empty 5x5 board
      return List.generate(5, (_) => List.generate(5, (_) => null));
    }
  }

  /// Convert board snapshot from TileSnapshot list to JSON
  static Map<String, dynamic> _convertBoardSnapshotToJson(
    List<List<TileSnapshot?>> boardSnapshot,
  ) {
    try {
      final boardList = boardSnapshot.map((row) {
        return row.map((tile) {
          if (tile == null) return null;
          return {'value': tile.value, 'isBlocker': tile.isBlocker};
        }).toList();
      }).toList();

      return {
        'board': boardList,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'board': [],
        'timestamp': DateTime.now().toIso8601String(),
        'error': 'Failed to convert board snapshot',
      };
    }
  }
}
