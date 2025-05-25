import '../entities/theme_entity.dart';
import '../repositories/theme_repository.dart';

/// Use case for getting current theme settings
class GetThemeSettingsUseCase {
  final ThemeRepository _repository;

  GetThemeSettingsUseCase(this._repository);

  Future<ThemeEntity> execute() async {
    final savedTheme = await _repository.loadThemeSettings();
    return savedTheme ?? _repository.getDefaultThemeSettings();
  }
}

/// Use case for updating theme mode
class UpdateThemeModeUseCase {
  final ThemeRepository _repository;

  UpdateThemeModeUseCase(this._repository);

  Future<ThemeEntity> execute(ThemeEntity currentTheme, ThemeModeEntity newMode) async {
    final updatedTheme = currentTheme.copyWith(themeMode: newMode);
    await _repository.saveThemeSettings(updatedTheme);
    return updatedTheme;
  }
}

/// Use case for updating light theme primary color
class UpdateLightPrimaryColorUseCase {
  final ThemeRepository _repository;

  UpdateLightPrimaryColorUseCase(this._repository);

  Future<ThemeEntity> execute(ThemeEntity currentTheme, ColorEntity newColor) async {
    final updatedTheme = currentTheme.copyWith(lightPrimaryColor: newColor);
    await _repository.saveThemeSettings(updatedTheme);
    return updatedTheme;
  }
}

/// Use case for updating dark theme primary color
class UpdateDarkPrimaryColorUseCase {
  final ThemeRepository _repository;

  UpdateDarkPrimaryColorUseCase(this._repository);

  Future<ThemeEntity> execute(ThemeEntity currentTheme, ColorEntity newColor) async {
    final updatedTheme = currentTheme.copyWith(darkPrimaryColor: newColor);
    await _repository.saveThemeSettings(updatedTheme);
    return updatedTheme;
  }
}

/// Use case for resetting theme to defaults
class ResetThemeUseCase {
  final ThemeRepository _repository;

  ResetThemeUseCase(this._repository);

  Future<ThemeEntity> execute() async {
    await _repository.resetThemeSettings();
    return _repository.getDefaultThemeSettings();
  }
}

/// Use case for getting available color options
class GetAvailableColorsUseCase {
  final ThemeRepository _repository;

  GetAvailableColorsUseCase(this._repository);

  List<ColorEntity> execute() {
    return _repository.getAvailableColors();
  }
}

/// Use case for determining current brightness based on theme mode
class GetCurrentBrightnessUseCase {
  final ThemeRepository _repository;

  GetCurrentBrightnessUseCase(this._repository);

  Brightness execute(ThemeEntity themeEntity) {
    switch (themeEntity.themeMode) {
      case ThemeModeEntity.light:
        return Brightness.light;
      case ThemeModeEntity.dark:
        return Brightness.dark;
      case ThemeModeEntity.system:
        return _repository.getCurrentPlatformBrightness();
    }
  }
}
