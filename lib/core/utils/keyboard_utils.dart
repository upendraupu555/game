import 'package:flutter/services.dart';
import '../../domain/entities/tile_entity.dart';
import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

/// Keyboard input utility for 2048 game controls
/// Supports both WASD and arrow keys for tile movement
class KeyboardUtils {
  KeyboardUtils._();

  /// Map keyboard keys to move directions
  static final Map<LogicalKeyboardKey, MoveDirection> _keyMappings = {
    // Arrow keys
    LogicalKeyboardKey.arrowUp: MoveDirection.up,
    LogicalKeyboardKey.arrowDown: MoveDirection.down,
    LogicalKeyboardKey.arrowLeft: MoveDirection.left,
    LogicalKeyboardKey.arrowRight: MoveDirection.right,

    // WASD keys
    LogicalKeyboardKey.keyW: MoveDirection.up,
    LogicalKeyboardKey.keyS: MoveDirection.down,
    LogicalKeyboardKey.keyA: MoveDirection.left,
    LogicalKeyboardKey.keyD: MoveDirection.right,
  };

  /// Get move direction from keyboard key
  static MoveDirection? getDirectionFromKey(LogicalKeyboardKey key) {
    return _keyMappings[key];
  }

  /// Check if a key is a valid game control key
  static bool isGameControlKey(LogicalKeyboardKey key) {
    return _keyMappings.containsKey(key);
  }

  /// Get all supported keys for documentation/help
  static List<LogicalKeyboardKey> get supportedKeys {
    return _keyMappings.keys.toList();
  }

  /// Get human-readable description of key mappings
  static String getKeyMappingDescription() {
    return '''
Keyboard Controls:
• W or ↑ Arrow: Move Up
• A or ← Arrow: Move Left  
• S or ↓ Arrow: Move Down
• D or → Arrow: Move Right
''';
  }

  /// Log keyboard input for debugging
  static void logKeyboardInput(
    LogicalKeyboardKey key,
    MoveDirection? direction,
  ) {
    if (AppConstants.enablePerformanceLogging) {
      AppLogger.userAction(
        'KEYBOARD_INPUT',
        data: {
          'key': key.keyLabel,
          'direction': direction?.toString().split('.').last,
          'isValid': direction != null,
        },
      );
    }
  }
}

/// Keyboard input debouncer to prevent rapid-fire key presses
class KeyboardDebouncer {
  DateTime? _lastKeyTime;
  final Duration _debounceDelay;

  KeyboardDebouncer({Duration? debounceDelay})
    : _debounceDelay = debounceDelay ?? AppConstants.keyboardDebounceDelay;

  /// Check if enough time has passed since the last key press
  bool canProcessKey() {
    final now = DateTime.now();
    if (_lastKeyTime == null) {
      _lastKeyTime = now;
      return true;
    }

    final timeSinceLastKey = now.difference(_lastKeyTime!);
    if (timeSinceLastKey >= _debounceDelay) {
      _lastKeyTime = now;
      return true;
    }

    return false;
  }

  /// Reset the debouncer
  void reset() {
    _lastKeyTime = null;
  }
}
