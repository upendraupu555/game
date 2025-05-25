import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/theme_local_datasource.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/entities/theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/theme_usecases.dart';
// Import alias to avoid naming conflict
import '../../domain/repositories/theme_repository.dart' as domain;


// Infrastructure providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// Data layer providers
final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeLocalDataSourceImpl(prefs);
});

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final localDataSource = ref.watch(themeLocalDataSourceProvider);
  return ThemeRepositoryImpl(localDataSource);
});

// Use case providers
final getThemeSettingsUseCaseProvider = Provider<GetThemeSettingsUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return GetThemeSettingsUseCase(repository);
});

final updateThemeModeUseCaseProvider = Provider<UpdateThemeModeUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return UpdateThemeModeUseCase(repository);
});

final updateLightPrimaryColorUseCaseProvider = Provider<UpdateLightPrimaryColorUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return UpdateLightPrimaryColorUseCase(repository);
});

final updateDarkPrimaryColorUseCaseProvider = Provider<UpdateDarkPrimaryColorUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return UpdateDarkPrimaryColorUseCase(repository);
});

final resetThemeUseCaseProvider = Provider<ResetThemeUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return ResetThemeUseCase(repository);
});

final getAvailableColorsUseCaseProvider = Provider<GetAvailableColorsUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return GetAvailableColorsUseCase(repository);
});

final getCurrentBrightnessUseCaseProvider = Provider<GetCurrentBrightnessUseCase>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return GetCurrentBrightnessUseCase(repository);
});

// Theme state notifier
class ThemeNotifier extends StateNotifier<AsyncValue<ThemeEntity>> {
  ThemeNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadThemeSettings();
  }

  final Ref _ref;

  Future<void> _loadThemeSettings() async {
    try {
      final getThemeUseCase = _ref.read(getThemeSettingsUseCaseProvider);
      final themeEntity = await getThemeUseCase.execute();
      state = AsyncValue.data(themeEntity);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateThemeMode(ThemeModeEntity mode) async {
    final currentState = state;
    if (currentState is AsyncData<ThemeEntity>) {
      try {
        final updateUseCase = _ref.read(updateThemeModeUseCaseProvider);
        final updatedTheme = await updateUseCase.execute(currentState.value, mode);
        state = AsyncValue.data(updatedTheme);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> updateLightPrimaryColor(ColorEntity color) async {
    final currentState = state;
    if (currentState is AsyncData<ThemeEntity>) {
      try {
        final updateUseCase = _ref.read(updateLightPrimaryColorUseCaseProvider);
        final updatedTheme = await updateUseCase.execute(currentState.value, color);
        state = AsyncValue.data(updatedTheme);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> updateDarkPrimaryColor(ColorEntity color) async {
    final currentState = state;
    if (currentState is AsyncData<ThemeEntity>) {
      try {
        final updateUseCase = _ref.read(updateDarkPrimaryColorUseCaseProvider);
        final updatedTheme = await updateUseCase.execute(currentState.value, color);
        state = AsyncValue.data(updatedTheme);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final resetUseCase = _ref.read(resetThemeUseCaseProvider);
      final defaultTheme = await resetUseCase.execute();
      state = AsyncValue.data(defaultTheme);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Main theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AsyncValue<ThemeEntity>>((ref) {
  return ThemeNotifier(ref);
});

// Computed providers for UI convenience
final currentThemeProvider = Provider<ThemeEntity?>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.maybeWhen(
    data: (theme) => theme,
    orElse: () => null,
  );
});

final currentBrightnessProvider = Provider<Brightness>((ref) {
  final theme = ref.watch(currentThemeProvider);
  if (theme == null) return Brightness.light;
  
  final getBrightnessUseCase = ref.watch(getCurrentBrightnessUseCaseProvider);
  final domainBrightness = getBrightnessUseCase.execute(theme);
  
  return domainBrightness == domain.Brightness.dark 
      ? Brightness.dark 
      : Brightness.light;
});

final currentPrimaryColorProvider = Provider<Color>((ref) {
  final theme = ref.watch(currentThemeProvider);
  final brightness = ref.watch(currentBrightnessProvider);
  
  if (theme == null) return Colors.blue;
  
  final colorEntity = brightness == Brightness.dark 
      ? theme.darkPrimaryColor 
      : theme.lightPrimaryColor;
      
  return colorEntity.toFlutterColor();
});

final availableColorsProvider = Provider<List<ColorEntity>>((ref) {
  final getColorsUseCase = ref.watch(getAvailableColorsUseCaseProvider);
  return getColorsUseCase.execute();
});

