import '../entities/tile_entity.dart';

/// Domain entity representing a leaderboard entry
/// Following clean architecture principles - this is pure business logic
class LeaderboardEntry {
  final String id;
  final int score;
  final DateTime datePlayed;
  final String gameMode;
  final Duration gameDuration;
  final List<List<TileSnapshot?>> boardSnapshot;
  final int? customBaseNumber; // For custom mode games
  final int? timeLimit; // For time attack mode games

  const LeaderboardEntry({
    required this.id,
    required this.score,
    required this.datePlayed,
    required this.gameMode,
    required this.gameDuration,
    required this.boardSnapshot,
    this.customBaseNumber,
    this.timeLimit,
  });

  /// Create a leaderboard entry from a completed game
  factory LeaderboardEntry.fromGame({
    required int score,
    required String gameMode,
    required Duration gameDuration,
    required List<List<TileEntity?>> gameBoard,
    int? customBaseNumber,
    int? timeLimit,
  }) {
    final id = '${DateTime.now().millisecondsSinceEpoch}_$score';
    final boardSnapshot = _createBoardSnapshot(gameBoard);

    return LeaderboardEntry(
      id: id,
      score: score,
      datePlayed: DateTime.now(),
      gameMode: gameMode,
      gameDuration: gameDuration,
      boardSnapshot: boardSnapshot,
      customBaseNumber: customBaseNumber,
      timeLimit: timeLimit,
    );
  }

  /// Create a copy with updated values
  LeaderboardEntry copyWith({
    String? id,
    int? score,
    DateTime? datePlayed,
    String? gameMode,
    Duration? gameDuration,
    List<List<TileSnapshot?>>? boardSnapshot,
    int? customBaseNumber,
    int? timeLimit,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      score: score ?? this.score,
      datePlayed: datePlayed ?? this.datePlayed,
      gameMode: gameMode ?? this.gameMode,
      gameDuration: gameDuration ?? this.gameDuration,
      boardSnapshot: boardSnapshot ?? this.boardSnapshot,
      customBaseNumber: customBaseNumber ?? this.customBaseNumber,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  /// Get formatted score string
  String get formattedScore {
    if (score >= 10000) {
      return '${(score / 1000).round()}k';
    }
    return score.toString();
  }

  /// Get formatted duration string in MM:SS format
  String get formattedDuration {
    final minutes = gameDuration.inMinutes;
    final seconds = gameDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get relative date string (e.g., "2 days ago")
  String get relativeDateString {
    final now = DateTime.now();
    final difference = now.difference(datePlayed);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get absolute date string for display
  String get absoluteDateString {
    return '${datePlayed.day}/${datePlayed.month}/${datePlayed.year}';
  }

  /// Get detailed game mode string
  String get detailedGameMode {
    switch (gameMode) {
      case 'Time Attack':
        if (timeLimit != null) {
          final minutes = timeLimit! ~/ 60;
          return 'Time Attack ($minutes min)';
        }
        return gameMode;
      default:
        return gameMode;
    }
  }

  /// Create board snapshot from game board
  static List<List<TileSnapshot?>> _createBoardSnapshot(
    List<List<TileEntity?>> gameBoard,
  ) {
    return gameBoard.map((row) {
      return row.map((tile) {
        if (tile == null) return null;
        return TileSnapshot(value: tile.value, isBlocker: tile.isBlocker);
      }).toList();
    }).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry &&
        other.id == id &&
        other.score == score &&
        other.datePlayed == datePlayed &&
        other.gameMode == gameMode &&
        other.gameDuration == gameDuration &&
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
      gameDuration,
      customBaseNumber,
      timeLimit,
    );
  }

  @override
  String toString() {
    return 'LeaderboardEntry(id: $id, score: $score, gameMode: $gameMode, duration: $formattedDuration)';
  }
}

/// Simplified tile representation for board snapshots
class TileSnapshot {
  final int value;
  final bool isBlocker;

  const TileSnapshot({required this.value, required this.isBlocker});

  /// Create a safe TileSnapshot with validation
  factory TileSnapshot.safe({
    required dynamic value,
    required dynamic isBlocker,
  }) {
    // Validate and convert value
    int safeValue;
    if (value is int) {
      safeValue = value;
    } else if (value is String) {
      safeValue = int.tryParse(value) ?? 2;
    } else {
      safeValue = 2; // Default fallback
    }

    // Validate and convert isBlocker
    bool safeIsBlocker;
    if (isBlocker is bool) {
      safeIsBlocker = isBlocker;
    } else if (isBlocker is String) {
      safeIsBlocker = isBlocker.toLowerCase() == 'true';
    } else {
      safeIsBlocker = false; // Default fallback
    }

    return TileSnapshot(value: safeValue, isBlocker: safeIsBlocker);
  }

  /// Get the color based on tile value (same logic as TileEntity)
  int get colorValue {
    try {
      if (isBlocker) {
        return 0xFF2C2C2C; // Dark gray for blocker tiles
      }

      switch (value) {
        case 2:
          return 0xFFEEE4DA;
        case 4:
          return 0xFFEDE0C8;
        case 8:
          return 0xFFF2B179;
        case 16:
          return 0xFFF59563;
        case 32:
          return 0xFFF67C5F;
        case 64:
          return 0xFFF65E3B;
        case 128:
          return 0xFFEDCF72;
        case 256:
          return 0xFFEDCC61;
        case 512:
          return 0xFFEDC850;
        case 1024:
          return 0xFFEDC53F;
        case 2048:
          return 0xFFEDC22E;
        default:
          return 0xFF3C3A32; // For values > 2048
      }
    } catch (e) {
      return 0xFFCDC1B4; // Fallback color
    }
  }

  /// Get text color based on tile value
  int get textColorValue {
    try {
      if (isBlocker) {
        return 0xFFFFFFFF;
      }
      return value <= 4 ? 0xFF776E65 : 0xFFF9F6F2;
    } catch (e) {
      return 0xFF776E65; // Fallback color
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileSnapshot &&
        other.value == value &&
        other.isBlocker == isBlocker;
  }

  @override
  int get hashCode => Object.hash(value, isBlocker);

  @override
  String toString() {
    return 'TileSnapshot(value: $value, isBlocker: $isBlocker)';
  }
}
