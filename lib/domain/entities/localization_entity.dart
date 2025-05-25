/// Domain entity representing localization data
/// Following clean architecture principles - this is pure business logic
class LocalizationEntity {
  final String locale;
  final String language;
  final Map<String, dynamic> translations;

  const LocalizationEntity({
    required this.locale,
    required this.language,
    required this.translations,
  });

  /// Get a translation by key (e.g., "app_title", "theme_settings")
  String translate(String key, {String? fallback}) {
    if (translations.containsKey(key)) {
      final value = translations[key];
      return value is String ? value : (fallback ?? key);
    }
    return fallback ?? key; // Return key if translation not found
  }

  /// Check if a translation exists for the given key
  bool hasTranslation(String key) {
    return translations.containsKey(key) && translations[key] is String;
  }

  LocalizationEntity copyWith({
    String? locale,
    String? language,
    Map<String, dynamic>? translations,
  }) {
    return LocalizationEntity(
      locale: locale ?? this.locale,
      language: language ?? this.language,
      translations: translations ?? this.translations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalizationEntity &&
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
    return 'LocalizationEntity(locale: $locale, language: $language, translations: ${translations.keys.length} keys)';
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
