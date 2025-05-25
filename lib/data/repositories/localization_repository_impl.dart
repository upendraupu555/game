import '../../core/constants/app_constants.dart';
import '../../domain/entities/localization_entity.dart';
import '../../domain/repositories/localization_repository.dart';
import '../datasources/localization_asset_datasource.dart';
import '../datasources/localization_local_datasource.dart';

/// Implementation of localization repository
/// This is the data layer that implements the domain contract
class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationAssetDataSource _assetDataSource;
  final LocalizationLocalDataSource _localDataSource;

  LocalizationRepositoryImpl(
    this._assetDataSource,
    this._localDataSource,
  );

  @override
  Future<LocalizationEntity> loadLocalization(String locale) async {
    try {
      final localizationModel = await _assetDataSource.loadLocalization(locale);
      return localizationModel.toDomain();
    } catch (e) {
      // Log error in production
      throw Exception('Failed to load localization for locale $locale: $e');
    }
  }

  @override
  Future<String?> getCurrentLocale() async {
    try {
      return await _localDataSource.getCurrentLocale();
    } catch (e) {
      // Log error in production
      return null;
    }
  }

  @override
  Future<void> saveCurrentLocale(String locale) async {
    try {
      await _localDataSource.saveCurrentLocale(locale);
    } catch (e) {
      // Log error in production
      throw Exception('Failed to save current locale: $e');
    }
  }

  @override
  Future<List<String>> getAvailableLocales() async {
    try {
      return await _assetDataSource.getAvailableLocales();
    } catch (e) {
      // Log error in production and return default
      return [AppConstants.defaultLocale];
    }
  }

  @override
  Future<bool> isLocaleSupported(String locale) async {
    try {
      return await _assetDataSource.isLocaleSupported(locale);
    } catch (e) {
      // Log error in production
      return locale == AppConstants.defaultLocale;
    }
  }

  @override
  String getDefaultLocale() {
    return AppConstants.defaultLocale;
  }

  @override
  Future<void> resetToDefaultLocale() async {
    try {
      await _localDataSource.clearCurrentLocale();
    } catch (e) {
      // Log error in production
      throw Exception('Failed to reset to default locale: $e');
    }
  }
}
