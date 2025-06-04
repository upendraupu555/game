import 'dart:developer' as developer;

/// Centralized logging system for the 2048 game
/// Provides different log levels and structured logging
class AppLogger {
  static const String _appName = '2048Game';
  
  // Log levels
  static const int _debugLevel = 0;
  static const int _infoLevel = 1;
  static const int _warningLevel = 2;
  static const int _errorLevel = 3;
  
  // Current log level (can be changed for different environments)
  static int _currentLogLevel = _debugLevel;
  
  /// Set the minimum log level
  static void setLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        _currentLogLevel = _debugLevel;
        break;
      case LogLevel.info:
        _currentLogLevel = _infoLevel;
        break;
      case LogLevel.warning:
        _currentLogLevel = _warningLevel;
        break;
      case LogLevel.error:
        _currentLogLevel = _errorLevel;
        break;
    }
  }
  
  /// Log debug messages (development only)
  static void debug(String message, {String? tag, Object? data}) {
    if (_currentLogLevel <= _debugLevel) {
      _log('DEBUG', message, tag: tag, data: data);
    }
  }
  
  /// Log info messages
  static void info(String message, {String? tag, Object? data}) {
    if (_currentLogLevel <= _infoLevel) {
      _log('INFO', message, tag: tag, data: data);
    }
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? data}) {
    if (_currentLogLevel <= _warningLevel) {
      _log('WARNING', message, tag: tag, data: data);
    }
  }
  
  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _errorLevel) {
      _log('ERROR', message, tag: tag, data: error);
      if (stackTrace != null) {
        developer.log(
          stackTrace.toString(),
          name: '$_appName${tag != null ? ':$tag' : ''}',
          level: 1000, // Error level
        );
      }
    }
  }
  
  /// Log game events specifically
  static void gameEvent(String event, {Map<String, dynamic>? data}) {
    info('GAME_EVENT: $event', tag: 'GameEngine', data: data);
  }
  
  /// Log animation events
  static void animation(String event, {Map<String, dynamic>? data}) {
    debug('ANIMATION: $event', tag: 'Animation', data: data);
  }
  
  /// Log tile operations
  static void tile(String operation, {Map<String, dynamic>? data}) {
    debug('TILE: $operation', tag: 'TileEngine', data: data);
  }
  
  /// Log user interactions
  static void userAction(String action, {Map<String, dynamic>? data}) {
    info('USER_ACTION: $action', tag: 'UserInterface', data: data);
  }
  
  /// Log performance metrics
  static void performance(String metric, {Map<String, dynamic>? data}) {
    debug('PERFORMANCE: $metric', tag: 'Performance', data: data);
  }
  
  /// Internal logging method
  static void _log(String level, String message, {String? tag, Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = '$_appName${tag != null ? ':$tag' : ''}';
    
    String logMessage = '[$timestamp] [$level] $message';
    if (data != null) {
      logMessage += ' | Data: $data';
    }
    
    // Use developer.log for better debugging in Flutter DevTools
    developer.log(
      logMessage,
      name: logTag,
      time: DateTime.now(),
    );
  }
  
  /// Log game state changes
  static void gameState(String state, {
    int? score,
    int? bestScore,
    int? tilesCount,
    bool? isGameOver,
    bool? hasWon,
  }) {
    gameEvent('STATE_CHANGE', data: {
      'state': state,
      'score': score,
      'bestScore': bestScore,
      'tilesCount': tilesCount,
      'isGameOver': isGameOver,
      'hasWon': hasWon,
    });
  }
  
  /// Log tile movements
  static void tileMovement(String direction, {
    int? tilesMovedCount,
    int? mergesCount,
    int? newTileValue,
    String? newTilePosition,
  }) {
    gameEvent('TILE_MOVEMENT', data: {
      'direction': direction,
      'tilesMovedCount': tilesMovedCount,
      'mergesCount': mergesCount,
      'newTileValue': newTileValue,
      'newTilePosition': newTilePosition,
    });
  }
  
  /// Log new tile creation
  static void newTile({
    required int value,
    required int row,
    required int col,
    required String tileId,
    required int emptyPositionsCount,
  }) {
    tile('NEW_TILE_CREATED', data: {
      'value': value,
      'position': '($row, $col)',
      'tileId': tileId,
      'emptyPositionsAvailable': emptyPositionsCount,
    });
  }
  
  /// Log animation start/end
  static void animationEvent(String event, {
    String? animationType,
    int? duration,
    int? tilesCount,
  }) {
    animation(event, data: {
      'type': animationType,
      'duration': duration,
      'tilesCount': tilesCount,
    });
  }
}

/// Log levels enum
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Extension for easy logging from any class
extension LoggerExtension on Object {
  void logDebug(String message, {Object? data}) {
    AppLogger.debug(message, tag: runtimeType.toString(), data: data);
  }
  
  void logInfo(String message, {Object? data}) {
    AppLogger.info(message, tag: runtimeType.toString(), data: data);
  }
  
  void logWarning(String message, {Object? data}) {
    AppLogger.warning(message, tag: runtimeType.toString(), data: data);
  }
  
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }
}
