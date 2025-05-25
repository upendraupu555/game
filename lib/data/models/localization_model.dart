import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/localization_entity.dart';

/// Data model for localization with JSON serialization
/// This is the data layer representation that handles persistence and asset loading
class LocalizationModel {
  final String locale;
  final String language;
  final Map<String, dynamic> translations;

  const LocalizationModel({
    required this.locale,
    required this.language,
    required this.translations,
  });

  /// Convert to domain entity
  LocalizationEntity toDomain() {
    return LocalizationEntity(
      locale: locale,
      language: language,
      translations: translations,
    );
  }

  /// Create from domain entity
  factory LocalizationModel.fromDomain(LocalizationEntity entity) {
    return LocalizationModel(
      locale: entity.locale,
      language: entity.language,
      translations: entity.translations,
    );
  }

  /// Create from JSON string (from asset file)
  factory LocalizationModel.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return LocalizationModel(
        locale: json['locale'] ?? AppConstants.defaultLocale,
        language: json['language'] ?? 'Unknown',
        translations: json,
      );
    } catch (e) {
      throw Exception('Failed to parse localization JSON: $e');
    }
  }

  /// Create from Map
  factory LocalizationModel.fromMap(Map<String, dynamic> map) {
    return LocalizationModel(
      locale: map['locale'] ?? AppConstants.defaultLocale,
      language: map['language'] ?? 'Unknown',
      translations: map,
    );
  }

  /// Convert to JSON string
  String toJson() {
    return jsonEncode(translations);
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return translations;
  }

  /// Get default English localization model
  factory LocalizationModel.defaultEnglish() {
    return const LocalizationModel(
      locale: AppConstants.defaultLocale,
      language: 'English',
      translations: {
        'locale': AppConstants.defaultLocale,
        'language': 'English',
        'app_title': '2048 Game',
        'app_version': '1.0.0',
        'welcome_message': 'Welcome to 2048!',
        'start_game': 'Start Game',
        'coming_soon': 'Game coming soon!',
        'reset': 'Reset',
        'loading': 'Loading...',
        'current': 'Current',
        'preview': 'Preview',
        'error': 'Error',
        'retry': 'Retry',
        'theme_settings': 'Theme Settings',
        'font_settings': 'Font Settings',
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalizationModel &&
        other.locale == locale &&
        other.language == language &&
        _mapEquals(other.translations, translations);
  }

  @override
  int get hashCode {
    return locale.hashCode ^ language.hashCode ^ translations.hashCode;
  }

  @override
  String toString() {
    return 'LocalizationModel(locale: $locale, language: $language, translations: ${translations.keys.length} keys)';
  }

  /// Deep equality check for maps
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final value1 = map1[key];
      final value2 = map2[key];
      if (value1 is Map<String, dynamic> && value2 is Map<String, dynamic>) {
        if (!_mapEquals(value1, value2)) return false;
      } else if (value1 != value2) {
        return false;
      }
    }
    return true;
  }
}
