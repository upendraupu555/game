import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game/domain/entities/theme_entity.dart';
import 'package:game/presentation/providers/theme_providers.dart';
import 'package:game/presentation/theme/app_theme.dart';
import 'package:game/presentation/theme/colors.dart';
import 'package:game/data/models/theme_model.dart';

void main() {
  group('Clean Architecture Theme System Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    test('Default theme settings should be applied', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      // Wait for theme to load by polling until it's available
      ThemeEntity? currentTheme;
      for (int i = 0; i < 10; i++) {
        currentTheme = container.read(currentThemeProvider);
        if (currentTheme != null) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      expect(currentTheme?.themeMode, ThemeModeEntity.system);
      expect(currentTheme?.lightPrimaryColor.value, AppColors.defaultLightPrimary.value);
      expect(currentTheme?.darkPrimaryColor.value, AppColors.defaultDarkPrimary.value);

      container.dispose();
    });

    testWidgets('Theme mode can be changed', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final themeNotifier = container.read(themeProvider.notifier);

      // Wait for initial load
      await tester.pumpAndSettle();

      // Change to light mode
      await themeNotifier.updateThemeMode(ThemeModeEntity.light);
      await tester.pumpAndSettle();

      final lightTheme = container.read(currentThemeProvider);
      expect(lightTheme?.themeMode, ThemeModeEntity.light);

      // Change to dark mode
      await themeNotifier.updateThemeMode(ThemeModeEntity.dark);
      await tester.pumpAndSettle();

      final darkTheme = container.read(currentThemeProvider);
      expect(darkTheme?.themeMode, ThemeModeEntity.dark);

      container.dispose();
    });

    testWidgets('Primary colors can be changed', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final themeNotifier = container.read(themeProvider.notifier);

      // Wait for initial load
      await tester.pumpAndSettle();

      // Change light primary color
      final newLightColor = ColorEntity(
        value: AppColors.primaryGreen.value,
        name: AppColors.getColorName(AppColors.primaryGreen),
      );
      await themeNotifier.updateLightPrimaryColor(newLightColor);
      await tester.pumpAndSettle();

      final updatedTheme1 = container.read(currentThemeProvider);
      expect(updatedTheme1?.lightPrimaryColor.value, AppColors.primaryGreen.value);

      // Change dark primary color
      final newDarkColor = ColorEntity(
        value: AppColors.primaryPink.value,
        name: AppColors.getColorName(AppColors.primaryPink),
      );
      await themeNotifier.updateDarkPrimaryColor(newDarkColor);
      await tester.pumpAndSettle();

      final updatedTheme2 = container.read(currentThemeProvider);
      expect(updatedTheme2?.darkPrimaryColor.value, AppColors.primaryPink.value);

      container.dispose();
    });

    test('Theme model can be serialized and deserialized', () {
      final themeModel = ThemeModel(
        themeMode: 'dark',
        lightPrimaryColor: AppColors.primaryGreen.value,
        darkPrimaryColor: AppColors.primaryPink.value,
      );

      final json = themeModel.toJson();
      final deserializedModel = ThemeModel.fromJson(json);

      expect(deserializedModel.themeMode, themeModel.themeMode);
      expect(deserializedModel.lightPrimaryColor, themeModel.lightPrimaryColor);
      expect(deserializedModel.darkPrimaryColor, themeModel.darkPrimaryColor);
    });

    test('Theme model converts to domain entity correctly', () {
      final themeModel = ThemeModel(
        themeMode: 'light',
        lightPrimaryColor: AppColors.primaryBlue.value,
        darkPrimaryColor: AppColors.primaryTeal.value,
      );

      final domainEntity = themeModel.toDomain();

      expect(domainEntity.themeMode, ThemeModeEntity.light);
      expect(domainEntity.lightPrimaryColor.value, AppColors.primaryBlue.value);
      expect(domainEntity.darkPrimaryColor.value, AppColors.primaryTeal.value);
    });

    test('AppTheme generates correct light and dark themes', () {
      final lightColor = AppColors.primaryBlue;
      final darkColor = AppColors.primaryTeal;

      final lightTheme = AppTheme.lightTheme(lightColor);
      final darkTheme = AppTheme.darkTheme(darkColor);

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.colorScheme.primary, isNot(equals(darkTheme.colorScheme.primary)));
    });

    test('Available colors provider returns correct colors', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final availableColors = container.read(availableColorsProvider);

      expect(availableColors.length, AppColors.primaryColorOptions.length);
      expect(availableColors.first.value, AppColors.primaryBlue.value);
      expect(availableColors.first.name, AppColors.getColorName(AppColors.primaryBlue));

      container.dispose();
    });

    test('Current primary color provider works correctly', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      // Wait for theme to load by polling
      for (int i = 0; i < 10; i++) {
        final themeState = container.read(themeProvider);
        if (themeState is AsyncData) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final currentColor = container.read(currentPrimaryColorProvider);

      // Should return a valid color (not null and has valid color value)
      expect(currentColor, isA<Color>());
      expect((currentColor.a * 255.0).round() & 0xff, greaterThan(0));

      container.dispose();
    });
  });
}
