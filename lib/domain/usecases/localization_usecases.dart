import '../entities/localization_entity.dart';
import '../repositories/localization_repository.dart';

/// Use case for getting current localization
class GetCurrentLocalizationUseCase {
  final LocalizationRepository _repository;

  GetCurrentLocalizationUseCase(this._repository);

  Future<LocalizationEntity> execute() async {
    final currentLocale = await _repository.getCurrentLocale();
    final locale = currentLocale ?? _repository.getDefaultLocale();
    return await _repository.loadLocalization(locale);
  }
}

/// Use case for changing locale
class ChangeLocaleUseCase {
  final LocalizationRepository _repository;

  ChangeLocaleUseCase(this._repository);

  Future<LocalizationEntity> execute(String locale) async {
    final isSupported = await _repository.isLocaleSupported(locale);
    if (!isSupported) {
      throw Exception('Locale $locale is not supported');
    }

    await _repository.saveCurrentLocale(locale);
    return await _repository.loadLocalization(locale);
  }
}

/// Use case for getting available locales
class GetAvailableLocalesUseCase {
  final LocalizationRepository _repository;

  GetAvailableLocalesUseCase(this._repository);

  Future<List<String>> execute() async {
    return await _repository.getAvailableLocales();
  }
}

/// Use case for resetting locale to default
class ResetLocaleUseCase {
  final LocalizationRepository _repository;

  ResetLocaleUseCase(this._repository);

  Future<LocalizationEntity> execute() async {
    await _repository.resetToDefaultLocale();
    final defaultLocale = _repository.getDefaultLocale();
    return await _repository.loadLocalization(defaultLocale);
  }
}

/// Use case for getting translation by key
class GetTranslationUseCase {
  final LocalizationEntity _localization;

  GetTranslationUseCase(this._localization);

  String execute(String key, {String? fallback}) {
    return _localization.translate(key, fallback: fallback);
  }
}

/// Use case for checking if translation exists
class HasTranslationUseCase {
  final LocalizationEntity _localization;

  HasTranslationUseCase(this._localization);

  bool execute(String key) {
    return _localization.hasTranslation(key);
  }
}
