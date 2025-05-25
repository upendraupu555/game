import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game/core/localization/localization_manager.dart';
import 'package:game/presentation/providers/localization_providers.dart';
import 'package:game/presentation/providers/theme_providers.dart';

void main() {
  group('Asset-Based Localization Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create provider container with overrides
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should provide English localization by default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text(LocalizationManager.appTitle(ref)),
                      Text(LocalizationManager.welcomeMessage(ref)),
                      Text(LocalizationManager.startGame(ref)),
                      Text(LocalizationManager.themeSettings(ref)),
                      Text(LocalizationManager.fontSettings(ref)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Wait for localization to load
      await tester.pumpAndSettle();

      // Verify English strings are displayed
      expect(find.text('2048 Game'), findsOneWidget);
      expect(find.text('Welcome to 2048!'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);
      expect(find.text('Theme Settings'), findsOneWidget);
      expect(find.text('Font Settings'), findsOneWidget);
    });

    testWidgets('should provide all theme-related strings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text(LocalizationManager.themeMode(ref)),
                      Text(LocalizationManager.lightThemePrimaryColor(ref)),
                      Text(LocalizationManager.darkThemePrimaryColor(ref)),
                      Text(LocalizationManager.themePreviewText(ref)),
                      Text(LocalizationManager.lightThemeDescription(ref)),
                      Text(LocalizationManager.darkThemeDescription(ref)),
                      Text(LocalizationManager.systemThemeDescription(ref)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify theme strings are displayed
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Light Theme Primary Color'), findsOneWidget);
      expect(find.text('Dark Theme Primary Color'), findsOneWidget);
      expect(find.text('This is how your theme colors will look in the app'), findsOneWidget);
      expect(find.text('Always use light theme'), findsOneWidget);
      expect(find.text('Always use dark theme'), findsOneWidget);
      expect(find.text('Follow system setting'), findsOneWidget);
    });

    testWidgets('should provide all font-related strings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text(LocalizationManager.fontFamily(ref)),
                      Text(LocalizationManager.fontPreviewText(ref)),
                      Text(LocalizationManager.fontNameBubblegumSans(ref)),
                      Text(LocalizationManager.fontNameChewy(ref)),
                      Text(LocalizationManager.fontNameComicNeue(ref)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify font strings are displayed
      expect(find.text('Font Family'), findsOneWidget);
      expect(find.text('This is how your selected font will look in the app'), findsOneWidget);
      expect(find.text('Bubblegum Sans'), findsOneWidget);
      expect(find.text('Chewy'), findsOneWidget);
      expect(find.text('Comic Neue'), findsOneWidget);
    });

    testWidgets('should provide all color name strings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text(LocalizationManager.colorNameCrimsonRed(ref)),
                      Text(LocalizationManager.colorNameOceanBlue(ref)),
                      Text(LocalizationManager.colorNameRosePink(ref)),
                      Text(LocalizationManager.colorNameSunsetOrange(ref)),
                      Text(LocalizationManager.colorNameSilverGray(ref)),
                      Text(LocalizationManager.colorNameForestGreen(ref)),
                      Text(LocalizationManager.colorNameGoldenYellow(ref)),
                      Text(LocalizationManager.colorNameCustom(ref)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify color name strings are displayed
      expect(find.text('Crimson Red'), findsOneWidget);
      expect(find.text('Ocean Blue'), findsOneWidget);
      expect(find.text('Rose Pink'), findsOneWidget);
      expect(find.text('Sunset Orange'), findsOneWidget);
      expect(find.text('Silver Gray'), findsOneWidget);
      expect(find.text('Forest Green'), findsOneWidget);
      expect(find.text('Golden Yellow'), findsOneWidget);
      expect(find.text('Custom Color'), findsOneWidget);
    });

    testWidgets('should provide common UI strings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text(LocalizationManager.loading(ref)),
                      Text(LocalizationManager.error(ref)),
                      Text(LocalizationManager.retry(ref)),
                      Text(LocalizationManager.reset(ref)),
                      Text(LocalizationManager.current(ref)),
                      Text(LocalizationManager.preview(ref)),
                      Text(LocalizationManager.primaryButton(ref)),
                      Text(LocalizationManager.outlinedButton(ref)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify common UI strings are displayed
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Outlined Button'), findsOneWidget);
    });

    test('should load localization from assets', () async {
      // Trigger localization loading
      container.read(localizationProvider);

      // Wait a bit for async loading
      await Future.delayed(const Duration(milliseconds: 100));

      final currentLocalization = container.read(currentLocalizationProvider);
      expect(currentLocalization, isNotNull);
      expect(currentLocalization!.locale, 'en');
      expect(currentLocalization.language, 'English');
    });

    test('should provide translation for flat keys', () async {
      // Trigger localization loading
      container.read(localizationProvider);

      // Wait a bit for async loading
      await Future.delayed(const Duration(milliseconds: 100));

      final appTitle = container.read(translationProvider('app_title'));
      final welcomeMessage = container.read(translationProvider('welcome_message'));
      final themeSettings = container.read(translationProvider('theme_settings'));

      expect(appTitle, '2048 Game');
      expect(welcomeMessage, 'Welcome to 2048!');
      expect(themeSettings, 'Theme Settings');
    });

    test('should handle missing translations gracefully', () async {
      // Trigger localization loading
      container.read(localizationProvider);

      // Wait a bit for async loading
      await Future.delayed(const Duration(milliseconds: 100));

      final missingKey = container.read(translationProvider('non_existent_key'));
      expect(missingKey, 'non_existent_key'); // Should return the key itself
    });

    test('should provide context-based translation methods', () {
      // Test context-based methods (these don't require WidgetRef)
      expect(LocalizationManager.appTitleWithContext, isA<Function>());
      expect(LocalizationManager.loadingWithContext, isA<Function>());
      expect(LocalizationManager.errorWithContext, isA<Function>());
      expect(LocalizationManager.retryWithContext, isA<Function>());
    });
  });
}
