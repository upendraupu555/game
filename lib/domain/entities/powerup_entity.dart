/// Domain entity representing a powerup in the 2048 game
/// Following clean architecture principles - this is pure business logic
class PowerupEntity {
  final PowerupType type;
  final int movesRemaining;
  final bool isActive;
  final bool isUsed;
  final DateTime? activatedAt;
  final String id;

  const PowerupEntity({
    required this.type,
    required this.movesRemaining,
    required this.isActive,
    required this.isUsed,
    required this.id,
    this.activatedAt,
  });

  /// Create a new powerup
  factory PowerupEntity.create(PowerupType type) {
    final id = '${type.name}_${DateTime.now().millisecondsSinceEpoch}';
    return PowerupEntity(
      type: type,
      movesRemaining: type.defaultDuration,
      isActive: false,
      isUsed: false,
      id: id,
    );
  }

  /// Activate the powerup
  PowerupEntity activate() {
    return copyWith(isActive: true, activatedAt: DateTime.now());
  }

  /// Use one move of the powerup
  PowerupEntity useMove() {
    if (!isActive || movesRemaining <= 0) return this;

    final newMovesRemaining = movesRemaining - 1;
    return copyWith(
      movesRemaining: newMovesRemaining,
      isActive: newMovesRemaining > 0,
      isUsed: newMovesRemaining <= 0,
    );
  }

  /// Deactivate the powerup
  PowerupEntity deactivate() {
    return copyWith(isActive: false, isUsed: true, movesRemaining: 0);
  }

  /// Create a copy with updated values
  PowerupEntity copyWith({
    PowerupType? type,
    int? movesRemaining,
    bool? isActive,
    bool? isUsed,
    DateTime? activatedAt,
    String? id,
  }) {
    return PowerupEntity(
      type: type ?? this.type,
      movesRemaining: movesRemaining ?? this.movesRemaining,
      isActive: isActive ?? this.isActive,
      isUsed: isUsed ?? this.isUsed,
      activatedAt: activatedAt ?? this.activatedAt,
      id: id ?? this.id,
    );
  }

  /// Check if powerup is available for use
  bool get isAvailable => !isUsed && !isActive;

  /// Check if powerup has expired
  bool get hasExpired => isActive && movesRemaining <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerupEntity &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          movesRemaining == other.movesRemaining &&
          isActive == other.isActive &&
          isUsed == other.isUsed &&
          id == other.id;

  @override
  int get hashCode =>
      type.hashCode ^
      movesRemaining.hashCode ^
      isActive.hashCode ^
      isUsed.hashCode ^
      id.hashCode;

  @override
  String toString() {
    return 'PowerupEntity{type: $type, movesRemaining: $movesRemaining, isActive: $isActive, isUsed: $isUsed, id: $id}';
  }
}

/// Enum representing different types of powerups
enum PowerupType {
  // Primary powerups
  tileFreeze,
  undoMove,
  shuffleBoard,
  tileDestroyer,
  valueUpgrade,
  rowClear,
  columnClear,

  // Secondary powerups
  blockerShield,
  tileShrink,
  lockTile,
  valueTarget,
  timeSlow,
  valueFinder,
  cornerGather,

  // Legacy powerup (kept for backward compatibility)
  @Deprecated('Use rowClear or columnClear instead')
  rowColumnClear;

  /// Get the display name for the powerup
  String get displayName {
    switch (this) {
      case PowerupType.tileFreeze:
        return 'Tile Freeze';
      case PowerupType.undoMove:
        return 'Undo Move';
      case PowerupType.shuffleBoard:
        return 'Shuffle Board';
      case PowerupType.tileDestroyer:
        return 'Tile Destroyer';
      case PowerupType.valueUpgrade:
        return 'Value Upgrade';
      case PowerupType.rowClear:
        return 'Row Clear';
      case PowerupType.columnClear:
        return 'Column Clear';
      case PowerupType.blockerShield:
        return 'Blocker Shield';
      case PowerupType.tileShrink:
        return 'Tile Shrink';
      case PowerupType.lockTile:
        return 'Lock Tile';
      case PowerupType.valueTarget:
        return 'Value Target';
      case PowerupType.timeSlow:
        return 'Time Slow';
      case PowerupType.valueFinder:
        return 'Value Finder';
      case PowerupType.cornerGather:
        return 'Corner Gather';
      case PowerupType.rowColumnClear:
        return 'Row/Column Clear'; // Legacy support
    }
  }

