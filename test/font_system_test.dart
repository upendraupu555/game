import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game/core/constants/app_constants.dart';
import 'package:game/domain/entities/font_entity.dart';
import 'package:game/presentation/providers/font_providers.dart';
import 'package:game/presentation/providers/theme_providers.dart';
import 'package:game/presentation/theme/font_manager.dart';
import 'package:game/data/models/font_model.dart';

void main() {
  group('Font System Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    group('Font Entity Tests', () {
      test('should create font entity with correct properties', () {
        const font = FontEntity(
          fontFamily: AppConstants.fontFamilyBubblegumSans,
          displayName: AppConstants.fontNameBubblegumSans,
        );

        expect(font.fontFamily, AppConstants.fontFamilyBubblegumSans);
        expect(font.displayName, AppConstants.fontNameBubblegumSans);
      });

      test('should support equality comparison', () {
        const font1 = FontEntity(
          fontFamily: AppConstants.fontFamilyBubblegumSans,
          displayName: AppConstants.fontNameBubblegumSans,
        );

        const font2 = FontEntity(
          fontFamily: AppConstants.fontFamilyBubblegumSans,
          displayName: AppConstants.fontNameBubblegumSans,
        );

        expect(font1, equals(font2));
      });

      test('should support copyWith', () {
        const font = FontEntity(
          fontFamily: AppConstants.fontFamilyBubblegumSans,
          displayName: AppConstants.fontNameBubblegumSans,
        );

        final updatedFont = font.copyWith(
          fontFamily: AppConstants.fontFamilyChewy,
          displayName: AppConstants.fontNameChewy,
        );

        expect(updatedFont.fontFamily, AppConstants.fontFamilyChewy);
        expect(updatedFont.displayName, AppConstants.fontNameChewy);
      });
    });

    group('Font Model Tests', () {
      test('should serialize to and from JSON correctly', () {
        const fontModel = FontModel(
          fontFamily: AppConstants.fontFamilyBubblegumSans,
          displayName: AppConstants.fontNameBubblegumSans,
        );

        final json = fontModel.toJson();
        final fromJson = FontModel.fromJson(json);

        expect(fromJson.fontFamily, fontModel.fontFamily);
        expect(fromJson.displayName, fontModel.displayName);
      });

      test('should convert to domain entity correctly', () {
        const fontModel = FontModel(
          fontFamily: AppConstants.fontFamilyChewy,
          displayName: AppConstants.fontNameChewy,
        );

        final entity = fontModel.toDomain();

        expect(entity.fontFamily, fontModel.fontFamily);
        expect(entity.displayName, fontModel.displayName);
      });

      test('should create from domain entity correctly', () {
        const entity = FontEntity(
          fontFamily: AppConstants.fontFamilyComicNeue,
          displayName: AppConstants.fontNameComicNeue,
        );

        final model = FontModel.fromDomain(entity);

        expect(model.fontFamily, entity.fontFamily);
        expect(model.displayName, entity.displayName);
      });

      test('should provide default font model', () {
        final defaultModel = FontModel.defaultFont();

        expect(defaultModel.fontFamily, AppConstants.defaultFontFamily);
        expect(defaultModel.displayName, AppConstants.fontNameBubblegumSans);
      });
    });

    group('Font Manager Tests', () {
      test('should get correct display name for font families', () {
        expect(
          FontManager.getFontDisplayName(AppConstants.fontFamilyBubblegumSans),
          AppConstants.fontNameBubblegumSans,
        );
        expect(
          FontManager.getFontDisplayName(AppConstants.fontFamilyChewy),
          AppConstants.fontNameChewy,
        );
        expect(
          FontManager.getFontDisplayName(AppConstants.fontFamilyComicNeue),
          AppConstants.fontNameComicNeue,
        );
      });

      test('should check font availability correctly', () {
        expect(FontManager.isFontAvailable(AppConstants.fontFamilyBubblegumSans), true);
        expect(FontManager.isFontAvailable(AppConstants.fontFamilyChewy), true);
        expect(FontManager.isFontAvailable(AppConstants.fontFamilyComicNeue), true);
        expect(FontManager.isFontAvailable('UnknownFont'), false);
      });

      test('should return all available font families', () {
        final availableFonts = FontManager.getAvailableFontFamilies();

        expect(availableFonts.length, 3);
        expect(availableFonts.contains(AppConstants.fontFamilyBubblegumSans), true);
        expect(availableFonts.contains(AppConstants.fontFamilyChewy), true);
        expect(availableFonts.contains(AppConstants.fontFamilyComicNeue), true);
      });

      test('should create text style with correct font family', () {
        final textStyle = FontManager.createTextStyle(
          fontFamily: AppConstants.fontFamilyBubblegumSans,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );

        expect(textStyle.fontFamily, AppConstants.fontFamilyBubblegumSans);
        expect(textStyle.fontSize, 16);
        expect(textStyle.fontWeight, FontWeight.bold);
      });

      test('should create text theme with font family', () {
        final textTheme = FontManager.getTextTheme(
          AppConstants.fontFamilyBubblegumSans,
          brightness: Brightness.light,
        );

        expect(textTheme, isA<TextTheme>());
        // Note: We can't easily test the applied font family in the TextTheme
        // without more complex setup, but we can verify it doesn't throw
      });
    });

    group('Font Providers Tests', () {
      testWidgets('should provide default font initially', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                final fontState = ref.watch(fontProvider);
                return MaterialApp(
                  home: Scaffold(
                    body: fontState.when(
                      loading: () => const Text('Loading'),
                      error: (error, stack) => Text('Error: $error'),
                      data: (font) => Text('Font: ${font.fontFamily}'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Font: ${AppConstants.defaultFontFamily}'), findsOneWidget);
      });

      testWidgets('should update font when changed', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                final fontState = ref.watch(fontProvider);
                return MaterialApp(
                  home: Scaffold(
                    body: Column(
                      children: [
                        fontState.when(
                          loading: () => const Text('Loading'),
                          error: (error, stack) => Text('Error: $error'),
                          data: (font) => Text('Font: ${font.fontFamily}'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            const newFont = FontEntity(
                              fontFamily: AppConstants.fontFamilyChewy,
                              displayName: AppConstants.fontNameChewy,
                            );
                            ref.read(fontProvider.notifier).updateFont(newFont);
                          },
                          child: const Text('Change Font'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially shows default font
        expect(find.text('Font: ${AppConstants.defaultFontFamily}'), findsOneWidget);

        // Tap to change font
        await tester.tap(find.text('Change Font'));
        await tester.pumpAndSettle();

        // Should now show the new font
        expect(find.text('Font: ${AppConstants.fontFamilyChewy}'), findsOneWidget);
      });

      testWidgets('should provide available fonts', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                final availableFonts = ref.watch(availableFontsProvider);
                return MaterialApp(
                  home: Scaffold(
                    body: Column(
                      children: availableFonts
                          .map((font) => Text('Available: ${font.fontFamily}'))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Available: ${AppConstants.fontFamilyBubblegumSans}'), findsOneWidget);
        expect(find.text('Available: ${AppConstants.fontFamilyChewy}'), findsOneWidget);
        expect(find.text('Available: ${AppConstants.fontFamilyComicNeue}'), findsOneWidget);
      });
    });
  });
}
