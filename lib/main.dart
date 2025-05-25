import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/navigation_service.dart';
import 'presentation/providers/font_providers.dart';
import 'presentation/providers/theme_providers.dart';
import 'presentation/theme/app_theme.dart';
import 'domain/entities/theme_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final fontState = ref.watch(fontProvider);

    return themeState.when(
      loading: () => MaterialApp(
        title: AppConstants.appTitle,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        title: AppConstants.appTitle,
        home: Scaffold(
          body: Center(
            child: Text('${AppConstants.errorLoadingTheme}: $error'),
          ),
        ),
      ),
      data: (themeEntity) {
        return fontState.when(
          loading: () => MaterialApp(
            title: AppConstants.appTitle,
            theme: AppTheme.lightTheme(themeEntity.lightPrimaryColor.toFlutterColor()),
            darkTheme: AppTheme.darkTheme(themeEntity.darkPrimaryColor.toFlutterColor()),
            themeMode: _getThemeMode(themeEntity.themeMode),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppRoutes.home,
          ),
          error: (error, stack) => MaterialApp(
            title: AppConstants.appTitle,
            theme: AppTheme.lightTheme(themeEntity.lightPrimaryColor.toFlutterColor()),
            darkTheme: AppTheme.darkTheme(themeEntity.darkPrimaryColor.toFlutterColor()),
            themeMode: _getThemeMode(themeEntity.themeMode),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppRoutes.home,
          ),
          data: (fontEntity) => MaterialApp(
            title: AppConstants.appTitle,
            theme: AppTheme.lightTheme(
              themeEntity.lightPrimaryColor.toFlutterColor(),
              fontFamily: fontEntity.fontFamily,
            ),
            darkTheme: AppTheme.darkTheme(
              themeEntity.darkPrimaryColor.toFlutterColor(),
              fontFamily: fontEntity.fontFamily,
            ),
            themeMode: _getThemeMode(themeEntity.themeMode),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppRoutes.home,
          ),
        );
      },
    );
  }

  ThemeMode _getThemeMode(ThemeModeEntity themeMode) {
    switch (themeMode) {
      case ThemeModeEntity.light:
        return ThemeMode.light;
      case ThemeModeEntity.dark:
        return ThemeMode.dark;
      case ThemeModeEntity.system:
        return ThemeMode.system;
    }
  }
}


