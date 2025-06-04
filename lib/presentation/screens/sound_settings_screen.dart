import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sound_providers.dart';
import '../providers/theme_providers.dart';
import '../../domain/entities/sound_entity.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/navigation_service.dart';
import '../../core/localization/localization_manager.dart';

class SoundSettingsScreen extends ConsumerWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundAsync = ref.watch(soundProvider);
    final currentTheme = ref.watch(currentThemeProvider);
    final primaryColor = currentTheme?.lightPrimaryColor.toFlutterColor() ?? Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.soundSettings(ref)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Play back button sound
            ref.read(soundPlayerProvider)(SoundEventType.backButton);
            NavigationService.pop();
          },
        ),
      ),
      body: soundAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Error loading sound settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton(
                onPressed: () => ref.refresh(soundProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (soundSettings) => _buildSoundSettings(context, ref, soundSettings, primaryColor),
      ),
    );
  }

  Widget _buildSoundSettings(BuildContext context, WidgetRef ref, SoundEntity soundSettings, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      children: [
        // Master Sound Toggle
        _buildSectionHeader(context, 'Master Settings', Icons.volume_up),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildSoundToggleCard(context, ref, soundSettings, primaryColor),

        const SizedBox(height: AppConstants.paddingLarge),

        // Master Volume
        if (soundSettings.soundEnabled) ...[
          _buildVolumeCard(
            context: context,
            title: 'Master Volume',
            subtitle: 'Overall volume control',
            icon: Icons.volume_up,
            value: soundSettings.masterVolume,
            onChanged: (value) => ref.read(soundProvider.notifier).updateMasterVolume(value),
            primaryColor: primaryColor,
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Category Volumes
          _buildSectionHeader(context, 'Category Volumes', Icons.tune),
          const SizedBox(height: AppConstants.paddingSmall),

          _buildVolumeCard(
            context: context,
            title: 'UI Sounds',
            subtitle: 'Button taps, navigation, menus',
            icon: Icons.touch_app,
            value: soundSettings.uiVolume,
            onChanged: (value) => ref.read(soundProvider.notifier).updateCategoryVolume(SoundVolumeCategory.ui, value),
            primaryColor: primaryColor,
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          _buildVolumeCard(
            context: context,
            title: 'Game Sounds',
            subtitle: 'Tile movements, merges, game events',
            icon: Icons.games,
            value: soundSettings.gameVolume,
            onChanged: (value) => ref.read(soundProvider.notifier).updateCategoryVolume(SoundVolumeCategory.game, value),
            primaryColor: primaryColor,
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          _buildVolumeCard(
            context: context,
            title: 'Powerup Sounds',
            subtitle: 'Powerup activations and effects',
            icon: Icons.flash_on,
            value: soundSettings.powerupVolume,
            onChanged: (value) => ref.read(soundProvider.notifier).updateCategoryVolume(SoundVolumeCategory.powerup, value),
            primaryColor: primaryColor,
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          _buildVolumeCard(
            context: context,
            title: 'Timer Sounds',
            subtitle: 'Time Attack mode timer effects',
            icon: Icons.timer,
            value: soundSettings.timerVolume,
            onChanged: (value) => ref.read(soundProvider.notifier).updateCategoryVolume(SoundVolumeCategory.timer, value),
            primaryColor: primaryColor,
          ),
        ],

        const SizedBox(height: AppConstants.paddingLarge),

        // Reset Button
        _buildResetCard(context, ref, primaryColor),

        const SizedBox(height: AppConstants.paddingLarge),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
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
    );
  }

  Widget _buildSoundToggleCard(BuildContext context, WidgetRef ref, SoundEntity soundSettings, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          soundSettings.soundEnabled ? Icons.volume_up : Icons.volume_off,
          color: primaryColor,
        ),
        title: const Text('Sound Effects'),
        subtitle: Text(soundSettings.soundEnabled ? 'Enabled' : 'Disabled'),
        trailing: Switch(
          value: soundSettings.soundEnabled,
          onChanged: (value) {
            ref.read(soundProvider.notifier).toggleSound();
            // Play a test sound when enabling
            if (value) {
              Future.delayed(const Duration(milliseconds: 100), () {
                ref.read(soundPlayerProvider)(SoundEventType.buttonTap);
              });
            }
          },
          activeColor: primaryColor,
        ),
        onTap: () {
          ref.read(soundProvider.notifier).toggleSound();
          if (!soundSettings.soundEnabled) {
            Future.delayed(const Duration(milliseconds: 100), () {
              ref.read(soundPlayerProvider)(SoundEventType.buttonTap);
            });
          }
        },
      ),
    );
  }

  Widget _buildVolumeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
    required Color primaryColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryColor,
                thumbColor: primaryColor,
                overlayColor: primaryColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: AppConstants.minVolume,
                max: AppConstants.maxVolume,
                divisions: ((AppConstants.maxVolume - AppConstants.minVolume) / AppConstants.volumeStep).round(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetCard(BuildContext context, WidgetRef ref, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(Icons.restore, color: primaryColor),
        title: const Text('Reset to Defaults'),
        subtitle: const Text('Restore all sound settings to default values'),
        trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
        onTap: () => _showResetConfirmation(context, ref),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Sound Settings'),
        content: const Text('Are you sure you want to reset all sound settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(soundProvider.notifier).resetSoundSettings();
              ref.read(soundPlayerProvider)(SoundEventType.buttonTap);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
