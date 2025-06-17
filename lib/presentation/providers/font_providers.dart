import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/font_local_datasource.dart';
import '../../data/repositories/font_repository_impl.dart';
import '../../domain/entities/font_entity.dart';
import '../../domain/repositories/font_repository.dart';
import '../../domain/usecases/font_usecases.dart';
import '../../core/constants/app_constants.dart';
import 'theme_providers.dart';

// Data layer providers
final fontLocalDataSourceProvider = Provider<FontLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FontLocalDataSourceImpl(prefs);
});

final fontRepositoryProvider = Provider<FontRepository>((ref) {
  final localDataSource = ref.watch(fontLocalDataSourceProvider);
  return FontRepositoryImpl(localDataSource);
});

// Use case providers
final getFontSettingsUseCaseProvider = Provider<GetFontSettingsUseCase>((ref) {
  final repository = ref.watch(fontRepositoryProvider);
  return GetFontSettingsUseCase(repository);
});

final updateFontFamilyUseCaseProvider = Provider<UpdateFontFamilyUseCase>((
  ref,
) {
  final repository = ref.watch(fontRepositoryProvider);
  return UpdateFontFamilyUseCase(repository);
});

final resetFontUseCaseProvider = Provider<ResetFontUseCase>((ref) {
  final repository = ref.watch(fontRepositoryProvider);
  return ResetFontUseCase(repository);
});

final getAvailableFontsUseCaseProvider = Provider<GetAvailableFontsUseCase>((
  ref,
) {
  final repository = ref.watch(fontRepositoryProvider);
  return GetAvailableFontsUseCase(repository);
});

// Font state notifier
class FontNotifier extends StateNotifier<AsyncValue<FontEntity>> {
  FontNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadFontSettings();
  }

  final Ref _ref;

  Future<void> _loadFontSettings() async {
    try {
      final getFontUseCase = _ref.read(getFontSettingsUseCaseProvider);
      final fontEntity = await getFontUseCase.execute();
      state = AsyncValue.data(fontEntity);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateFont(FontEntity font) async {
    try {
      final updateUseCase = _ref.read(updateFontFamilyUseCaseProvider);
      final updatedFont = await updateUseCase.execute(font);
      state = AsyncValue.data(updatedFont);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetToDefault() async {
    try {
      final resetUseCase = _ref.read(resetFontUseCaseProvider);
      final defaultFont = await resetUseCase.execute();
      state = AsyncValue.data(defaultFont);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Main font provider
final fontProvider =
    StateNotifierProvider<FontNotifier, AsyncValue<FontEntity>>((ref) {
      return FontNotifier(ref);
    });

// Computed providers for UI convenience
final currentFontProvider = Provider<FontEntity?>((ref) {
  final fontState = ref.watch(fontProvider);
  return fontState.maybeWhen(data: (font) => font, orElse: () => null);
});

final currentFontFamilyProvider = Provider<String>((ref) {
  // TODO: Temporarily disabled font customization - always return default font
  if (!AppConstants.enableFontCustomization) {
    return AppConstants.defaultFontFamily; // Always use default font
  }
  final font = ref.watch(currentFontProvider);
  return font?.fontFamily ??
      AppConstants.defaultFontFamily; // Fallback to default
});

final availableFontsProvider = Provider<List<FontEntity>>((ref) {
  final getFontsUseCase = ref.watch(getAvailableFontsUseCaseProvider);
  return getFontsUseCase.execute();
});

// Note: sharedPreferencesProvider is imported from theme_providers.dart
