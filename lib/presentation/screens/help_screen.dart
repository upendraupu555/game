import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';

/// Help screen providing user guidance and support information
/// This is a generic whitelabel screen that can be customized through AppConfig
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.helpTitle(ref)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: AppConstants.iconSizeExtraLarge,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    LocalizationManager.helpTitle(ref),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    LocalizationManager.helpDescription(ref),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Getting Started
            _buildHelpSection(
              context,
              ref,
              title: 'Getting Started',
              icon: Icons.play_arrow,
              items: [
                'Welcome to ${AppConfig.appName}!',
                'Tap "Start Game" to begin playing 2048.',
                'Swipe tiles to combine numbers and reach 2048.',
                'Customize your experience in the Settings.',
                'Explore different themes and fonts to personalize your game.',
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Game Features
            _buildHelpSection(
              context,
              ref,
              title: 'Game Features',
              icon: Icons.star,
              items: [
                '2048 Puzzle Game - Slide tiles to combine numbers',
                'Score Tracking - Keep track of your best scores',
                'Game State Persistence - Resume your game anytime',
                if (AppConfig.enableThemeCustomization) 'Theme Customization - Change colors and appearance',
                if (AppConfig.enableFontCustomization) 'Font Selection - Choose from multiple font options',
                if (AppConfig.enableDarkMode) 'Dark Mode - Toggle between light and dark themes',
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Settings Help
            if (AppConfig.enableThemeCustomization || AppConfig.enableFontCustomization)
              _buildHelpSection(
                context,
                ref,
                title: 'Settings',
                icon: Icons.settings,
                items: [
                  if (AppConfig.enableThemeCustomization) 'Theme Settings - Customize colors and theme mode',
                  if (AppConfig.enableFontCustomization) 'Font Settings - Select your preferred font',
                  'Reset Options - Restore default settings anytime',
                ],
              ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Troubleshooting
            _buildHelpSection(
              context,
              ref,
              title: 'Troubleshooting',
              icon: Icons.build,
              items: [
                'If the app is not responding, try restarting it.',
                'Settings not saving? Check your device storage.',
                'Theme not applying? Try switching theme modes.',
                'For persistent issues, contact support.',
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // FAQ
            _buildFAQSection(context, ref),

            const SizedBox(height: AppConstants.paddingLarge),

            // Contact Support
            _buildContactSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, WidgetRef ref) {
    final faqs = [
      {
        'question': 'How do I play 2048?',
        'answer': 'Swipe tiles in any direction to move them. When two tiles with the same number touch, they merge into one! Try to reach the 2048 tile.',
      },
      {
        'question': 'How do I win the game?',
        'answer': 'Create a tile with the number 2048 to win! You can continue playing to reach even higher numbers.',
      },
      {
        'question': 'How do I change the app theme?',
        'answer': 'Go to Settings > Theme Settings to customize colors and theme mode.',
      },
      {
        'question': 'Can I change the font?',
        'answer': 'Yes! Visit Settings > Font Settings to choose from available fonts.',
      },
      {
        'question': 'How do I reset my settings?',
        'answer': 'Each settings screen has a reset button to restore defaults.',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Frequently Asked Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...faqs.map((faq) => ExpansionTile(
              title: Text(
                faq['question']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Text(
                    faq['answer']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              Icons.support_agent,
              size: AppConstants.iconSizeLarge,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Need More Help?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'If you couldn\'t find what you\'re looking for, don\'t hesitate to contact our support team.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement contact support
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocalizationManager.comingSoon(ref)),
                  ),
                );
              },
              icon: const Icon(Icons.email),
              label: Text(LocalizationManager.contactUs(ref)),
            ),
          ],
        ),
      ),
    );
  }
}
