import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';

/// About screen showing app information, version, and company details
/// This is a generic whitelabel screen that can be customized through AppConfig
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.aboutTitle(ref)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon and Title
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.apps,
                    size: AppConstants.iconSizeExtraLarge * 1.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    LocalizationManager.appTitle(ref),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'v${LocalizationManager.appVersion(ref)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Description
            _buildSection(
              context,
              ref,
              title: LocalizationManager.aboutTitle(ref),
              content: LocalizationManager.aboutDescription(ref),
              icon: Icons.info_outline,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Version Information
            if (AppConfig.isFeatureEnabled('version_info'))
              _buildSection(
                context,
                ref,
                title: LocalizationManager.versionInfo(ref),
                content: _buildVersionInfo(ref),
                icon: Icons.info,
              ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Company Information
            _buildSection(
              context,
              ref,
              title: LocalizationManager.companyInfo(ref),
              content: _buildCompanyInfo(),
              icon: Icons.business,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Links Section
            _buildLinksSection(context, ref),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Copyright
            Center(
              child: Text(
                AppConfig.copyright,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String content,
    required IconData icon,
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
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Links',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Contact Us
            _buildLinkTile(
              context,
              ref,
              title: LocalizationManager.contactUs(ref),
              icon: Icons.email,
              onTap: () {
                // TODO: Implement contact functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocalizationManager.comingSoon(ref)),
                  ),
                );
              },
            ),
            
            // Privacy Policy
            _buildLinkTile(
              context,
              ref,
              title: LocalizationManager.privacyPolicy(ref),
              icon: Icons.privacy_tip,
              onTap: () {
                // TODO: Implement privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocalizationManager.comingSoon(ref)),
                  ),
                );
              },
            ),
            
            // Terms of Service
            _buildLinkTile(
              context,
              ref,
              title: LocalizationManager.termsOfService(ref),
              icon: Icons.description,
              onTap: () {
                // TODO: Implement terms of service
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocalizationManager.comingSoon(ref)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _buildVersionInfo(WidgetRef ref) {
    return '''
App Version: ${AppConfig.appVersion}
Build: ${AppConfig.bundleId}
Platform: Flutter
''';
  }

  String _buildCompanyInfo() {
    return '''
${AppConfig.companyName}

${AppConfig.appDescription}
''';
  }
}
