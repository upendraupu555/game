import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/navigation_service.dart';
import 'core/logging/app_logger.dart';
import 'core/services/app_initialization_service.dart';
import 'presentation/providers/font_providers.dart';
import 'presentation/providers/theme_providers.dart';
import 'presentation/providers/user_providers.dart';
import 'presentation/providers/payment_providers.dart';
import 'presentation/theme/app_theme.dart';
import 'domain/entities/theme_entity.dart';
import 'presentation/widgets/interstitial_ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  // Initialize logging system
  AppLogger.setLogLevel(LogLevel.debug);
  AppLogger.info('🎮 2048 Game Starting...', tag: 'App');

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  AppLogger.info('✅ Supabase initialized', tag: 'App');

  final sharedPreferences = await SharedPreferences.getInstance();
  AppLogger.info('✅ SharedPreferences initialized', tag: 'App');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize app services only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        final initService = ref.read(appInitializationServiceProvider);
        initService.initializeApp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final fontState = ref.watch(fontProvider);

    // Initialize user system
    ref.watch(userProvider);

    // Initialize payment system
    ref.watch(paymentProvider);

    return themeState.when(
      loading: () => MaterialApp(
        title: AppConstants.appTitle,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
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
            theme: AppTheme.lightTheme(
              themeEntity.lightPrimaryColor.toFlutterColor(),
            ),
            darkTheme: AppTheme.darkTheme(
              themeEntity.darkPrimaryColor.toFlutterColor(),
            ),
            themeMode: _getThemeMode(themeEntity.themeMode),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppRoutes.home,
          ),
          error: (error, stack) => MaterialApp(
            title: AppConstants.appTitle,
            theme: AppTheme.lightTheme(
              themeEntity.lightPrimaryColor.toFlutterColor(),
            ),
            darkTheme: AppTheme.darkTheme(
              themeEntity.darkPrimaryColor.toFlutterColor(),
            ),
            themeMode: _getThemeMode(themeEntity.themeMode),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppRoutes.home,
          ),
          data: (fontEntity) => InterstitialAdServiceProvider(
            child: MaterialApp(
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
