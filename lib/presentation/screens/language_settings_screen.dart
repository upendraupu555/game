import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/font_providers.dart';
import '../providers/localization_providers.dart';

/// Language Settings Screen
/// Allows users to select their preferred language from available options
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(currentFontProvider);
    final currentLocalization = ref.watch(currentLocalizationProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Handle null safety
    final fontFamily = currentFont?.fontFamily ?? 'BubblegumSans';
    final currentLocale = currentLocalization?.locale ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.translate(ref, 'language_settings')),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            NavigationService.pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            // Header Section
            _buildHeaderSection(context, ref, primaryColor, fontFamily),

            const SizedBox(height: AppConstants.paddingLarge),

            // Language Selection Section
            _buildLanguageSelectionSection(
              context,
              ref,
              primaryColor,
              fontFamily,
              currentLocale,
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Information Section
            _buildInformationSection(context, ref, primaryColor, fontFamily),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: primaryColor, size: 32),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationManager.translate(ref, 'language_settings'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      LocalizationManager.translate(ref, 'select_language'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionSection(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
    String currentLocale,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: AppConfig.supportedLanguages.map((locale) {
          final isSelected = locale == currentLocale;
          final languageName = AppConfig.languageDisplayNames[locale] ?? locale;

          return _buildLanguageOption(
            context: context,
            ref: ref,
            locale: locale,
            languageName: languageName,
            isSelected: isSelected,
            primaryColor: primaryColor,
            fontFamily: fontFamily,
            isFirst: locale == AppConfig.supportedLanguages.first,
            isLast: locale == AppConfig.supportedLanguages.last,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String locale,
    required String languageName,
    required bool isSelected,
    required Color primaryColor,
    required String fontFamily,
    required bool isFirst,
    required bool isLast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onLanguageSelected(ref, locale),
        borderRadius: BorderRadius.vertical(
          top: isFirst
              ? const Radius.circular(AppConstants.borderRadiusLarge)
              : Radius.zero,
          bottom: isLast
              ? const Radius.circular(AppConstants.borderRadiusLarge)
              : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              // Language Flag/Icon (placeholder)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(Icons.language, color: primaryColor, size: 20),
              ),

              const SizedBox(width: AppConstants.paddingMedium),

              // Language Name
              Expanded(
                child: Text(
                  languageName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? primaryColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: fontFamily,
                  ),
                ),
              ),

              // Selection Indicator
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 24)
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationSection(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 20),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                LocalizationManager.translate(ref, 'restart_required'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            LocalizationManager.translate(ref, 'language_change_message'),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  void _onLanguageSelected(WidgetRef ref, String locale) async {
    try {
      // Update the language
      await ref.read(localizationProvider.notifier).changeLocale(locale);

      // Show success message
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationManager.translate(ref, 'language_changed'),
              style: TextStyle(
                fontFamily:
                    ref.read(currentFontProvider)?.fontFamily ??
                    'BubblegumSans',
              ),
            ),
            backgroundColor: Theme.of(ref.context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationManager.translate(ref, 'error_unknown'),
              style: TextStyle(
                fontFamily:
                    ref.read(currentFontProvider)?.fontFamily ??
                    'BubblegumSans',
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
