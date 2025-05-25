import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/font_entity.dart';
import '../providers/font_providers.dart';
import '../theme/font_manager.dart';

class FontSettingsScreen extends ConsumerWidget {
  const FontSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontState = ref.watch(fontProvider);
    final availableFonts = ref.watch(availableFontsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.fontSettings(ref)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(fontProvider.notifier).resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocalizationManager.fontResetMessage(ref)),
                ),
              );
            },
          ),
        ],
      ),
      body: fontState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: AppConstants.iconSizeExtraLarge),
              const SizedBox(height: AppConstants.paddingMedium),
              Text('${LocalizationManager.error(ref)}: $error'),
              const SizedBox(height: AppConstants.paddingMedium),
              ElevatedButton(
                onPressed: () => ref.invalidate(fontProvider),
                child: Text(LocalizationManager.retry(ref)),
              ),
            ],
          ),
        ),
        data: (currentFont) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Font Family Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationManager.fontFamily(ref),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ...availableFonts.map((font) => _buildFontOption(
                        context,
                        ref,
                        font,
                        currentFont,
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Font Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationManager.preview(ref),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildFontPreview(context, ref, currentFont.fontFamily),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontOption(
    BuildContext context,
    WidgetRef ref,
    FontEntity font,
    FontEntity currentFont,
  ) {
    final isSelected = font.fontFamily == currentFont.fontFamily;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall / 2),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        title: Text(
          font.displayName,
          style: FontManager.createTextStyle(
            fontFamily: font.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${LocalizationManager.fontFamilyLabel(ref)} ${font.fontFamily}',
          style: FontManager.createTextStyle(
            fontFamily: font.fontFamily,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Icons.radio_button_unchecked),
        onTap: () {
          ref.read(fontProvider.notifier).updateFont(font);
        },
      ),
    );
  }

  Widget _buildFontPreview(BuildContext context, WidgetRef ref, String fontFamily) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationManager.appTitle(ref),
            style: FontManager.headlineStyle(fontFamily),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            LocalizationManager.fontPreviewText(ref),
            style: FontManager.bodyStyle(fontFamily),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    LocalizationManager.primaryButton(ref),
                    style: FontManager.buttonStyle(fontFamily),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    LocalizationManager.outlinedButton(ref),
                    style: FontManager.buttonStyle(fontFamily),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            LocalizationManager.fontPreviewNumbers(ref),
            style: FontManager.captionStyle(fontFamily),
          ),
        ],
      ),
    );
  }
}
