import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';

/// Dedicated Privacy Policy screen with full content display
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.privacyPolicy(ref)),
        elevation: 0,
        backgroundColor: currentPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: _loadPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(context, ref, snapshot.error.toString());
          } else {
            return _buildContent(
              context,
              ref,
              snapshot.data ?? 'Privacy policy not available',
              currentFontFamily,
            );
          }
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String content,
    String fontFamily,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.privacy_tip,
                  size: AppConstants.iconSizeLarge,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Last updated: December 15, 2024',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: fontFamily,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: SelectableText(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: fontFamily,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Contact section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Questions about this policy?',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'If you have any questions about this privacy policy, please contact us at devisettiupendragames@gmail.com',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppConstants.iconSizeExtraLarge,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Error loading privacy policy',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadPrivacyPolicy() async {
    try {
      return await rootBundle.loadString('assets/privacy_policy.md');
    } catch (e) {
      throw Exception('Privacy policy document not found: $e');
    }
  }
}
