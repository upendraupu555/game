import '../entities/localization_entity.dart';

/// Abstract repository interface for localization management
/// Following clean architecture - domain layer defines the contract
abstract class LocalizationRepository {
  /// Load localization data for a specific locale
  Future<LocalizationEntity> loadLocalization(String locale);

  /// Get the current saved locale
  Future<String?> getCurrentLocale();

  /// Save the current locale preference
  Future<void> saveCurrentLocale(String locale);

  /// Get list of available locales
  Future<List<String>> getAvailableLocales();

  /// Check if a locale is supported
  Future<bool> isLocaleSupported(String locale);

  /// Get default locale
  String getDefaultLocale();

  /// Reset locale to default
  Future<void> resetToDefaultLocale();
}
