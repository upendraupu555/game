import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/gesture_utils.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/tile_entity.dart';
import '../providers/powerup_selection_providers.dart';
import '../providers/game_providers.dart';
import 'powerup_selection_overlay.dart';

/// Simple Flutter widget-based game board for 2048
class SimpleGameBoard extends ConsumerStatefulWidget {
  final GameEntity gameState;
  final Function(MoveDirection) onMove;

  const SimpleGameBoard({
    super.key,
    required this.gameState,
    required this.onMove,
  });

  @override
  ConsumerState<SimpleGameBoard> createState() => _SimpleGameBoardState();
}

class _SimpleGameBoardState extends ConsumerState<SimpleGameBoard> {
  final GestureDebouncer _gestureDebouncer = GestureDebouncer();
  Offset? _panStartPosition;

  @override
  Widget build(BuildContext context) {
    final isInSelectionMode = ref.watch(isInSelectionModeProvider);

    return Stack(
      clipBehavior: Clip.none, // Allow overlay to extend beyond board bounds
      children: [
        GestureDetector(
          onPanStart: isInSelectionMode ? null : _handlePanStart,
          onPanEnd: isInSelectionMode ? null : _handlePanEnd,
          child: Container(
            width: 320,
            height: 320,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBBADA0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: 25,
              itemBuilder: (context, index) {
                final row = index ~/ 5;
                final col = index % 5;

                // Safety check for board size compatibility
                if (row >= widget.gameState.board.length ||
                    widget.gameState.board.isEmpty ||
                    col >= widget.gameState.board[0].length) {
                  return _buildTile(null, row, col, ref);
                }

                final tile = widget.gameState.board[row][col];
                return _buildTile(tile, row, col, ref);
              },
            ),
          ),
        ),

        // Selection mode indicators - positioned relative to the game board
        if (isInSelectionMode)
          Positioned.fill(child: SelectionModeIndicators(boardSize: 5)),
      ],
    );
  }

  Widget _buildTile(TileEntity? tile, int row, int col, WidgetRef ref) {
    final isInSelectionMode = ref.watch(isInSelectionModeProvider);

    Widget tileWidget;

    if (tile == null) {
      tileWidget = Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCDC1B4),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    } else {
      tileWidget = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Color(tile.colorValue),
          borderRadius: BorderRadius.circular(4),
          // Add border for blocker tiles
          border: tile.isBlocker
              ? Border.all(color: Colors.red, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: tile.isNew ? 1.0 : (tile.isMerged ? 1.1 : 1.0),
          child: Center(
            child: Text(
              tile.displayText,
              style: TextStyle(
                color: Color(tile.textColorValue),
                fontSize: tile.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: 'BubblegumSans',
              ),
            ),
          ),
        ),
      );
    }

    // Wrap with selection highlight if in selection mode
    if (isInSelectionMode) {
      tileWidget = TileSelectionHighlight(
        row: row,
        col: col,
        hasTile: tile != null,
        child: tileWidget,
      );
    }

    // Always add tap detection for selection mode (works for both empty and filled tiles)
    if (isInSelectionMode) {
      tileWidget = GestureDetector(
        onTap: () {
          ref.read(gameProvider.notifier).selectTileForPowerup(row, col);
        },
        child: tileWidget,
      );
    }

    return tileWidget;
  }

  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = details.localPosition;
    AppLogger.userAction(
      'PAN_START_SIMPLE_BOARD',
      data: {
        'startPosition':
            '(${details.localPosition.dx.toStringAsFixed(2)}, ${details.localPosition.dy.toStringAsFixed(2)})',
      },
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    // Check debouncing
    if (!_gestureDebouncer.canProcessGesture()) {
      AppLogger.userAction(
        'GESTURE_DEBOUNCED_SIMPLE_BOARD',
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
      'SIMPLE_BOARD_GESTURE_ANALYSIS',
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
        'SIMPLE_BOARD_MOVE_EXECUTED',
        data: {
          'direction': result.direction.toString(),
          'velocity': result.velocity.toStringAsFixed(2),
          'ratio': result.directionRatio.toStringAsFixed(2),
        },
      );
      widget.onMove(result.direction!);
    } else {
      AppLogger.userAction(
        'SIMPLE_BOARD_MOVE_REJECTED',
        data: {'reason': result.reason},
      );
    }
  }
}
