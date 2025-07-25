import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
// TODO: Temporarily disabled imports for font and sound providers
// import '../providers/font_providers.dart';
// import '../providers/sound_providers.dart';
import '../providers/leaderboard_providers.dart';
import '../providers/localization_providers.dart';
// TODO: Temporarily disabled sound entity import
// import '../../domain/entities/sound_entity.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    // TODO: Temporarily disabled font customization
    // final currentFont = ref.watch(currentFontProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.navSettings(ref)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Appearance', Icons.palette),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: LocalizationManager.themeSettings(ref),
              subtitle: _getThemeSubtitle(currentTheme),
              icon: Icons.color_lens,
              onTap: () {
                NavigationService.pushNamed(AppRoutes.themeSettings);
              },
              primaryColor: primaryColor,
            ),

            // TODO: Temporarily disabled font and sound settings
            // Uncomment these sections to re-enable font and sound customization
            /*
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: LocalizationManager.fontSettings(ref),
              subtitle: _getFontSubtitle(currentFont),
              icon: Icons.font_download,
              onTap: () {
                NavigationService.pushNamed(AppRoutes.fontSettings);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: LocalizationManager.soundSettings(ref),
              subtitle: _getSoundSubtitle(ref),
              icon: Icons.volume_up,
              onTap: () {
                NavigationService.pushNamed(AppRoutes.soundSettings);
              },
              primaryColor: primaryColor,
            ),
            */
            // const SizedBox(height: AppConstants.paddingSmall),
            // _buildSettingsCard(
            //   context: context,
            //   ref: ref,
            //   title: LocalizationManager.translate(ref, 'language_settings'),
            //   subtitle: _getLanguageSubtitle(ref),
            //   icon: Icons.language,
            //   onTap: () {
            //     NavigationService.pushNamed(AppRoutes.languageSettings);
            //   },
            //   primaryColor: primaryColor,
            // ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Profile Section
            _buildSectionHeader(context, 'Profile', Icons.person),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: LocalizationManager.translate(ref, 'user_profile'),
              subtitle: LocalizationManager.translate(
                ref,
                'user_profile_description',
              ),
              icon: Icons.account_circle,
              onTap: () {
                NavigationService.pushNamed(AppRoutes.profile);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: 'Game Statistics',
              subtitle: 'View detailed game performance',
              icon: Icons.analytics,
              onTap: () {
                NavigationService.pushNamed(
                  AppRoutes.leaderboard,
                  arguments: {'initialTab': 1}, // Statistics tab index
                );
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // App Information Section
            _buildSectionHeader(context, 'App Information', Icons.info),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: LocalizationManager.aboutApp(ref),
              subtitle: 'Version, developer info, and credits',
              icon: Icons.info_outline,
              onTap: () {
                NavigationService.pushNamed(AppRoutes.about);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSettingsCard(
              context: context,
              ref: ref,
              title: LocalizationManager.clearLeaderboard(ref),
              subtitle: 'Clear all leaderboard entries',
              icon: Icons.leaderboard_outlined,
              onTap: () {
                _showClearLeaderboardDialog(context, ref);
              },
              primaryColor: Colors.orange,
            ),

            const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Temporarily disabled sound playback
          // ref.read(soundPlayerProvider)(SoundEventType.buttonTap);
          onTap();
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(icon, color: primaryColor, size: 24),
              ),

              const SizedBox(width: AppConstants.paddingMedium),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeSubtitle(dynamic currentTheme) {
    if (currentTheme == null) return 'Loading...';

    final themeModeText = switch (currentTheme.themeMode.toString()) {
      'ThemeModeEntity.light' => 'Light mode',
      'ThemeModeEntity.dark' => 'Dark mode',
      _ => 'System default',
    };

    return '$themeModeText • Custom colors';
  }

  // TODO: Temporarily disabled font and sound subtitle methods
  // Uncomment these methods to re-enable font and sound customization
  /*
  String _getFontSubtitle(dynamic currentFont) {
    if (currentFont == null) return 'Loading...';

    return currentFont.displayName ?? 'Default font';
  }

  String _getSoundSubtitle(WidgetRef ref) {
    final soundState = ref.watch(soundProvider);
    return soundState.when(
      loading: () => 'Loading...',
      error: (_, __) => 'Error loading settings',
      data: (sound) {
        if (!sound.soundEnabled) {
          return LocalizationManager.soundDisabled(ref);
        }
        final masterPercent = (sound.masterVolume * 100).round();
        return 'Enabled • $masterPercent% volume';
      },
    );
  }
  */

  void _showClearLeaderboardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationManager.clearLeaderboardConfirmation(ref)),
        content: Text(LocalizationManager.clearLeaderboardMessage(ref)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationManager.cancel(ref)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(leaderboardProvider.notifier).clearLeaderboard();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LocalizationManager.leaderboardCleared(ref),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear leaderboard: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(LocalizationManager.clearLeaderboard(ref)),
          ),
        ],
      ),
    );
  }

  String _getLanguageSubtitle(WidgetRef ref) {
    final currentLocalization = ref.watch(currentLocalizationProvider);
    if (currentLocalization != null) {
      final languageName =
          AppConfig.languageDisplayNames[currentLocalization.locale] ??
          currentLocalization.language;
      return languageName;
    }
    return 'English'; // Fallback
  }
}
