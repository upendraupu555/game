import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  late Animation<double> _moveAnimation;

  Map<String, TilePosition> _tilePositions = {};
  bool _isAnimating = false;
  final GestureDebouncer _gestureDebouncer = GestureDebouncer();
  Offset? _panStartPosition;

  // Performance optimization: Cache position calculations
  final Map<String, Offset> _positionCache = {};

  // Batch state updates to reduce rebuilds
  bool _hasPendingStateUpdate = false;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    // Create optimized animation with easing
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutCubic,
    );

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
    // Use cached position calculation for better performance
    final key = '${row.toStringAsFixed(2)}_${col.toStringAsFixed(2)}';

    return _positionCache.putIfAbsent(key, () {
      // Calculate position with perfect centering to match background grid
      const gridWidth = 5 * tileSize + 6 * tileSpacing;
      const gridHeight = 5 * tileSize + 6 * tileSpacing;

      final offsetX = (boardSize - gridWidth) / 2;
      final offsetY = (boardSize - gridHeight) / 2;

      final x = offsetX + tileSpacing + col * (tileSize + tileSpacing);
      final y = offsetY + tileSpacing + row * (tileSize + tileSpacing);
      return Offset(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInSelectionMode = ref.watch(isInSelectionModeProvider);

    return Stack(
      clipBehavior: Clip.none, // Allow overlay to extend beyond board bounds
      children: [
        GestureDetector(
          onPanStart: isInSelectionMode ? null : _handlePanStart,
          onPanEnd: isInSelectionMode ? null : _handlePanEnd,
          onTapDown: isInSelectionMode ? _handleTapDown : null,
          child: Container(
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

        // Selection mode indicators - positioned relative to the game board
        if (isInSelectionMode)
          Positioned.fill(child: SelectionModeIndicators(boardSize: 5)),
      ],
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
    return Positioned.fill(child: CustomPaint(painter: GridPainter()));
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

        // Alternative merge animation - "Ripple Wave" effect
        double scale = 1.0;
        double glowIntensity = 0.0;
        double rotation = 0.0;
        double pulseOpacity = 1.0;
        double rippleScale = 0.0;

        if (position.tile.isMerged) {
          final progress = _moveController.value;

          if (progress > 0.55) {
            // Animation starts at 55% of movement completion
            final mergeProgress = (progress - 0.55) / 0.45;

            if (mergeProgress <= 0.4) {
              // Phase 1: Ripple expansion (0-40%)
              final rippleProgress = mergeProgress / 0.4;
              rippleScale =
                  (Curves.easeOutQuart.transform(rippleProgress) * 2.0).clamp(
                    0.0,
                    10.0,
                  );
              glowIntensity = (rippleProgress * 0.6).clamp(0.0, 1.0);
              scale = (1.0 + (math.sin(rippleProgress * math.pi) * 0.15)).clamp(
                0.1,
                3.0,
              ); // Gentle wave
            } else if (mergeProgress <= 0.7) {
              // Phase 2: Tile emphasis (40-70%)
              final emphasisProgress = (mergeProgress - 0.4) / 0.3;
              final emphasisCurve = Curves.elasticOut.transform(
                emphasisProgress,
              );
              scale = (1.0 + (emphasisCurve * 0.25)).clamp(
                0.1,
                3.0,
              ); // Bounce to 125%
              glowIntensity = (0.6 - (emphasisProgress * 0.3)).clamp(
                0.0,
                1.0,
              ); // Fade ripple glow
              rippleScale = (2.0 + (emphasisProgress * 1.0)).clamp(
                0.0,
                10.0,
              ); // Continue ripple expansion

              // Add slight rotation for dynamic feel
              rotation = (math.sin(emphasisProgress * math.pi * 2) * 0.05)
                  .clamp(-0.5, 0.5);
            } else {
              // Phase 3: Settle with afterglow (70-100%)
              final settleProgress = (mergeProgress - 0.7) / 0.3;
              scale = (1.25 - (settleProgress * 0.25)).clamp(
                0.1,
                3.0,
              ); // Return to normal
              glowIntensity = (0.3 * (1.0 - settleProgress)).clamp(
                0.0,
                1.0,
              ); // Fade afterglow
              rippleScale = (3.0 + (settleProgress * 2.0)).clamp(
                0.0,
                10.0,
              ); // Final ripple fade
              rotation = (rotation * (1.0 - settleProgress)).clamp(
                -0.5,
                0.5,
              ); // Stop rotation

              // Subtle final pulse with proper clamping
              final pulsePhase = settleProgress * math.pi * 4; // 2 full cycles
              pulseOpacity =
                  (1.0 + (math.sin(pulsePhase) * 0.08 * (1.0 - settleProgress)))
                      .clamp(0.0, 1.0);
            }

            // Reduced logging for better performance
            if (AppConstants.enablePerformanceLogging &&
                mergeProgress % 0.2 < 0.05) {
              AppLogger.animation(
                'MERGE_ANIMATION_PROGRESS',
                data: {
                  'tileId': position.tile.id,
                  'progress': progress.toStringAsFixed(2),
                  'mergeProgress': mergeProgress.toStringAsFixed(2),
                  'scale': scale.toStringAsFixed(2),
                },
              );
            }
          }
        }

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect background
              if (rippleScale > 0)
                Transform.scale(
                  scale: rippleScale,
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Color(position.tile.colorValue).withValues(
                          alpha: (glowIntensity * 0.5).clamp(0.0, 1.0),
                        ),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(position.tile.colorValue).withValues(
                            alpha: (glowIntensity * 0.3).clamp(0.0, 1.0),
                          ),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              // Main tile
              Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: pulseOpacity.clamp(0.0, 1.0),
                    child: Container(
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        color: Color(position.tile.colorValue),
                        borderRadius: BorderRadius.circular(4),
                        // Add selection border if in selection mode
                        border:
                            isInSelectionMode &&
                                selectionState.activePowerupType != null
                            ? Border.all(
                                color: _getSelectionColor(
                                  selectionState.activePowerupType!,
                                ),
                                width: 3,
                              )
                            : null,
                        boxShadow: _buildTileShadows(
                          position.tile,
                          glowIntensity,
                          widget.gameState.isScenicMode,
                        ),
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
            ],
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
    // Calculate grid bounds
    const gridWidth = 5 * tileSize + 6 * tileSpacing;
    const gridHeight = 5 * tileSize + 6 * tileSpacing;

    final offsetX = (boardSize - gridWidth) / 2;
    final offsetY = (boardSize - gridHeight) / 2;

    // Check if tap is within grid bounds
    final relativeX = localPosition.dx - offsetX - tileSpacing;
    final relativeY = localPosition.dy - offsetY - tileSpacing;

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
    _panStartPosition = details.localPosition;
    AppLogger.userAction(
      'PAN_START_SLIDING_BOARD',
      data: {
        'startPosition':
            '(${details.localPosition.dx.toStringAsFixed(2)}, ${details.localPosition.dy.toStringAsFixed(2)})',
        'isAnimating': _isAnimating,
      },
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    // Block gestures during animations
    if (_isAnimating) {
      AppLogger.animation(
        'GESTURE_BLOCKED_ANIMATION',
        data: {
          'reason': 'Animation in progress',
          'animationValue': _moveController.value,
        },
      );
      return;
    }

    // Check debouncing
    if (!_gestureDebouncer.canProcessGesture()) {
      AppLogger.userAction(
        'GESTURE_DEBOUNCED_SLIDING_BOARD',
        data: {'reason': 'Gesture debounced'},
      );
      return;
    }

    // Use enhanced gesture analysis
    final result = GestureUtils.analyzeSwipe(
      details,
      startPosition: _panStartPosition,
      customVelocityThreshold: AppConstants.swipeVelocityThreshold,
      customDistanceThreshold: AppConstants.swipeDistanceThreshold,
    );

    AppLogger.userAction(
      'SLIDING_BOARD_GESTURE_ANALYSIS',
      data: {
        'result': result.toString(),
        'description': GestureUtils.getSwipeDescription(result),
        'isValid': result.isValid,
        'direction': result.direction?.toString(),
      },
    );

    // Execute move if swipe is valid
    if (result.isValid && result.direction != null) {
      AppLogger.userAction(
        'SLIDING_BOARD_MOVE_EXECUTED',
        data: {
          'direction': result.direction.toString(),
          'velocity': result.velocity.toStringAsFixed(2),
          'ratio': result.directionRatio.toStringAsFixed(2),
        },
      );
      widget.onMove(result.direction!);
    } else {
      AppLogger.userAction(
        'SLIDING_BOARD_MOVE_REJECTED',
        data: {'reason': result.reason},
      );
    }
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
