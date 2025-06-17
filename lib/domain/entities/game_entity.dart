import 'tile_entity.dart';
import 'powerup_entity.dart';

/// Domain entity representing the complete game state
/// Following clean architecture principles - this is pure business logic
class GameEntity {
  final List<List<TileEntity?>> board;
  final int score;
  final int bestScore;
  final bool isGameOver;
  final bool hasWon;
  final bool canUndo;
  final bool isPaused;
  final DateTime lastPlayed;
  final List<PowerupEntity> availablePowerups;
  final List<PowerupEntity> activePowerups;
  final Set<PowerupType> usedPowerupTypes;
  final Set<PowerupType>
  offeredPowerupTypes; // Track powerups offered via inventory dialog
  final bool isTimeAttackMode;
  final int? timeLimit; // in seconds
  final DateTime? timeAttackStartTime;
  final int pausedTimeSeconds; // Total time spent paused
  final bool isScenicMode;
  final int? scenicBackgroundIndex; // Index of the current scenic background
  final GameEntity? previousState; // For undo functionality

  const GameEntity({
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
    this.offeredPowerupTypes = const {},
    this.isTimeAttackMode = false,
    this.timeLimit,
    this.timeAttackStartTime,
    this.pausedTimeSeconds = 0,
    this.isScenicMode = false,
    this.scenicBackgroundIndex,
    this.previousState,
  });

  /// Create a new game with empty board
  factory GameEntity.newGame() {
    return GameEntity(
      board: List.generate(5, (_) => List.generate(5, (_) => null)),
      score: 0,
      bestScore: 0,
      isGameOver: false,
      hasWon: false,
      canUndo: false,
      isPaused: false,
      lastPlayed: DateTime.now(),
      availablePowerups: const [],
      activePowerups: const [],
      usedPowerupTypes: const {},
      offeredPowerupTypes: const {},
    );
  }

  /// Create a new time attack game
  factory GameEntity.newTimeAttackGame(int timeLimitSeconds) {
    final now = DateTime.now();
    return GameEntity(
      board: List.generate(5, (_) => List.generate(5, (_) => null)),
      score: 0,
      bestScore: 0,
      isGameOver: false,
      hasWon: false,
      canUndo: false,
      isPaused: false,
      lastPlayed: now,
      availablePowerups: const [],
      activePowerups: const [],
      usedPowerupTypes: const {},
      offeredPowerupTypes: const {},
      isTimeAttackMode: true,
      timeLimit: timeLimitSeconds,
      timeAttackStartTime: now,
    );
  }

  /// Create a new scenic mode game
  factory GameEntity.newScenicGame(int backgroundIndex) {
    return GameEntity(
      board: List.generate(5, (_) => List.generate(5, (_) => null)),
      score: 0,
      bestScore: 0,
      isGameOver: false,
      hasWon: false,
      canUndo: false,
      isPaused: false,
      lastPlayed: DateTime.now(),
      availablePowerups: const [],
      activePowerups: const [],
      usedPowerupTypes: const {},
      offeredPowerupTypes: const {},
      isScenicMode: true,
      scenicBackgroundIndex: backgroundIndex,
    );
  }

  /// Create a copy with updated values
  GameEntity copyWith({
    List<List<TileEntity?>>? board,
    int? score,
    int? bestScore,
    bool? isGameOver,
    bool? hasWon,
    bool? canUndo,
    bool? isPaused,
    DateTime? lastPlayed,
    List<PowerupEntity>? availablePowerups,
    List<PowerupEntity>? activePowerups,
    Set<PowerupType>? usedPowerupTypes,
    Set<PowerupType>? offeredPowerupTypes,
    bool? isTimeAttackMode,
    int? timeLimit,
    DateTime? timeAttackStartTime,
    int? pausedTimeSeconds,
    bool? isScenicMode,
    int? scenicBackgroundIndex,
    GameEntity? previousState,
  }) {
    return GameEntity(
      board: board ?? this.board,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      isGameOver: isGameOver ?? this.isGameOver,
      hasWon: hasWon ?? this.hasWon,
      canUndo: canUndo ?? this.canUndo,
      isPaused: isPaused ?? this.isPaused,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      availablePowerups: availablePowerups ?? this.availablePowerups,
      activePowerups: activePowerups ?? this.activePowerups,
      usedPowerupTypes: usedPowerupTypes ?? this.usedPowerupTypes,
      offeredPowerupTypes: offeredPowerupTypes ?? this.offeredPowerupTypes,
      isTimeAttackMode: isTimeAttackMode ?? this.isTimeAttackMode,
      timeLimit: timeLimit ?? this.timeLimit,
      timeAttackStartTime: timeAttackStartTime ?? this.timeAttackStartTime,
      pausedTimeSeconds: pausedTimeSeconds ?? this.pausedTimeSeconds,
      isScenicMode: isScenicMode ?? this.isScenicMode,
      scenicBackgroundIndex:
          scenicBackgroundIndex ?? this.scenicBackgroundIndex,
      previousState: previousState ?? this.previousState,
    );
  }

