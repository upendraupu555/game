import '../../core/constants/app_constants.dart';
import '../../domain/entities/theme_entity.dart';
import '../../presentation/theme/colors.dart';

/// Data model for theme settings with JSON serialization
/// This is the data layer representation that handles persistence
class ThemeModel {
  final String themeMode;
  final int lightPrimaryColor;
  final int darkPrimaryColor;

  const ThemeModel({
    required this.themeMode,
    required this.lightPrimaryColor,
    required this.darkPrimaryColor,
  });

  /// Convert to domain entity
  ThemeEntity toDomain() {
    return ThemeEntity(
      themeMode: _stringToThemeMode(themeMode),
      lightPrimaryColor: _intToColorEntity(lightPrimaryColor),
      darkPrimaryColor: _intToColorEntity(darkPrimaryColor),
    );
  }

  /// Create from domain entity
  factory ThemeModel.fromDomain(ThemeEntity entity) {
    return ThemeModel(
      themeMode: _themeModeToString(entity.themeMode),
      lightPrimaryColor: entity.lightPrimaryColor.value,
      darkPrimaryColor: entity.darkPrimaryColor.value,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'lightPrimaryColor': lightPrimaryColor,
      'darkPrimaryColor': darkPrimaryColor,
    };
  }

  /// Create from JSON
  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      themeMode: json['themeMode'] ?? AppConstants.defaultThemeMode,
      lightPrimaryColor: json['lightPrimaryColor'] ?? AppConstants.defaultLightPrimaryValue,
      darkPrimaryColor: json['darkPrimaryColor'] ?? AppConstants.defaultDarkPrimaryValue,
    );
  }

  /// Get default theme model
  factory ThemeModel.defaultTheme() {
    return ThemeModel(
      themeMode: AppConstants.defaultThemeMode,
      lightPrimaryColor: AppConstants.defaultLightPrimaryValue,
      darkPrimaryColor: AppConstants.defaultDarkPrimaryValue,
    );
  }

  // Helper methods for conversion
  static ThemeModeEntity _stringToThemeMode(String value) {
    switch (value) {
      case AppConstants.themeModeLight:
        return ThemeModeEntity.light;
      case AppConstants.themeModeDark:
        return ThemeModeEntity.dark;
      case AppConstants.themeModeSystem:
      default:
        return ThemeModeEntity.system;
    }
  }

  static String _themeModeToString(ThemeModeEntity mode) {
    switch (mode) {
      case ThemeModeEntity.light:
        return AppConstants.themeModeLight;
      case ThemeModeEntity.dark:
        return AppConstants.themeModeDark;
      case ThemeModeEntity.system:
        return AppConstants.themeModeSystem;
    }
  }

  static ColorEntity _intToColorEntity(int colorValue) {
    final color = AppColors.getColorByHex(colorValue);
    final name = AppColors.getColorName(color);
    return ColorEntity(value: colorValue, name: name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeModel &&
        other.themeMode == themeMode &&
        other.lightPrimaryColor == lightPrimaryColor &&
        other.darkPrimaryColor == darkPrimaryColor;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        lightPrimaryColor.hashCode ^
        darkPrimaryColor.hashCode;
  }

  @override
  String toString() {
    return 'ThemeModel(themeMode: $themeMode, lightPrimaryColor: $lightPrimaryColor, darkPrimaryColor: $darkPrimaryColor)';
  }
}
