import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sound_local_datasource.dart';
import '../../data/repositories/sound_repository_impl.dart';
import '../../domain/entities/sound_entity.dart';
import '../../domain/repositories/sound_repository.dart';
import '../../domain/usecases/sound_usecases.dart';
import '../../core/services/sound_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/constants/app_constants.dart';
import 'theme_providers.dart'; // For SharedPreferences provider

// Infrastructure providers
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService.instance;
});

// Data layer providers
final soundLocalDataSourceProvider = Provider<SoundLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SoundLocalDataSourceImpl(prefs);
});

final soundRepositoryProvider = Provider<SoundRepository>((ref) {
  final localDataSource = ref.watch(soundLocalDataSourceProvider);
  final soundService = ref.watch(soundServiceProvider);
  return SoundRepositoryImpl(localDataSource, soundService);
});

// Use case providers
final getSoundSettingsUseCaseProvider = Provider<GetSoundSettingsUseCase>((
  ref,
) {
  final repository = ref.watch(soundRepositoryProvider);
  return GetSoundSettingsUseCase(repository);
});

final updateSoundSettingsUseCaseProvider = Provider<UpdateSoundSettingsUseCase>(
  (ref) {
    final repository = ref.watch(soundRepositoryProvider);
    return UpdateSoundSettingsUseCase(repository);
  },
);

final toggleSoundUseCaseProvider = Provider<ToggleSoundUseCase>((ref) {
  final repository = ref.watch(soundRepositoryProvider);
  return ToggleSoundUseCase(repository);
});

final updateMasterVolumeUseCaseProvider = Provider<UpdateMasterVolumeUseCase>((
  ref,
) {
  final repository = ref.watch(soundRepositoryProvider);
  return UpdateMasterVolumeUseCase(repository);
});

final updateCategoryVolumeUseCaseProvider =
    Provider<UpdateCategoryVolumeUseCase>((ref) {
      final repository = ref.watch(soundRepositoryProvider);
      return UpdateCategoryVolumeUseCase(repository);
    });

final playSoundUseCaseProvider = Provider<PlaySoundUseCase>((ref) {
  final repository = ref.watch(soundRepositoryProvider);
  return PlaySoundUseCase(repository);
});

final initializeSoundSystemUseCaseProvider =
    Provider<InitializeSoundSystemUseCase>((ref) {
      final repository = ref.watch(soundRepositoryProvider);
      return InitializeSoundSystemUseCase(repository);
    });

final resetSoundSettingsUseCaseProvider = Provider<ResetSoundSettingsUseCase>((
  ref,
) {
  final repository = ref.watch(soundRepositoryProvider);
  return ResetSoundSettingsUseCase(repository);
});

