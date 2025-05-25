import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game/core/constants/app_constants.dart';
import 'package:game/core/navigation/navigation_service.dart';
import 'package:game/domain/entities/navigation_entity.dart';
import 'package:game/presentation/providers/navigation_providers.dart';
import 'package:game/presentation/providers/theme_providers.dart';
import 'package:game/presentation/widgets/navigation_helper.dart';

void main() {
  group('Navigation System Tests', () {
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

    group('NavigationService', () {
      test('should have correct navigator key', () {
        expect(NavigationService.navigatorKey, isA<GlobalKey<NavigatorState>>());
      });

      test('should generate routes correctly', () {
        // Test home route
        final homeRoute = NavigationService.generateRoute(
          const RouteSettings(name: AppRoutes.home),
        );
        expect(homeRoute, isA<MaterialPageRoute>());

        // Test theme settings route
        final themeRoute = NavigationService.generateRoute(
          const RouteSettings(name: AppRoutes.themeSettings),
        );
        expect(themeRoute, isA<MaterialPageRoute>());

        // Test font settings route
        final fontRoute = NavigationService.generateRoute(
          const RouteSettings(name: AppRoutes.fontSettings),
        );
        expect(fontRoute, isA<MaterialPageRoute>());

        // Test game route
        final gameRoute = NavigationService.generateRoute(
          const RouteSettings(name: AppRoutes.game),
        );
        expect(gameRoute, isA<MaterialPageRoute>());

        // Test unknown route
        final unknownRoute = NavigationService.generateRoute(
          const RouteSettings(name: '/unknown'),
        );
        expect(unknownRoute, isA<MaterialPageRoute>());
      });

      test('should handle route arguments', () {
        final arguments = {'test': 'value'};
        final route = NavigationService.generateRoute(
          RouteSettings(
            name: AppRoutes.game,
            arguments: arguments,
          ),
        );

        expect(route, isA<MaterialPageRoute>());
        expect(route!.settings.arguments, equals(arguments));
      });
    });

    group('NavigationEntity', () {
      test('should create navigation entity correctly', () {
        const navigation = NavigationEntity(
          path: AppRoutes.home,
          name: AppRoutes.homeRouteName,
        );

        expect(navigation.path, AppRoutes.home);
        expect(navigation.name, AppRoutes.homeRouteName);
        expect(navigation.arguments, isNull);
        expect(navigation.isModal, false);
        expect(navigation.clearStack, false);
      });

      test('should create navigation entity with arguments', () {
        final arguments = {'key': 'value'};
        final navigation = NavigationEntity(
          path: AppRoutes.game,
          name: AppRoutes.gameRouteName,
          arguments: arguments,
          isModal: true,
          clearStack: true,
        );

        expect(navigation.path, AppRoutes.game);
        expect(navigation.name, AppRoutes.gameRouteName);
        expect(navigation.arguments, equals(arguments));
        expect(navigation.isModal, true);
        expect(navigation.clearStack, true);
      });

      test('should support equality comparison', () {
        const navigation1 = NavigationEntity(
          path: AppRoutes.home,
          name: AppRoutes.homeRouteName,
        );

        const navigation2 = NavigationEntity(
          path: AppRoutes.home,
          name: AppRoutes.homeRouteName,
        );

        const navigation3 = NavigationEntity(
          path: AppRoutes.game,
          name: AppRoutes.gameRouteName,
        );

        expect(navigation1, equals(navigation2));
        expect(navigation1, isNot(equals(navigation3)));
      });

      test('should support copyWith', () {
        const original = NavigationEntity(
          path: AppRoutes.home,
          name: AppRoutes.homeRouteName,
        );

        final copied = original.copyWith(
          path: AppRoutes.game,
          isModal: true,
        );

        expect(copied.path, AppRoutes.game);
        expect(copied.name, AppRoutes.homeRouteName); // unchanged
        expect(copied.isModal, true);
        expect(copied.clearStack, false); // unchanged
      });
    });

    group('NavigationHelper Extension', () {
      testWidgets('should provide navigation extension methods', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              onGenerateRoute: NavigationService.generateRoute,
              home: Consumer(
                builder: (context, ref, child) {
                  // Test that extension methods are available
                  expect(ref.toHome, isA<Function>());
                  expect(ref.toThemeSettings, isA<Function>());
                  expect(ref.toFontSettings, isA<Function>());
                  expect(ref.toLanguageSettings, isA<Function>());
                  expect(ref.toGame, isA<Function>());
                  expect(ref.goBack, isA<Function>());
                  expect(ref.canGoBack, isA<bool>());

                  return const Scaffold(
                    body: Text('Navigation Test'),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Navigation Test'), findsOneWidget);
      });
    });

    group('Route Constants', () {
      test('should have all required route constants', () {
        // Main routes
        expect(AppRoutes.home, '/');
        expect(AppRoutes.game, '/game');

        // Settings routes
        expect(AppRoutes.settings, '/settings');
        expect(AppRoutes.themeSettings, '/settings/theme');
        expect(AppRoutes.fontSettings, '/settings/font');
        expect(AppRoutes.languageSettings, '/settings/language');

        // Route names
        expect(AppRoutes.homeRouteName, 'home');
        expect(AppRoutes.gameRouteName, 'game');
        expect(AppRoutes.settingsRouteName, 'settings');
        expect(AppRoutes.themeSettingsRouteName, 'theme_settings');
        expect(AppRoutes.fontSettingsRouteName, 'font_settings');
        expect(AppRoutes.languageSettingsRouteName, 'language_settings');
      });
    });

    group('Navigation Providers', () {
      test('should provide navigation use cases', () {
        final navigateToUseCase = container.read(navigateToUseCaseProvider);
        final navigateBackUseCase = container.read(navigateBackUseCaseProvider);
        final navigateAndReplaceUseCase = container.read(navigateAndReplaceUseCaseProvider);
        final navigateAndClearStackUseCase = container.read(navigateAndClearStackUseCaseProvider);

        expect(navigateToUseCase, isNotNull);
        expect(navigateBackUseCase, isNotNull);
        expect(navigateAndReplaceUseCase, isNotNull);
        expect(navigateAndClearStackUseCase, isNotNull);
      });

      test('should provide navigation state', () {
        final currentRoute = container.read(currentRouteProvider);
        final canNavigateBack = container.read(canNavigateBackProvider);
        final navigationHistory = container.read(navigationHistoryProvider);

        expect(currentRoute, isNull); // Initially null
        expect(canNavigateBack, isA<bool>());
        expect(navigationHistory, isA<List<NavigationEntity>>());
      });
    });

    testWidgets('should integrate with MaterialApp correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppRoutes.home,
          ),
        ),
      );

      // Wait for any async operations to complete
      await tester.pumpAndSettle();

      // Should show home screen
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
