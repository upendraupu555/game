import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/sound_entity.dart';
import '../logging/app_logger.dart';
import '../constants/app_constants.dart';

/// Core sound service for managing audio playback
/// This service handles the low-level audio operations using audioplayers
class SoundService {
  static SoundService? _instance;
  static SoundService get instance => _instance ??= SoundService._();

  SoundService._();

  final Map<SoundEventType, AudioPlayer> _players = {};
  final Map<SoundEventType, String> _soundPaths = {};
  bool _isInitialized = false;
  bool _isSystemMuted = false;

  /// Initialize the sound service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Temporarily disabled sound system initialization
    if (!AppConstants.enableSoundSystem) {
      AppLogger.info(
        'Sound system disabled - skipping initialization',
        tag: 'SoundService',
      );
      _isInitialized = true; // Mark as initialized to prevent further attempts
      return;
    }

    try {
      AppLogger.info('Initializing sound service', tag: 'SoundService');

      // Initialize sound paths mapping
      _initializeSoundPaths();

      // Create audio players for each sound type
      for (final soundType in SoundEventType.values) {
        _players[soundType] = AudioPlayer();
      }

      // Check system audio state
      await _checkSystemAudioState();

      _isInitialized = true;
      AppLogger.info(
        'Sound service initialized successfully',
        tag: 'SoundService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to initialize sound service',
        tag: 'SoundService',
        error: e,
      );
      rethrow;
    }
  }

  /// Dispose of all audio resources
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      AppLogger.info('Disposing sound service', tag: 'SoundService');

      // Stop all sounds
      await stopAllSounds();

      // Dispose all players
      for (final player in _players.values) {
        await player.dispose();
      }

      _players.clear();
      _soundPaths.clear();
      _isInitialized = false;

      AppLogger.info(
        'Sound service disposed successfully',
        tag: 'SoundService',
      );
    } catch (e) {
      AppLogger.error(
        'Error disposing sound service',
        tag: 'SoundService',
        error: e,
      );
    }
  }

  /// Play a sound effect
  Future<void> playSound(
    SoundEventType soundType, {
    double volume = 1.0,
  }) async {
    if (!_isInitialized) {
      AppLogger.warning('Sound service not initialized', tag: 'SoundService');
      return;
    }

    if (_isSystemMuted || volume == 0.0) {
      AppLogger.debug(
        'Sound muted or volume is 0',
        tag: 'SoundService',
        data: {
          'soundType': soundType.name,
          'isSystemMuted': _isSystemMuted,
          'volume': volume,
        },
      );
      return;
    }

    try {
      final player = _players[soundType];
      final soundPath = _soundPaths[soundType];

      if (player == null || soundPath == null) {
        AppLogger.warning(
          'Sound not found',
          tag: 'SoundService',
          data: {'soundType': soundType.name},
        );
        return;
      }

      // Stop current playback if any
      await player.stop();

      // Set volume
      await player.setVolume(volume.clamp(0.0, 1.0));

      // Play the sound
      await player.play(AssetSource(soundPath));

      AppLogger.debug(
        'Sound played',
        tag: 'SoundService',
        data: {
          'soundType': soundType.name,
          'volume': volume,
          'soundPath': soundPath,
        },
      );
    } catch (e) {
      AppLogger.error(
        'Failed to play sound: ${soundType.name} at volume $volume',
        tag: 'SoundService',
        error: e,
      );
    }
  }

  /// Preload all sound files for better performance
  Future<void> preloadSounds() async {
    if (!_isInitialized) return;

    try {
      AppLogger.info('Preloading sounds', tag: 'SoundService');

      final preloadTasks = <Future>[];

      for (final entry in _soundPaths.entries) {
        final soundType = entry.key;
        final soundPath = entry.value;
        final player = _players[soundType];

        if (player != null) {
          // Preload by setting the source without playing
          preloadTasks.add(
            player.setSource(AssetSource(soundPath)).catchError((e) {
              AppLogger.warning(
                'Failed to preload sound',
                tag: 'SoundService',
                data: {
                  'soundType': soundType.name,
                  'soundPath': soundPath,
                  'error': e.toString(),
                },
              );
            }),
          );
        }
      }

      await Future.wait(preloadTasks);
      AppLogger.info('Sound preloading completed', tag: 'SoundService');
    } catch (e) {
      AppLogger.error(
        'Error during sound preloading',
        tag: 'SoundService',
        error: e,
      );
    }
  }

  /// Stop all currently playing sounds
  Future<void> stopAllSounds() async {
    if (!_isInitialized) return;

    try {
      final stopTasks = _players.values.map((player) => player.stop());
      await Future.wait(stopTasks);

      AppLogger.debug('All sounds stopped', tag: 'SoundService');
    } catch (e) {
      AppLogger.error('Error stopping sounds', tag: 'SoundService', error: e);
    }
  }

  /// Check if the sound service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if system audio is muted
  bool get isSystemMuted => _isSystemMuted;

  /// Initialize the mapping between sound types and file paths
  void _initializeSoundPaths() {
    _soundPaths.addAll({
      // UI Sounds
      SoundEventType.buttonTap: 'sounds/ui_button_tap.mp3',
      SoundEventType.navigationTransition: 'sounds/ui_navigation.mp3',
      SoundEventType.menuOpen: 'sounds/ui_menu_open.mp3',
      SoundEventType.menuClose: 'sounds/ui_menu_close.mp3',
      SoundEventType.backButton: 'sounds/ui_back.mp3',

      // Game Sounds
      SoundEventType.tileMove: 'sounds/game_tile_move.mp3',
      SoundEventType.tileMerge: 'sounds/game_tile_merge.mp3',
      SoundEventType.tileAppear: 'sounds/game_tile_appear.mp3',
      SoundEventType.blockerCreate: 'sounds/game_blocker_create.mp3',
      SoundEventType.blockerMerge: 'sounds/game_blocker_merge.mp3',

      // Powerup Sounds
      SoundEventType.powerupUnlock: 'sounds/powerup_unlock.mp3',
      SoundEventType.powerupTileFreeze: 'sounds/powerup_tile_freeze.mp3',
      SoundEventType.powerupTileDestroyer: 'sounds/powerup_tile_destroyer.mp3',
      SoundEventType.powerupRowClear: 'sounds/powerup_row_clear.mp3',
      SoundEventType.powerupColumnClear: 'sounds/powerup_column_clear.mp3',

      // Time Attack Sounds
      SoundEventType.timerTick: 'sounds/timer_tick.mp3',
      SoundEventType.timerWarning: 'sounds/timer_warning.mp3',
      SoundEventType.timeUp: 'sounds/timer_time_up.mp3',

      // Game State Sounds
      SoundEventType.gameOver: 'sounds/game_over.mp3',
      SoundEventType.gameWin: 'sounds/game_win.mp3',
      SoundEventType.newGame: 'sounds/game_new.mp3',
      SoundEventType.pauseGame: 'sounds/game_pause.mp3',
      SoundEventType.resumeGame: 'sounds/game_resume.mp3',
    });
  }

  /// Check system audio state (mute, volume, etc.)
  Future<void> _checkSystemAudioState() async {
    try {
      // For now, we'll assume system is not muted
      // In a real implementation, you might want to check system volume
      // or listen to system audio state changes
      _isSystemMuted = false;
    } catch (e) {
      AppLogger.warning(
        'Could not check system audio state: $e',
        tag: 'SoundService',
      );
      _isSystemMuted = false;
    }
  }
}
