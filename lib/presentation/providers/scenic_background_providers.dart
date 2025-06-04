import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scenic_background_entity.dart';
import '../../domain/repositories/scenic_background_repository.dart';
import '../../domain/usecases/scenic_background_usecases.dart';
import '../../data/datasources/scenic_background_local_datasource.dart';
import '../../data/repositories/scenic_background_repository_impl.dart';
import '../../core/logging/app_logger.dart';
import 'theme_providers.dart';

// Data source providers
final scenicBackgroundLocalDataSourceProvider = Provider<ScenicBackgroundLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ScenicBackgroundLocalDataSourceImpl(sharedPreferences);
});

// Repository providers
final scenicBackgroundRepositoryProvider = Provider<ScenicBackgroundRepository>((ref) {
  final localDataSource = ref.watch(scenicBackgroundLocalDataSourceProvider);
  return ScenicBackgroundRepositoryImpl(localDataSource);
});

// Use case providers
final getRandomScenicBackgroundUseCaseProvider = Provider<GetRandomScenicBackgroundUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return GetRandomScenicBackgroundUseCase(repository);
});

final getScenicBackgroundByIndexUseCaseProvider = Provider<GetScenicBackgroundByIndexUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return GetScenicBackgroundByIndexUseCase(repository);
});

final preloadScenicBackgroundsUseCaseProvider = Provider<PreloadScenicBackgroundsUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return PreloadScenicBackgroundsUseCase(repository);
});

final getAllScenicBackgroundsUseCaseProvider = Provider<GetAllScenicBackgroundsUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return GetAllScenicBackgroundsUseCase(repository);
});

final saveCurrentScenicBackgroundUseCaseProvider = Provider<SaveCurrentScenicBackgroundUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return SaveCurrentScenicBackgroundUseCase(repository);
});

final loadCurrentScenicBackgroundUseCaseProvider = Provider<LoadCurrentScenicBackgroundUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return LoadCurrentScenicBackgroundUseCase(repository);
});

final getScenicModeSettingsUseCaseProvider = Provider<GetScenicModeSettingsUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return GetScenicModeSettingsUseCase(repository);
});

final saveScenicModeSettingsUseCaseProvider = Provider<SaveScenicModeSettingsUseCase>((ref) {
  final repository = ref.watch(scenicBackgroundRepositoryProvider);
  return SaveScenicModeSettingsUseCase(repository);
});

// Scenic background state notifier
class ScenicBackgroundNotifier extends StateNotifier<AsyncValue<ScenicBackgroundEntity?>> {
  final Ref _ref;

  ScenicBackgroundNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadCurrentBackground();
  }

  Future<void> _loadCurrentBackground() async {
    try {
      final loadUseCase = _ref.read(loadCurrentScenicBackgroundUseCaseProvider);
      final currentIndex = await loadUseCase.execute();
      
      if (currentIndex != null) {
        final getByIndexUseCase = _ref.read(getScenicBackgroundByIndexUseCaseProvider);
        final background = await getByIndexUseCase.execute(currentIndex);
        state = AsyncValue.data(background);
      } else {
        // No saved background, get a random one
        await getRandomBackground();
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load current scenic background', error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> getRandomBackground() async {
    try {
      state = const AsyncValue.loading();
      final getRandomUseCase = _ref.read(getRandomScenicBackgroundUseCaseProvider);
      final background = await getRandomUseCase.execute();
      
      // Save the selected background
      final saveUseCase = _ref.read(saveCurrentScenicBackgroundUseCaseProvider);
      await saveUseCase.execute(background.index);
      
      state = AsyncValue.data(background);
      AppLogger.info('Random scenic background selected: ${background.name}');
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get random scenic background', error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setBackgroundByIndex(int index) async {
    try {
      state = const AsyncValue.loading();
      final getByIndexUseCase = _ref.read(getScenicBackgroundByIndexUseCaseProvider);
      final background = await getByIndexUseCase.execute(index);
      
      if (background != null) {
        // Save the selected background
        final saveUseCase = _ref.read(saveCurrentScenicBackgroundUseCaseProvider);
        await saveUseCase.execute(background.index);
        
        state = AsyncValue.data(background);
        AppLogger.info('Scenic background set: ${background.name}');
      } else {
        throw Exception('Background not found for index: $index');
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to set scenic background by index', error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> preloadBackgrounds(List<int> indices) async {
    try {
      final preloadUseCase = _ref.read(preloadScenicBackgroundsUseCaseProvider);
      await preloadUseCase.execute(indices);
      AppLogger.info('Scenic backgrounds preloaded: $indices');
    } catch (error) {
      AppLogger.error('Failed to preload scenic backgrounds', error: error);
    }
  }
}

// Scenic mode settings notifier
class ScenicModeSettingsNotifier extends StateNotifier<AsyncValue<ScenicModeSettings>> {
  final Ref _ref;

  ScenicModeSettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final getSettingsUseCase = _ref.read(getScenicModeSettingsUseCaseProvider);
      final settings = await getSettingsUseCase.execute();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load scenic mode settings', error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(ScenicModeSettings settings) async {
    try {
      final saveSettingsUseCase = _ref.read(saveScenicModeSettingsUseCaseProvider);
      await saveSettingsUseCase.execute(settings);
      state = AsyncValue.data(settings);
      AppLogger.info('Scenic mode settings updated: $settings');
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update scenic mode settings', error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleEnabled() async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(isEnabled: !currentSettings.isEnabled);
      await updateSettings(newSettings);
    }
  }

  Future<void> updateOpacity(double opacity) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(backgroundOpacity: opacity);
      await updateSettings(newSettings);
    }
  }

  Future<void> updateBlur(double blur) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(backgroundBlur: blur);
      await updateSettings(newSettings);
    }
  }
}

// Main providers
final scenicBackgroundProvider = StateNotifierProvider<ScenicBackgroundNotifier, AsyncValue<ScenicBackgroundEntity?>>((ref) {
  return ScenicBackgroundNotifier(ref);
});

final scenicModeSettingsProvider = StateNotifierProvider<ScenicModeSettingsNotifier, AsyncValue<ScenicModeSettings>>((ref) {
  return ScenicModeSettingsNotifier(ref);
});

// Computed providers for UI convenience
final currentScenicBackgroundProvider = Provider<ScenicBackgroundEntity?>((ref) {
  final backgroundState = ref.watch(scenicBackgroundProvider);
  return backgroundState.value;
});

final currentScenicModeSettingsProvider = Provider<ScenicModeSettings?>((ref) {
  final settingsState = ref.watch(scenicModeSettingsProvider);
  return settingsState.value;
});

final isScenicModeEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(currentScenicModeSettingsProvider);
  return settings?.isEnabled ?? true;
});

final scenicBackgroundOpacityProvider = Provider<double>((ref) {
  final settings = ref.watch(currentScenicModeSettingsProvider);
  return settings?.backgroundOpacity ?? 0.3;
});

final scenicBackgroundBlurProvider = Provider<double>((ref) {
  final settings = ref.watch(currentScenicModeSettingsProvider);
  return settings?.backgroundBlur ?? 2.0;
});
