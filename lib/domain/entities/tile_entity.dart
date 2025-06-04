/// Domain entity representing a single tile in the 2048 game
/// Following clean architecture principles - this is pure business logic
class TileEntity {
  final int value;
  final int row;
  final int col;
  final String id;
  final bool isNew;
  final bool isMerged;
  final bool isBlocker;

  const TileEntity({
    required this.value,
    required this.row,
    required this.col,
    required this.id,
    this.isNew = false,
    this.isMerged = false,
    this.isBlocker = false,
  });

  /// Create a new tile with value 2 or 4
  factory TileEntity.random(int row, int col) {
    final value = _getRandomValue();
    final id = '${DateTime.now().millisecondsSinceEpoch}_${row}_$col';
    return TileEntity(value: value, row: row, col: col, id: id, isNew: true);
  }

  /// Create a tile with specific value
  factory TileEntity.withValue(int value, int row, int col) {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${row}_$col';
    return TileEntity(value: value, row: row, col: col, id: id);
  }

  /// Create a blocker tile
  factory TileEntity.blocker(int row, int col) {
    final id = 'blocker_${DateTime.now().millisecondsSinceEpoch}_${row}_$col';
    return TileEntity(
      value: -1, // Special value for blocker tiles
      row: row,
      col: col,
      id: id,
      isBlocker: true,
      isNew: true,
    );
  }

  /// Get random starting value (2 or 4)
  static int _getRandomValue() {
    // 90% chance for 2, 10% chance for 4
    return DateTime.now().millisecond % 10 == 0 ? 4 : 2;
  }

  /// Create a copy with updated values
  TileEntity copyWith({
    int? value,
    int? row,
    int? col,
    String? id,
    bool? isNew,
    bool? isMerged,
    bool? isBlocker,
  }) {
    return TileEntity(
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      id: id ?? this.id,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
      isBlocker: isBlocker ?? this.isBlocker,
    );
  }

  /// Move tile to new position
  TileEntity moveTo(int newRow, int newCol) {
    return copyWith(row: newRow, col: newCol, isNew: false);
  }

  /// Merge with another tile (double the value)
  TileEntity merge() {
    return copyWith(value: value * 2, isMerged: true, isNew: false);
  }

  /// Reset merge and new flags
  TileEntity resetFlags() {
    return copyWith(isNew: false, isMerged: false);
  }

  /// Check if this tile can merge with another
  bool canMergeWith(TileEntity other) {
    // Blocker tiles can only merge with other blocker tiles
    if (isBlocker || other.isBlocker) {
      return isBlocker && other.isBlocker && !isMerged && !other.isMerged;
    }
    // Normal tiles can only merge with other normal tiles of same value
    return value == other.value && !isMerged && !other.isMerged;
  }

  /// Get the color based on tile value
  int get colorValue {
    // Blocker tiles have a distinct dark color
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
  }

  /// Get text color based on tile value
  int get textColorValue {
    // Blocker tiles have white text
    if (isBlocker) {
      return 0xFFFFFFFF;
    }
    return value <= 4 ? 0xFF776E65 : 0xFFF9F6F2;
  }

  /// Get font size based on tile value (smaller for 5x5 board)
  double get fontSize {
    // Blocker tiles have smaller text
    if (isBlocker) {
      return 16.0;
    }
    if (value < 100) return 24.0;
    if (value < 1000) return 20.0;
    if (value < 10000) return 18.0;
    return 16.0;
  }

  /// Get display text for the tile
  String get displayText {
    if (isBlocker) {
      return '🚫'; // Block emoji for blocker tiles
    }
    return value.toString();
  }

  /// Check if this is the winning tile (2048)
  bool get isWinningTile => value >= 2048;

  /// Get score contribution when this tile is created through merging
  int get scoreContribution => value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileEntity &&
        other.value == value &&
        other.row == row &&
        other.col == col &&
        other.id == id &&
        other.isNew == isNew &&
        other.isMerged == isMerged &&
        other.isBlocker == isBlocker;
  }

  @override
  int get hashCode {
    return Object.hash(value, row, col, id, isNew, isMerged, isBlocker);
  }

  @override
  String toString() {
    return 'TileEntity(value: $value, position: ($row, $col), id: $id, isNew: $isNew, isMerged: $isMerged, isBlocker: $isBlocker)';
  }
}

/// Direction enum for tile movement
enum MoveDirection {
  up,
  down,
  left,
  right;

  /// Get the opposite direction
  MoveDirection get opposite {
    switch (this) {
      case MoveDirection.up:
        return MoveDirection.down;
      case MoveDirection.down:
        return MoveDirection.up;
      case MoveDirection.left:
        return MoveDirection.right;
      case MoveDirection.right:
        return MoveDirection.left;
    }
  }

  /// Get direction vector (row, col)
  (int, int) get vector {
    switch (this) {
      case MoveDirection.up:
        return (-1, 0);
      case MoveDirection.down:
        return (1, 0);
      case MoveDirection.left:
        return (0, -1);
      case MoveDirection.right:
        return (0, 1);
    }
  }
}