  /// Get all non-null tiles
  List<TileEntity> get allTiles {
    final tiles = <TileEntity>[];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final tile = board[row][col];
        if (tile != null) {
          tiles.add(tile);
        }
      }
    }
    return tiles;
  }

  /// Get empty positions on the board (optimized)
  List<Position> get emptyPositions {
    final positions = <Position>[];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (board[row][col] == null) {
          positions.add(Position(row, col));
        }
      }
    }
    return positions;
  }

  /// Check if the board is full (optimized to avoid creating list)
  bool get isBoardFull {
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (board[row][col] == null) {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if any moves are possible
  bool get canMove {
    if (!isBoardFull) return true;

    // Check for possible merges horizontally
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 4; col++) {
        final current = board[row][col];
        final next = board[row][col + 1];
        if (current != null && next != null && current.canMergeWith(next)) {
          return true;
        }
      }
    }

    // Check for possible merges vertically
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        final current = board[row][col];
        final next = board[row + 1][col];
        if (current != null && next != null && current.canMergeWith(next)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get tile at specific position
  TileEntity? getTileAt(int row, int col) {
    if (row < 0 || row >= 5 || col < 0 || col >= 5) return null;
    return board[row][col];
  }

  /// Set tile at specific position
  GameEntity setTileAt(int row, int col, TileEntity? tile) {
    if (row < 0 || row >= 5 || col < 0 || col >= 5) return this;

    final newBoard = List.generate(
      5,
      (r) => List.generate(5, (c) => board[r][c]),
    );
    newBoard[row][col] = tile;

    return copyWith(board: newBoard);
  }

  /// Helper method to compare lists of powerups
  bool _listEquals(List<PowerupEntity> list1, List<PowerupEntity> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Helper method to compare sets of powerup types
  bool _setEquals(Set<PowerupType> set1, Set<PowerupType> set2) {
    if (set1.length != set2.length) return false;
    return set1.containsAll(set2) && set2.containsAll(set1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameEntity) return false;

    // Compare board contents
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (board[row][col] != other.board[row][col]) return false;
      }
    }

    return score == other.score &&
        bestScore == other.bestScore &&
        isGameOver == other.isGameOver &&
        hasWon == other.hasWon &&
        canUndo == other.canUndo &&
        _listEquals(availablePowerups, other.availablePowerups) &&
        _listEquals(activePowerups, other.activePowerups) &&
        _setEquals(usedPowerupTypes, other.usedPowerupTypes) &&
        _setEquals(offeredPowerupTypes, other.offeredPowerupTypes);
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
      availablePowerups.length,
      activePowerups.length,
      usedPowerupTypes.length,
    );
  }

  /// Check if a powerup type is currently active
  bool isPowerupActive(PowerupType type) {
    return activePowerups.any(
      (powerup) => powerup.type == type && powerup.isActive,
    );
  }

  /// Check if a powerup type has been used in this game
  bool isPowerupUsed(PowerupType type) {
    return usedPowerupTypes.contains(type);
  }

  /// Check if a powerup type has ever been unlocked (used or available)
  bool isPowerupEverUnlocked(PowerupType type) {
    return usedPowerupTypes.contains(type) ||
        availablePowerups.any((p) => p.type == type);
  }

  /// Get total number of powerups unlocked in this game
  int get totalPowerupsUnlocked {
    final usedCount = usedPowerupTypes.length;
    final availableCount = availablePowerups.length;
    final offeredCount = offeredPowerupTypes.length;
    return usedCount + availableCount + offeredCount;
  }

  /// Mark a powerup as offered via inventory management dialog
  GameEntity markPowerupAsOffered(PowerupType powerupType) {
    final newOfferedPowerupTypes = Set<PowerupType>.from(offeredPowerupTypes)
      ..add(powerupType);
    return copyWith(offeredPowerupTypes: newOfferedPowerupTypes);
  }

  /// Check if a powerup has been offered via inventory management dialog
  bool isPowerupOffered(PowerupType powerupType) {
    return offeredPowerupTypes.contains(powerupType);
  }

  /// Check if tile freeze powerup is active
  bool get isTileFreezeActive => isPowerupActive(PowerupType.tileFreeze);

  /// Check if blocker shield powerup is active
  bool get isBlockerShieldActive => isPowerupActive(PowerupType.blockerShield);

  /// Get active powerup of specific type
  PowerupEntity? getActivePowerup(PowerupType type) {
    try {
      return activePowerups.firstWhere(
        (powerup) => powerup.type == type && powerup.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Add a new powerup to available powerups
  GameEntity addPowerup(PowerupEntity powerup) {
    if (availablePowerups.length >= 3) return this; // Max 3 powerups
    if (availablePowerups.any((p) => p.type == powerup.type)) {
      return this; // No duplicates
    }

    final newAvailablePowerups = List<PowerupEntity>.from(availablePowerups)
      ..add(powerup);
    return copyWith(availablePowerups: newAvailablePowerups);
  }

  /// Activate a powerup
  GameEntity activatePowerup(PowerupType type) {
    final powerupIndex = availablePowerups.indexWhere(
      (p) => p.type == type && p.isAvailable,
    );

    if (powerupIndex == -1) {
      return this;
    }

    final powerup = availablePowerups[powerupIndex];
    final activatedPowerup = powerup.activate();

    final newAvailablePowerups = List<PowerupEntity>.from(availablePowerups)
      ..removeAt(powerupIndex);
    final newActivePowerups = List<PowerupEntity>.from(activePowerups)
      ..add(activatedPowerup);
    final newUsedPowerupTypes = Set<PowerupType>.from(usedPowerupTypes)
      ..add(type);

    return copyWith(
      availablePowerups: newAvailablePowerups,
      activePowerups: newActivePowerups,
      usedPowerupTypes: newUsedPowerupTypes,
    );
  }

  /// Process powerup effects after a move
  GameEntity processPowerupEffects() {
    final updatedActivePowerups = <PowerupEntity>[];

    for (final powerup in activePowerups) {
      final updatedPowerup = powerup.useMove();
      if (updatedPowerup.isActive) {
        updatedActivePowerups.add(updatedPowerup);
      }
    }

    return copyWith(activePowerups: updatedActivePowerups);
  }

  /// Check if time has expired in time attack mode
  bool get isTimeExpired {
    if (!isTimeAttackMode || timeLimit == null || timeAttackStartTime == null) {
      return false;
    }

    final elapsed = DateTime.now().difference(timeAttackStartTime!);
    final effectiveElapsed = elapsed.inSeconds - pausedTimeSeconds;
    return effectiveElapsed >= timeLimit!;
  }

  /// Get remaining time in seconds for time attack mode
  int get remainingTimeSeconds {
    if (!isTimeAttackMode || timeLimit == null || timeAttackStartTime == null) {
      return 0;
    }

    final elapsed = DateTime.now().difference(timeAttackStartTime!);
    final effectiveElapsed = elapsed.inSeconds - pausedTimeSeconds;
    final remaining = timeLimit! - effectiveElapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// Get elapsed time in seconds for time attack mode (excluding paused time)
  int get elapsedTimeSeconds {
    if (!isTimeAttackMode || timeAttackStartTime == null) {
      return 0;
    }

    final elapsed = DateTime.now().difference(timeAttackStartTime!);
    final effectiveElapsed = elapsed.inSeconds - pausedTimeSeconds;
    return effectiveElapsed > 0 ? effectiveElapsed : 0;
  }

  @override
  String toString() {
    return 'GameEntity(score: $score, bestScore: $bestScore, isGameOver: $isGameOver, hasWon: $hasWon, powerups: ${availablePowerups.length}/${activePowerups.length}, timeAttack: $isTimeAttackMode)';
  }
}

/// Represents a position on the game board
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Position($row, $col)';
}