  /// Get the description for the powerup
  String get description {
    switch (this) {
      case PowerupType.tileFreeze:
        return 'Prevents new tiles from appearing for 5 moves';
      case PowerupType.undoMove:
        return 'Revert the last move made';
      case PowerupType.shuffleBoard:
        return 'Randomly rearrange all tiles on the board';
      case PowerupType.tileDestroyer:
        return 'Tap to select and remove any single tile from the board';
      case PowerupType.valueUpgrade:
        return 'Upgrade all tiles on the board to their next power of 2';
      case PowerupType.rowClear:
        return 'Tap any tile to clear its entire row';
      case PowerupType.columnClear:
        return 'Tap any tile to clear its entire column';
      case PowerupType.blockerShield:
        return 'Prevent blocker tiles from appearing for 3 moves';
      case PowerupType.tileShrink:
        return 'Reduce the value of a selected tile by half';
      case PowerupType.lockTile:
        return 'Lock a tile in place for 5 moves';
      case PowerupType.valueTarget:
        return 'Next tile spawned will be a specific value';
      case PowerupType.timeSlow:
        return 'Slows down timer for 30 seconds';
      case PowerupType.valueFinder:
        return 'Highlights all tiles of a specific value';
      case PowerupType.cornerGather:
        return 'Pulls all tiles toward a corner of your choice';
      case PowerupType.rowColumnClear:
        return 'Clear an entire row or column of your choice'; // Legacy support
    }
  }

  /// Get the emoji icon for the powerup
  String get icon {
    switch (this) {
      case PowerupType.tileFreeze:
        return '🧊';
      case PowerupType.undoMove:
        return '↩️';
      case PowerupType.shuffleBoard:
        return '🔀';
      case PowerupType.tileDestroyer:
        return '💥';
      case PowerupType.valueUpgrade:
        return '⬆️';
      case PowerupType.rowClear:
        return '↔️';
      case PowerupType.columnClear:
        return '↕️';
      case PowerupType.blockerShield:
        return '🛡️';
      case PowerupType.tileShrink:
        return '📉';
      case PowerupType.lockTile:
        return '🔒';
      case PowerupType.valueTarget:
        return '🎯';
      case PowerupType.timeSlow:
        return '⏱️';
      case PowerupType.valueFinder:
        return '🔍';
      case PowerupType.cornerGather:
        return '🌀';
      case PowerupType.rowColumnClear:
        return '🧹'; // Legacy support
    }
  }

  /// Get the default duration for the powerup (in moves)
  int get defaultDuration {
    switch (this) {
      case PowerupType.tileFreeze:
        return 5;
      case PowerupType.blockerShield:
        return 3;
      case PowerupType.lockTile:
        return 5;
      case PowerupType.undoMove:
      case PowerupType.shuffleBoard:
      case PowerupType.tileDestroyer:
      case PowerupType.valueUpgrade:
      case PowerupType.rowClear:
      case PowerupType.columnClear:
      case PowerupType.tileShrink:
      case PowerupType.valueTarget:
      case PowerupType.timeSlow:
      case PowerupType.valueFinder:
      case PowerupType.cornerGather:
      case PowerupType.rowColumnClear: // Legacy support
        return 1; // Single use powerups
    }
  }

  /// Check if this is a primary powerup
  bool get isPrimary {
    return [
      PowerupType.tileFreeze,
      PowerupType.undoMove,
      PowerupType.shuffleBoard,
      PowerupType.tileDestroyer,
      PowerupType.valueUpgrade,
      PowerupType.rowClear,
      PowerupType.columnClear,
    ].contains(this);
  }

  /// Get the score threshold required to unlock this powerup
  int get scoreThreshold {
    switch (this) {
      case PowerupType.tileFreeze:
        return 1000;
      case PowerupType.undoMove:
        return 2500;
      case PowerupType.shuffleBoard:
        return 5000;
      case PowerupType.tileDestroyer:
        return 7500;
      case PowerupType.valueUpgrade:
        return 10000;
      case PowerupType.rowClear:
        return 12000;
      case PowerupType.columnClear:
        return 15000;
      case PowerupType.rowColumnClear: // Legacy support
        return 15000;
      default:
        return 20000; // Secondary powerups require higher scores
    }
  }

  /// Check if this powerup requires interactive selection
  bool get requiresInteractiveSelection {
    return [
      PowerupType.tileDestroyer,
      PowerupType.rowClear,
      PowerupType.columnClear,
    ].contains(this);
  }
}