// Sound state notifier
class SoundNotifier extends StateNotifier<AsyncValue<SoundEntity>> {
  SoundNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initializeAndLoadSoundSettings();
  }

  final Ref _ref;

  Future<void> _initializeAndLoadSoundSettings() async {
    try {
      // TODO: Temporarily disabled sound system initialization
      if (!AppConstants.enableSoundSystem) {
        // Create a default sound entity without initializing the sound system
        final defaultSoundEntity = SoundEntity(
          soundEnabled: false, // Disabled by default when sound system is off
          masterVolume: AppConstants.defaultMasterVolume,
          uiVolume: AppConstants.defaultUIVolume,
          gameVolume: AppConstants.defaultGameVolume,
          powerupVolume: AppConstants.defaultPowerupVolume,
          timerVolume: AppConstants.defaultTimerVolume,
        );
        state = AsyncValue.data(defaultSoundEntity);
        AppLogger.info(
          'Sound system disabled - using default settings',
          tag: 'SoundNotifier',
        );
        return;
      }

      // Initialize sound system first
      final initializeUseCase = _ref.read(initializeSoundSystemUseCaseProvider);
      await initializeUseCase.execute();

      // Then load sound settings
      final getSoundUseCase = _ref.read(getSoundSettingsUseCaseProvider);
      final soundEntity = await getSoundUseCase.execute();
      state = AsyncValue.data(soundEntity);

      AppLogger.info(
        'Sound system initialized and settings loaded',
        tag: 'SoundNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to initialize sound system',
        tag: 'SoundNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle sound on/off
  Future<void> toggleSound() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final toggleUseCase = _ref.read(toggleSoundUseCaseProvider);
      final newSoundEntity = await toggleUseCase.execute(currentState);
      state = AsyncValue.data(newSoundEntity);

      AppLogger.userAction(
        'SOUND_TOGGLED',
        data: {'soundEnabled': newSoundEntity.soundEnabled},
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to toggle sound',
        tag: 'SoundNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update master volume
  Future<void> updateMasterVolume(double volume) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final updateUseCase = _ref.read(updateMasterVolumeUseCaseProvider);
      final newSoundEntity = await updateUseCase.execute(currentState, volume);
      state = AsyncValue.data(newSoundEntity);

      AppLogger.userAction('MASTER_VOLUME_UPDATED', data: {'volume': volume});
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to update master volume',
        tag: 'SoundNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update category-specific volume
  Future<void> updateCategoryVolume(
    SoundVolumeCategory category,
    double volume,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final updateUseCase = _ref.read(updateCategoryVolumeUseCaseProvider);
      final newSoundEntity = await updateUseCase.execute(
        currentState,
        category,
        volume,
      );
      state = AsyncValue.data(newSoundEntity);

      AppLogger.userAction(
        'CATEGORY_VOLUME_UPDATED',
        data: {'category': category.name, 'volume': volume},
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to update category volume',
        tag: 'SoundNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Play a sound effect
  Future<void> playSound(
    SoundEventType soundType, {
    double? volumeOverride,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final playUseCase = _ref.read(playSoundUseCaseProvider);
      await playUseCase.execute(
        soundType,
        currentState,
        volumeOverride: volumeOverride,
      );

      AppLogger.debug(
        'Sound played via notifier',
        tag: 'SoundNotifier',
        data: {'soundType': soundType.name, 'volumeOverride': volumeOverride},
      );
    } catch (error) {
      AppLogger.error(
        'Failed to play sound: ${soundType.name}',
        tag: 'SoundNotifier',
        error: error,
      );
    }
  }

  /// Reset sound settings to defaults
  Future<void> resetSoundSettings() async {
    try {
      final resetUseCase = _ref.read(resetSoundSettingsUseCaseProvider);
      final defaultSoundEntity = await resetUseCase.execute();
      state = AsyncValue.data(defaultSoundEntity);

      AppLogger.userAction('SOUND_SETTINGS_RESET');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to reset sound settings',
        tag: 'SoundNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Main sound provider
final soundProvider =
    StateNotifierProvider<SoundNotifier, AsyncValue<SoundEntity>>((ref) {
      return SoundNotifier(ref);
    });

// Computed providers for UI convenience
final currentSoundProvider = Provider<SoundEntity?>((ref) {
  final soundState = ref.watch(soundProvider);
  return soundState.maybeWhen(data: (sound) => sound, orElse: () => null);
});

final isSoundEnabledProvider = Provider<bool>((ref) {
  final sound = ref.watch(currentSoundProvider);
  return sound?.soundEnabled ?? false;
});

final masterVolumeProvider = Provider<double>((ref) {
  final sound = ref.watch(currentSoundProvider);
  return sound?.masterVolume ?? 0.0;
});

// Helper provider for playing sounds throughout the app
final soundPlayerProvider =
    Provider<Future<void> Function(SoundEventType, {double? volumeOverride})>((
      ref,
    ) {
      return (SoundEventType soundType, {double? volumeOverride}) async {
        // TODO: Temporarily disabled - check feature flag
        if (!AppConstants.enableSoundSystem) {
          // Sound system is disabled, return early without playing sound
          return;
        }
        await ref
            .read(soundProvider.notifier)
            .playSound(soundType, volumeOverride: volumeOverride);
      };
    });
