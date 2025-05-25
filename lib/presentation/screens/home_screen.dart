import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
import '../widgets/themed_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.appTitle(ref)),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              NavigationService.pushNamed(AppRoutes.themeSettings);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'about':
                  if (AppConfig.isFeatureEnabled('about_screen')) {
                    NavigationService.pushNamed(AppRoutes.about);
                  }
                  break;
                case 'help':
                  if (AppConfig.isFeatureEnabled('help_screen')) {
                    NavigationService.pushNamed(AppRoutes.help);
                  }
                  break;
                case 'feedback':
                  if (AppConfig.isFeatureEnabled('feedback_screen')) {
                    NavigationService.pushNamed(AppRoutes.feedback);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              if (AppConfig.isFeatureEnabled('about_screen'))
                PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 8),
                      Text(LocalizationManager.navAbout(ref)),
                    ],
                  ),
                ),
              if (AppConfig.isFeatureEnabled('help_screen'))
                PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      const Icon(Icons.help),
                      const SizedBox(width: 8),
                      Text(LocalizationManager.navHelp(ref)),
                    ],
                  ),
                ),
              if (AppConfig.isFeatureEnabled('feedback_screen'))
                PopupMenuItem(
                  value: 'feedback',
                  child: Row(
                    children: [
                      const Icon(Icons.feedback),
                      const SizedBox(width: 8),
                      Text(LocalizationManager.navFeedback(ref)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  children: [
                    Icon(
                      Icons.games,
                      size: AppConstants.iconSizeExtraLarge,
                      color: currentPrimaryColor,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      LocalizationManager.welcomeMessage(ref),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '${LocalizationManager.themeMode(ref)}: ${currentTheme?.themeMode.displayName ?? LocalizationManager.loading(ref)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ThemedButton(
                      text: LocalizationManager.startGame(ref),
                      onPressed: () {
                        NavigationService.pushNamed(AppRoutes.game);
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ThemedButton(
                      text: LocalizationManager.themeSettings(ref),
                      isPrimary: false,
                      onPressed: () {
                        NavigationService.pushNamed(AppRoutes.themeSettings);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),
            // Demo cards to show theme colors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              LocalizationManager.current(ref),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'Secondary',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
