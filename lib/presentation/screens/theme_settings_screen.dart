import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/theme_entity.dart';
import '../providers/theme_providers.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final availableColors = ref.watch(availableColorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.themeSettings(ref)),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(themeProvider.notifier).resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocalizationManager.themeResetMessage(ref)),
                  ),
                );
              }
            },
            child: Text(LocalizationManager.reset(ref)),
          ),
        ],
      ),
      body: themeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(themeProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (themeEntity) =>
            _buildThemeSettings(context, ref, themeEntity, availableColors),
      ),
    );
  }

  Widget _buildThemeSettings(
    BuildContext context,
    WidgetRef ref,
    ThemeEntity themeEntity,
    List<ColorEntity> availableColors,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme Mode Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationManager.themeMode(ref),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...ThemeModeEntity.values.map(
                  (mode) => RadioListTile<ThemeModeEntity>(
                    title: Text(mode.displayName),
                    subtitle: Text(_getThemeModeDescription(mode, ref)),
                    value: mode,
                    groupValue: themeEntity.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeProvider.notifier).updateThemeMode(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Light Theme Primary Color Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationManager.lightThemePrimaryColor(ref),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${LocalizationManager.current(ref)}: ${themeEntity.lightPrimaryColor.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _buildColorPicker(
                  context,
                  ref,
                  themeEntity.lightPrimaryColor,
                  availableColors,
                  (color) => ref
                      .read(themeProvider.notifier)
                      .updateLightPrimaryColor(color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Dark Theme Primary Color Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationManager.darkThemePrimaryColor(ref),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${LocalizationManager.current(ref)}: ${themeEntity.darkPrimaryColor.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _buildColorPicker(
                  context,
                  ref,
                  themeEntity.darkPrimaryColor,
                  availableColors,
                  (color) => ref
                      .read(themeProvider.notifier)
                      .updateDarkPrimaryColor(color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Preview Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationManager.preview(ref),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildPreview(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    WidgetRef ref,
    ColorEntity selectedColor,
    List<ColorEntity> availableColors,
    Function(ColorEntity) onColorSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableColors.map((colorEntity) {
        final isSelected = colorEntity.value == selectedColor.value;
        final color = colorEntity.toFlutterColor();

        return GestureDetector(
          onTap: () => onColorSelected(colorEntity),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, color: _getContrastColor(color), size: 24)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(LocalizationManager.primaryButton(ref)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: Text(LocalizationManager.outlinedButton(ref)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            LocalizationManager.themePreviewText(ref),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _getThemeModeDescription(ThemeModeEntity mode, WidgetRef ref) {
    switch (mode) {
      case ThemeModeEntity.light:
        return LocalizationManager.lightThemeDescription(ref);
      case ThemeModeEntity.dark:
        return LocalizationManager.darkThemeDescription(ref);
      case ThemeModeEntity.system:
        return LocalizationManager.systemThemeDescription(ref);
    }
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use black or white text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
