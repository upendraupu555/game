import '../entities/theme_entity.dart';

/// Abstract repository interface for theme persistence
/// Following clean architecture - domain layer defines the contract
abstract class ThemeRepository {
  /// Load theme settings from persistent storage
  Future<ThemeEntity?> loadThemeSettings();

  /// Save theme settings to persistent storage
  Future<void> saveThemeSettings(ThemeEntity themeEntity);

  /// Reset theme settings to default values
  Future<void> resetThemeSettings();

  /// Get default theme settings
  ThemeEntity getDefaultThemeSettings();

  /// Get available color options
  List<ColorEntity> getAvailableColors();

  /// Get current platform brightness
  Brightness getCurrentPlatformBrightness();
}

/// Enum for platform brightness (avoiding Flutter dependency in domain)
enum Brightness {
  light,
  dark,
}
