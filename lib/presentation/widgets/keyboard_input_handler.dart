import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/keyboard_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/tile_entity.dart';
import '../providers/game_providers.dart';
import '../providers/powerup_selection_providers.dart';

/// Keyboard input handler widget that wraps game content and provides keyboard controls
/// Supports both WASD and arrow keys for tile movement
class KeyboardInputHandler extends ConsumerStatefulWidget {
  final Widget child;
  final Function(MoveDirection)? onMove;
  final bool enabled;
  final bool enableDebouncing;

  const KeyboardInputHandler({
    super.key,
    required this.child,
    this.onMove,
    this.enabled = true,
    this.enableDebouncing = true,
  });

  @override
  ConsumerState<KeyboardInputHandler> createState() =>
      _KeyboardInputHandlerState();
}

class _KeyboardInputHandlerState extends ConsumerState<KeyboardInputHandler> {
  final KeyboardDebouncer _keyboardDebouncer = KeyboardDebouncer();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          // Ensure focus is maintained when user taps on the game area
          _focusNode.requestFocus();
        },
        child: widget.child,
      ),
    );
  }

  /// Handle keyboard input events
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only handle key down events to prevent double triggers
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Check if this is a game control key
    if (!KeyboardUtils.isGameControlKey(event.logicalKey)) {
      return KeyEventResult.ignored;
    }

    // Check debouncing if enabled
    if (widget.enableDebouncing && !_keyboardDebouncer.canProcessKey()) {
      if (AppConstants.enablePerformanceLogging) {
        AppLogger.userAction(
          'KEYBOARD_INPUT_DEBOUNCED',
          data: {
            'key': event.logicalKey.keyLabel,
            'reason': 'Debounced - too fast',
          },
        );
      }
      return KeyEventResult.handled;
    }

    // Get the move direction from the key
    final direction = KeyboardUtils.getDirectionFromKey(event.logicalKey);
    if (direction == null) {
      return KeyEventResult.ignored;
    }

    // Log the keyboard input
    KeyboardUtils.logKeyboardInput(event.logicalKey, direction);

    // Execute the move callback
    if (widget.onMove != null) {
      widget.onMove!(direction);

      if (AppConstants.enablePerformanceLogging) {
        AppLogger.userAction(
          'KEYBOARD_MOVE_EXECUTED',
          data: {
            'key': event.logicalKey.keyLabel,
            'direction': direction.toString().split('.').last,
          },
        );
      }
    }

    return KeyEventResult.handled;
  }
}

/// Enhanced keyboard input handler with additional game state awareness
class GameKeyboardInputHandler extends ConsumerStatefulWidget {
  final Widget child;
  final Function(MoveDirection)? onMove;
  final bool enabled;
  final bool enableDebouncing;

  const GameKeyboardInputHandler({
    super.key,
    required this.child,
    this.onMove,
    this.enabled = true,
    this.enableDebouncing = true,
  });

  @override
  ConsumerState<GameKeyboardInputHandler> createState() =>
      _GameKeyboardInputHandlerState();
}

class _GameKeyboardInputHandlerState
    extends ConsumerState<GameKeyboardInputHandler> {
  final KeyboardDebouncer _keyboardDebouncer = KeyboardDebouncer();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          // Ensure focus is maintained when user taps on the game area
          _focusNode.requestFocus();
        },
        child: widget.child,
      ),
    );
  }

  /// Handle keyboard input events with game state awareness
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only handle key down events to prevent double triggers
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Check if this is a game control key
    if (!KeyboardUtils.isGameControlKey(event.logicalKey)) {
      return KeyEventResult.ignored;
    }

    // Check game state - don't process input if game is paused, over, or in selection mode
    final gameState = ref.read(gameProvider).value;
    if (gameState != null) {
      if (gameState.isGameOver || gameState.isPaused) {
        if (AppConstants.enablePerformanceLogging) {
          AppLogger.userAction(
            'KEYBOARD_INPUT_BLOCKED',
            data: {
              'key': event.logicalKey.keyLabel,
              'reason': gameState.isGameOver ? 'Game over' : 'Game paused',
            },
          );
        }
        return KeyEventResult.handled;
      }
    }

    // Check if in selection mode (for powerups)
    final isInSelectionMode = ref
        .read(powerupSelectionProvider)
        .isSelectionMode;
    if (isInSelectionMode) {
      if (AppConstants.enablePerformanceLogging) {
        AppLogger.userAction(
          'KEYBOARD_INPUT_BLOCKED',
          data: {
            'key': event.logicalKey.keyLabel,
            'reason': 'In powerup selection mode',
          },
        );
      }
      return KeyEventResult.handled;
    }

    // Check debouncing if enabled
    if (widget.enableDebouncing && !_keyboardDebouncer.canProcessKey()) {
      if (AppConstants.enablePerformanceLogging) {
        AppLogger.userAction(
          'KEYBOARD_INPUT_DEBOUNCED',
          data: {
            'key': event.logicalKey.keyLabel,
            'reason': 'Debounced - too fast',
          },
        );
      }
      return KeyEventResult.handled;
    }

    // Get the move direction from the key
    final direction = KeyboardUtils.getDirectionFromKey(event.logicalKey);
    if (direction == null) {
      return KeyEventResult.ignored;
    }

    // Log the keyboard input
    KeyboardUtils.logKeyboardInput(event.logicalKey, direction);

    // Execute the move callback
    if (widget.onMove != null) {
      widget.onMove!(direction);

      if (AppConstants.enablePerformanceLogging) {
        AppLogger.userAction(
          'KEYBOARD_MOVE_EXECUTED',
          data: {
            'key': event.logicalKey.keyLabel,
            'direction': direction.toString().split('.').last,
          },
        );
      }
    }

    return KeyEventResult.handled;
  }
}
