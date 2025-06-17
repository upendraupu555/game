import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/localization_asset_datasource.dart';
import '../../data/datasources/localization_local_datasource.dart';
import '../../data/repositories/localization_repository_impl.dart';
import '../../domain/entities/localization_entity.dart';
import '../../domain/repositories/localization_repository.dart';
import '../../domain/usecases/localization_usecases.dart';
import 'theme_providers.dart';

// Data layer providers
final localizationAssetDataSourceProvider =
    Provider<LocalizationAssetDataSource>((ref) {
      return LocalizationAssetDataSourceImpl();
    });

final localizationLocalDataSourceProvider =
    Provider<LocalizationLocalDataSource>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return LocalizationLocalDataSourceImpl(prefs);
    });

final localizationRepositoryProvider = Provider<LocalizationRepository>((ref) {
  final assetDataSource = ref.watch(localizationAssetDataSourceProvider);
  final localDataSource = ref.watch(localizationLocalDataSourceProvider);
  return LocalizationRepositoryImpl(assetDataSource, localDataSource);
});

// Use case providers
final getCurrentLocalizationUseCaseProvider =
    Provider<GetCurrentLocalizationUseCase>((ref) {
      final repository = ref.watch(localizationRepositoryProvider);
      return GetCurrentLocalizationUseCase(repository);
    });

final changeLocaleUseCaseProvider = Provider<ChangeLocaleUseCase>((ref) {
  final repository = ref.watch(localizationRepositoryProvider);
  return ChangeLocaleUseCase(repository);
});

final getAvailableLocalesUseCaseProvider = Provider<GetAvailableLocalesUseCase>(
  (ref) {
    final repository = ref.watch(localizationRepositoryProvider);
    return GetAvailableLocalesUseCase(repository);
  },
);

final resetLocaleUseCaseProvider = Provider<ResetLocaleUseCase>((ref) {
  final repository = ref.watch(localizationRepositoryProvider);
  return ResetLocaleUseCase(repository);
});

// Localization state notifier
class LocalizationNotifier
    extends StateNotifier<AsyncValue<LocalizationEntity>> {
  LocalizationNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadCurrentLocalization();
  }

  final Ref _ref;

  Future<void> loadCurrentLocalization() async {
    try {
      final getCurrentUseCase = _ref.read(
        getCurrentLocalizationUseCaseProvider,
      );
      final localization = await getCurrentUseCase.execute();
      state = AsyncValue.data(localization);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> changeLocale(String locale) async {
    try {
      final changeLocaleUseCase = _ref.read(changeLocaleUseCaseProvider);
      final localization = await changeLocaleUseCase.execute(locale);
      state = AsyncValue.data(localization);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetToDefault() async {
    try {
      final resetUseCase = _ref.read(resetLocaleUseCaseProvider);
      final localization = await resetUseCase.execute();
      state = AsyncValue.data(localization);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Main localization provider
final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, AsyncValue<LocalizationEntity>>(
      (ref) {
        return LocalizationNotifier(ref);
      },
    );

// Computed providers for UI convenience
final currentLocalizationProvider = Provider<LocalizationEntity?>((ref) {
  final localizationState = ref.watch(localizationProvider);
  return localizationState.maybeWhen(
    data: (localization) => localization,
    orElse: () => null,
  );
});

final currentLocaleProvider = Provider<String>((ref) {
  final localization = ref.watch(currentLocalizationProvider);
  return localization?.locale ?? 'en'; // Fallback to English
});

final availableLocalesProvider = FutureProvider<List<String>>((ref) async {
  final getAvailableUseCase = ref.watch(getAvailableLocalesUseCaseProvider);
  return await getAvailableUseCase.execute();
});

// Translation helper provider
final translationProvider = Provider.family<String, String>((ref, key) {
  final localization = ref.watch(currentLocalizationProvider);
  if (localization != null) {
    return localization.translate(key, fallback: key);
  }
  return key; // Return key if no localization available
});

// Note: sharedPreferencesProvider is imported from theme_providers.dart
