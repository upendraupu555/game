import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../core/constants/app_constants.dart';
import '../providers/powerup_selection_providers.dart';
import '../providers/game_providers.dart';

/// Provider for the game board's global key to track its position
final gameBoardKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

/// Overlay widget that appears when in powerup selection mode
class PowerupSelectionOverlay extends ConsumerWidget {
  const PowerupSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(powerupSelectionProvider);

    if (!selectionState.isSelectionMode ||
        selectionState.activePowerupType == null) {
      return const SizedBox.shrink();
    }

    // Return positioned content directly since this widget is already inside a Stack
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: RepaintBoundary(
        child: IgnorePointer(
          ignoring: false, // Allow interaction with overlay elements
          child: _DynamicPositionedOverlay(selectionState: selectionState),
        ),
      ),
    );
  }
}

/// Widget that dynamically positions overlay elements based on actual game board position
class _DynamicPositionedOverlay extends ConsumerStatefulWidget {
  final PowerupSelectionState selectionState;

  const _DynamicPositionedOverlay({required this.selectionState});

  @override
  ConsumerState<_DynamicPositionedOverlay> createState() =>
      _DynamicPositionedOverlayState();
}

class _DynamicPositionedOverlayState
    extends ConsumerState<_DynamicPositionedOverlay> {
  Rect? _gameBoardRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGameBoardPosition();
    });
  }

  @override
  void didUpdateWidget(_DynamicPositionedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGameBoardPosition();
    });
  }

  void _updateGameBoardPosition() {
    final gameBoardKey = ref.read(gameBoardKeyProvider);
    final renderBox =
        gameBoardKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null && mounted) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      setState(() {
        _gameBoardRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = 0;
    //MediaQuery.of(context).padding.top;
    final safeAreaBottom = 0;
    //  MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic positions based on game board location
    // final instructionTop = _gameBoardRect != null
    //     ? (_gameBoardRect!.top - 120).clamp(
    //         safeAreaTop + AppConstants.paddingMedium,
    //         _gameBoardRect!.top - 80,
    //       )
    //     : safeAreaTop + AppConstants.paddingMedium;

    // final cancelBottom = _gameBoardRect != null
    //     ? (screenHeight - _gameBoardRect!.bottom - 80).clamp(
    //         safeAreaBottom + AppConstants.paddingLarge,
    //         screenHeight - _gameBoardRect!.bottom - 60,
    //       )
    //     : safeAreaBottom + AppConstants.paddingLarge + 60;

    final instructionTop = 0.0;
    final cancelBottom = 150.0;

    return Stack(
      children: [
        // Top instruction banner - positioned above the game board
        Positioned(
          top: instructionTop,
          left: AppConstants.paddingMedium,
          right: AppConstants.paddingMedium,
          child: _buildInstructionBanner(context, ref, widget.selectionState),
        ),

        // Cancel button - positioned below the game board
        Positioned(
          bottom: cancelBottom,
          left: AppConstants.paddingLarge,
          right: AppConstants.paddingLarge,
          child: _buildCancelButton(context, ref),
        ),
      ],
    );
  }

  Widget _buildInstructionBanner(
    BuildContext context,
    WidgetRef ref,
    PowerupSelectionState selectionState,
  ) {
    final powerupType = selectionState.activePowerupType!;
    final message = selectionState.selectionMessage ?? 'Tap to select target';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: _getPowerupColor(powerupType).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _getPowerupColor(powerupType).withValues(alpha: 0.4),
            blurRadius: 8.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                powerupType.icon,
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      powerupType.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(gameProvider.notifier).cancelPowerupSelection();
        },
        icon: const Icon(Icons.close, color: Colors.white),
        label: const Text(
          'Cancel Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: AppConstants.elevationMedium,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Color _getPowerupColor(PowerupType powerupType) {
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

/// Widget that shows row/column indicators during selection mode
class SelectionModeIndicators extends ConsumerWidget {
  final int boardSize;

  const SelectionModeIndicators({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(powerupSelectionProvider);

    if (!selectionState.isSelectionMode ||
        selectionState.activePowerupType == null) {
      return const SizedBox.shrink();
    }

    final powerupType = selectionState.activePowerupType!;

    // Create a grid overlay for tile selection highlighting
    return _buildSelectionGrid(powerupType, ref);
  }

  Widget _buildSelectionGrid(PowerupType powerupType, WidgetRef ref) {
    // Use precise positioning to match the actual game board layout
    // These constants match the SlidingGameBoard positioning
    const double boardSize = 320.0;
    const double tileSize = 56.0;
    const double tileSpacing = 6.0;
    const double gridWidth = 5 * tileSize + 6 * tileSpacing;
    const double gridHeight = 5 * tileSize + 6 * tileSpacing;
    const double offsetX = (boardSize - gridWidth) / 2;
    const double offsetY = (boardSize - gridHeight) / 2;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          for (int row = 0; row < 5; row++)
            for (int col = 0; col < 5; col++)
              Positioned(
                left: offsetX + tileSpacing + col * (tileSize + tileSpacing),
                top: offsetY + tileSpacing + row * (tileSize + tileSpacing),
                width: tileSize,
                height: tileSize,
                child: _buildSelectionTile(powerupType, row, col, ref),
              ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile(
    PowerupType powerupType,
    int row,
    int col,
    WidgetRef ref,
  ) {
    final shouldHighlight = _shouldHighlightTile(powerupType, row, col, ref);

    if (!shouldHighlight) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        ref.read(gameProvider.notifier).selectTileForPowerup(row, col);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _getPowerupColor(powerupType), width: 2),
          color: _getPowerupColor(powerupType).withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: _getPowerupColor(powerupType).withValues(alpha: 0.3),
              blurRadius: 8.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldHighlightTile(
    PowerupType powerupType,
    int row,
    int col,
    WidgetRef ref,
  ) {
    final gameState = ref.watch(gameProvider).value;
    if (gameState == null) return false;

    // Check if there's a tile at this position
    final hasTile = gameState.board[row][col] != null;

    switch (powerupType) {
      case PowerupType.tileDestroyer:
        // Only highlight tiles that actually have a tile entity
        return hasTile;
      case PowerupType.rowClear:
      case PowerupType.columnClear:
        // Highlight all positions since we can clear empty rows/columns too
        return true;
      default:
        return true;
    }
  }

  Color _getPowerupColor(PowerupType powerupType) {
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
