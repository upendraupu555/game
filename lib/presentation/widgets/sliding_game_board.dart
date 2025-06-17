import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/tile_entity.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/gesture_utils.dart';
import '../../core/utils/performance_utils.dart';
import '../../core/constants/app_constants.dart';
import '../providers/powerup_selection_providers.dart';
import '../providers/game_providers.dart';
import 'powerup_selection_overlay.dart';
import 'keyboard_input_handler.dart';

/// Game board with sliding tile animations
class SlidingGameBoard extends ConsumerStatefulWidget {
  final GameEntity gameState;
  final Function(MoveDirection) onMove;

  const SlidingGameBoard({
    super.key,
    required this.gameState,
    required this.onMove,
  });

  @override
  ConsumerState<SlidingGameBoard> createState() => _SlidingGameBoardState();
}

class _SlidingGameBoardState extends ConsumerState<SlidingGameBoard>
    with TickerProviderStateMixin {
  static const double boardSize = 320.0;
  static const double tileSize = 56.0;
  static const double tileSpacing = 6.0;
  static const Duration animationDuration = Duration(
    milliseconds: 150,
  ); // Optimized for 60fps

  late AnimationController _moveController;

  Map<String, TilePosition> _tilePositions = {};
  bool _isAnimating = false;
  final GestureDebouncer _gestureDebouncer = GestureDebouncer();
  Offset? _panStartPosition;

  // Performance optimization: Cache position calculations
  final Map<String, Offset> _positionCache = {};

  // Cache for tile decorations to avoid recalculation
  final Map<String, BoxDecoration> _decorationCache = {};

  // Pre-calculated constants for better performance
  static const double _gridWidth = 5 * tileSize + 6 * tileSpacing;
  static const double _gridHeight = 5 * tileSize + 6 * tileSpacing;
  static const double _offsetX = (boardSize - _gridWidth) / 2;
  static const double _offsetY = (boardSize - _gridHeight) / 2;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    // Animation uses easing directly in the AnimatedBuilder

    _initializeTilePositions();

    // Track performance if enabled
    if (AppConstants.enablePerformanceLogging) {
      PerformanceUtils.trackFrameRate();
    }
  }

  @override
  void didUpdateWidget(SlidingGameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState != widget.gameState && !_isAnimating) {
      _animateTileMovement();
    }
  }

  @override
  void dispose() {
    _moveController.dispose();

    // Clear caches to prevent memory leaks
    _positionCache.clear();
    _decorationCache.clear();
    _tilePositions.clear();

    // Reset performance tracking
    if (AppConstants.enablePerformanceLogging) {
      PerformanceUtils.reset();
      AnimationOptimizer.reset();
    }

    super.dispose();
  }

  void _initializeTilePositions() {
    _tilePositions.clear();
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final tile = widget.gameState.board[row][col];
        if (tile != null) {
          _tilePositions[tile.id] = TilePosition(
            tile: tile,
            currentRow: row.toDouble(),
            currentCol: col.toDouble(),
            targetRow: row.toDouble(),
            targetCol: col.toDouble(),
          );
        }
      }
    }
  }

  void _animateTileMovement() async {
    if (_isAnimating) {
      if (AppConstants.enablePerformanceLogging) {
        AppLogger.animation(
          'ANIMATION_BLOCKED',
          data: {'reason': 'Already animating'},
        );
      }
      return;
    }

    _isAnimating = true;
    final newPositions = <String, TilePosition>{};
    final existingTiles = <String>[];
    final newTiles = <String>[];

    // Reduced logging for better performance
    if (AppConstants.enablePerformanceLogging) {
      AppLogger.animationEvent(
        'ANIMATION_START',
        animationType: 'TILE_MOVEMENT',
        tilesCount: _tilePositions.length,
      );
    }

    // Find new positions for existing tiles
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final tile = widget.gameState.board[row][col];
        if (tile != null) {
          if (_tilePositions.containsKey(tile.id)) {
            // Existing tile - update target position
            final currentPos = _tilePositions[tile.id]!;
            newPositions[tile.id] = currentPos.copyWith(
              tile: tile,
              targetRow: row.toDouble(),
              targetCol: col.toDouble(),
            );
            existingTiles.add(tile.id);
          } else {
            // New tile - add at target position
            newPositions[tile.id] = TilePosition(
              tile: tile,
              currentRow: row.toDouble(),
              currentCol: col.toDouble(),
              targetRow: row.toDouble(),
              targetCol: col.toDouble(),
            );
            newTiles.add(tile.id);

            AppLogger.animation(
              'NEW_TILE_ADDED',
              data: {
                'tileId': tile.id,
                'value': tile.value,
                'position': '($row, $col)',
                'isNew': tile.isNew,
                'animationType': 'instant', // No entrance animation
              },
            );
          }
        }
      }
    }

    AppLogger.animation(
      'TILE_POSITIONS_UPDATED',
      data: {
        'existingTiles': existingTiles.length,
        'newTiles': newTiles.length,
        'totalTiles': newPositions.length,
      },
    );

    setState(() {
      _tilePositions = newPositions;
    });

    // Animate movement
    _moveController.reset();
    await _moveController.forward();

    // Update current positions to target positions
    setState(() {
      for (final position in _tilePositions.values) {
        position.currentRow = position.targetRow;
        position.currentCol = position.targetCol;
      }
    });

    // No delay or entrance animation - new tiles appear instantly
    _isAnimating = false;
  }

  Offset _getPositionForGrid(double row, double col) {
    // Use cached position calculation with pre-calculated constants for better performance
    final key =
        '${row.toStringAsFixed(1)}_${col.toStringAsFixed(1)}'; // Reduced precision for better cache hits

    return _positionCache.putIfAbsent(key, () {
      // Use pre-calculated constants for optimal performance
      final x = _offsetX + tileSpacing + col * (tileSize + tileSpacing);
      final y = _offsetY + tileSpacing + row * (tileSize + tileSpacing);
      return Offset(x, y);
    });
  }

  /// Get cached tile decoration for performance
  BoxDecoration _getTileDecoration(
    TileEntity tile,
    double glowIntensity,
    bool isInSelectionMode,
    PowerupType? activePowerupType,
  ) {
    // Include tile value in cache key to ensure different values get different colors
    final cacheKey =
        '${tile.value}_${tile.isBlocker}_${glowIntensity.toStringAsFixed(2)}_${isInSelectionMode}_${activePowerupType?.name ?? 'none'}';

    return _decorationCache.putIfAbsent(cacheKey, () {
      return BoxDecoration(
        color: Color(tile.colorValue),
        borderRadius: BorderRadius.circular(4),
        // Add selection border if in selection mode
        border: isInSelectionMode && activePowerupType != null
            ? Border.all(color: _getSelectionColor(activePowerupType), width: 3)
            : null,
        boxShadow: _buildTileShadows(
          tile,
          glowIntensity,
          widget.gameState.isScenicMode,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInSelectionMode = ref.watch(isInSelectionModeProvider);
    final gameBoardKey = ref.watch(gameBoardKeyProvider);

    return RepaintBoundary(
      child: GameKeyboardInputHandler(
        onMove: widget.onMove,
        enabled:
            !isInSelectionMode, // Disable keyboard input during selection mode
        child: Stack(
          clipBehavior:
              Clip.none, // Allow overlay to extend beyond board bounds
          children: [
            GestureDetector(
              onPanStart: isInSelectionMode ? null : _handlePanStart,
              onPanEnd: isInSelectionMode ? null : _handlePanEnd,
              onTapDown: isInSelectionMode ? _handleTapDown : null,
              child: RepaintBoundary(
                child: Container(
                  key: gameBoardKey, // Add the GlobalKey for position tracking
                  width: boardSize,
                  height: boardSize,
                  decoration: _buildGameBoardDecoration(),
                  child: Stack(
                    children: [
                      // Background grid
                      _buildBackgroundGrid(),
                      // Animated tiles
                      ..._tilePositions.values.map(_buildAnimatedTile),
                    ],
                  ),
                ),
              ),
            ),

            // Selection mode indicators - positioned relative to the game board
            if (isInSelectionMode)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: SelectionModeIndicators(boardSize: 5),
              ),
          ],
        ),
      ),
    );
  }

  /// Build game board decoration with scenic mode support
  BoxDecoration _buildGameBoardDecoration() {
    final isScenicMode = widget.gameState.isScenicMode;

    if (isScenicMode) {
      // Semi-transparent game board for scenic mode with glass-morphism effect
      return BoxDecoration(
        color: Color(
          AppConstants.scenicGameBoardColorValue,
        ).withValues(alpha: AppConstants.scenicGameBoardOpacity),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else {
      // Regular game board decoration
      return BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      );
    }
  }

  Widget _buildBackgroundGrid() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: RepaintBoundary(child: CustomPaint(painter: GridPainter())),
    );
  }

  /// Build tile shadows with scenic mode enhancements
  List<BoxShadow> _buildTileShadows(
    TileEntity tile,
    double glowIntensity,
    bool isScenicMode,
  ) {
    final shadows = <BoxShadow>[];

    if (isScenicMode) {
      // Enhanced shadows for scenic mode readability
      shadows.addAll([
        // Primary shadow for depth
        BoxShadow(
          color: Colors.black.withValues(
            alpha: AppConstants.scenicTileShadowOpacity,
          ),
          blurRadius: AppConstants.scenicTileShadowBlur,
          offset: const Offset(0, 3),
        ),
        // Secondary shadow for better definition
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ]);
    } else {
      // Regular shadow
      shadows.add(
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.1 + (_moveController.value * 0.1),
          ),
          blurRadius: 2 + (_moveController.value * 2),
          offset: Offset(0, 1 + (_moveController.value * 2)),
        ),
      );
    }

    // Add glow effects for merged tiles
    if (glowIntensity > 0) {
      shadows.addAll([
        // Enhanced glow effect for merged tiles
        BoxShadow(
          color: Color(
            tile.colorValue,
          ).withValues(alpha: (glowIntensity * 0.7).clamp(0.0, 1.0)),
          blurRadius: 15 + (glowIntensity * 25),
          spreadRadius: 4 + (glowIntensity * 8),
          offset: Offset.zero,
        ),
        // Bright center glow
        if (glowIntensity > 0.3)
          BoxShadow(
            color: Colors.white.withValues(
              alpha: ((glowIntensity - 0.3) * 0.4).clamp(0.0, 1.0),
            ),
            blurRadius: 25 + (glowIntensity * 20),
            spreadRadius: 6 + (glowIntensity * 4),
            offset: Offset.zero,
          ),
      ]);
    }

    return shadows;
  }

  Widget _buildAnimatedTile(TilePosition position) {
    final isInSelectionMode = ref.watch(isInSelectionModeProvider);
    final selectionState = ref.watch(powerupSelectionProvider);

    return AnimatedBuilder(
      animation: _moveController,
      builder: (context, child) {
        // Interpolate position with easing
        final easedProgress = Curves.easeOutCubic.transform(
          _moveController.value,
        );
        final currentRow =
            position.currentRow +
            (position.targetRow - position.currentRow) * easedProgress;
        final currentCol =
            position.currentCol +
            (position.targetCol - position.currentCol) * easedProgress;

        final offset = _getPositionForGrid(currentRow, currentCol);

        // Optimized merge animation - simplified for better performance
        double scale = 1.0;
        double glowIntensity = 0.0;
        double pulseOpacity = 1.0;

        if (position.tile.isMerged) {
          final progress = _moveController.value;

          if (progress > 0.6) {
            // Simplified merge animation starts at 60% of movement completion
            final mergeProgress = (progress - 0.6) / 0.4;

            // Single-phase animation for better performance
            if (mergeProgress <= 0.5) {
              // Scale up phase (0-50%)
              final scaleProgress = mergeProgress / 0.5;
              scale =
                  (1.0 + (Curves.easeOutBack.transform(scaleProgress) * 0.3))
                      .clamp(0.8, 1.5);
              glowIntensity = (scaleProgress * 0.8).clamp(0.0, 1.0);
            } else {
              // Scale down phase (50-100%)
              final settleProgress = (mergeProgress - 0.5) / 0.5;
              scale =
                  (1.3 - (Curves.easeInCubic.transform(settleProgress) * 0.3))
                      .clamp(0.8, 1.5);
              glowIntensity = (0.8 * (1.0 - settleProgress)).clamp(0.0, 1.0);

              // Subtle pulse effect
              pulseOpacity =
                  (1.0 +
                          (math.sin(settleProgress * math.pi * 2) *
                              0.1 *
                              (1.0 - settleProgress)))
                      .clamp(0.8, 1.2);
            }
          }
        }

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: RepaintBoundary(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: pulseOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: _getTileDecoration(
                    position.tile,
                    glowIntensity,
                    isInSelectionMode,
                    selectionState.activePowerupType,
                  ),
                  child: Center(
                    child: Text(
                      position.tile.value.toString(),
                      style: TextStyle(
                        color: Color(position.tile.textColorValue),
                        fontSize:
                            position.tile.fontSize +
                            (glowIntensity *
                                4), // Slightly larger text for merged tiles
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BubblegumSans',
                        shadows: glowIntensity > 0
                            ? [
                                Shadow(
                                  color: Color(position.tile.textColorValue)
                                      .withValues(
                                        alpha: (glowIntensity * 0.5).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                      ),
                                  blurRadius: 2 + (glowIntensity * 4),
                                  offset: Offset.zero,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final localPosition = details.localPosition;

    // Convert tap position to grid coordinates
    final gridPosition = _getGridPositionFromOffset(localPosition);
    if (gridPosition != null) {
      final row = gridPosition.row;
      final col = gridPosition.col;

      AppLogger.userAction(
        'TILE_SELECTED_FOR_POWERUP',
        data: {
          'row': row,
          'col': col,
          'tapPosition': '(${localPosition.dx}, ${localPosition.dy})',
        },
      );

      ref.read(gameProvider.notifier).selectTileForPowerup(row, col);
    }
  }

  GridPosition? _getGridPositionFromOffset(Offset localPosition) {
    // Use pre-calculated constants for better performance
    final relativeX = localPosition.dx - _offsetX - tileSpacing;
    final relativeY = localPosition.dy - _offsetY - tileSpacing;

    if (relativeX < 0 || relativeY < 0) return null;

    // Calculate grid position
    final col = (relativeX / (tileSize + tileSpacing)).floor();
    final row = (relativeY / (tileSize + tileSpacing)).floor();

    // Validate bounds
    if (row >= 0 && row < 5 && col >= 0 && col < 5) {
      return GridPosition(row: row, col: col);
    }

    return null;
  }

  void _handlePanStart(DragStartDetails details) {
    // Store start position for distance-based gesture detection
    _panStartPosition = details.localPosition;

    // Minimal logging for better performance
    if (AppConstants.enablePerformanceLogging) {
      AppLogger.userAction(
        'PAN_START',
        data: {
          'x': details.localPosition.dx.toInt(),
          'y': details.localPosition.dy.toInt(),
          'animating': _isAnimating,
        },
      );
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    // Fast rejection checks for better performance
    if (_isAnimating) {
      return; // Block gestures during animations
    }

    if (!_gestureDebouncer.canProcessGesture()) {
      return; // Block rapid gestures
    }

    // Optimized gesture analysis with distance-based detection
    final result = GestureUtils.analyzeSwipe(
      details,
      startPosition: _panStartPosition,
      customVelocityThreshold: AppConstants.swipeVelocityThreshold,
      customDistanceThreshold: AppConstants.swipeDistanceThreshold,
    );

    // Execute move immediately if valid (no logging overhead)
    if (result.isValid && result.direction != null) {
      widget.onMove(result.direction!);

      // Optional logging only if performance logging is enabled
      if (AppConstants.enablePerformanceLogging) {
        AppLogger.userAction(
          'MOVE_EXECUTED',
          data: {
            'dir': result.direction.toString().split('.').last,
            'vel': result.velocity.toInt(),
            'conf': result.directionRatio.toStringAsFixed(1),
          },
        );
      }
    }
    // No logging for rejected gestures to improve performance
  }

  /// Get the selection color for a powerup type
  Color _getSelectionColor(PowerupType powerupType) {
    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }
}

/// Data class for tile position information
class TilePosition {
  final TileEntity tile;
  double currentRow;
  double currentCol;
  double targetRow;
  double targetCol;

  TilePosition({
    required this.tile,
    required this.currentRow,
    required this.currentCol,
    required this.targetRow,
    required this.targetCol,
  });

  TilePosition copyWith({
    TileEntity? tile,
    double? currentRow,
    double? currentCol,
    double? targetRow,
    double? targetCol,
  }) {
    return TilePosition(
      tile: tile ?? this.tile,
      currentRow: currentRow ?? this.currentRow,
      currentCol: currentCol ?? this.currentCol,
      targetRow: targetRow ?? this.targetRow,
      targetCol: targetCol ?? this.targetCol,
    );
  }
}

/// Data class for grid position
class GridPosition {
  final int row;
  final int col;

  const GridPosition({required this.row, required this.col});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition(row: $row, col: $col)';
}

/// Custom painter for the background grid with perfect symmetry
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDC1B4)
      ..style = PaintingStyle.fill;

    const tileSize = _SlidingGameBoardState.tileSize;
    const tileSpacing = _SlidingGameBoardState.tileSpacing;

    // Calculate total grid size to ensure perfect centering
    const gridWidth =
        5 * tileSize +
        6 * tileSpacing; // 5 tiles + 6 spaces (including borders)
    const gridHeight = 5 * tileSize + 6 * tileSpacing;

    // Center the grid within the available space
    final offsetX = (size.width - gridWidth) / 2;
    final offsetY = (size.height - gridHeight) / 2;

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final x = offsetX + tileSpacing + col * (tileSize + tileSpacing);
        final y = offsetY + tileSpacing + row * (tileSize + tileSpacing);

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, tileSize, tileSize),
          const Radius.circular(4),
        );

        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
