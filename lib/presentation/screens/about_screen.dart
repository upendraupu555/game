import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import '../widgets/hero_section_widget.dart';
import '../widgets/confetti_widget.dart';

/// Enhanced About screen with consistent logo, developer info, and integrated support
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  final _feedbackFormKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'User Interface',
    'Performance',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.aboutTitle(ref)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with consistent logo and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeroSectionWidget(
                  primaryColor: currentPrimaryColor,
                  fontFamily: currentFontFamily,
                  showTagline: false,
                  logoSize: 100,
                  titleFontSize: 32,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // App Description
            _buildSection(
              context,
              ref,
              title: LocalizationManager.aboutTitle(ref),
              content: LocalizationManager.aboutDescription(ref),
              icon: Icons.info_outline,
              primaryColor: currentPrimaryColor,
              fontFamily: currentFontFamily,
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Developer Information
            _buildSection(
              context,
              ref,
              title: 'Developer',
              content: _buildDeveloperInfo(ref),
              icon: Icons.person,
              primaryColor: currentPrimaryColor,
              fontFamily: currentFontFamily,
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Technology Credits
            _buildSection(
              context,
              ref,
              title: 'Technology',
              content: LocalizationManager.builtWithFlutter(ref),
              icon: Icons.code,
              primaryColor: currentPrimaryColor,
              fontFamily: currentFontFamily,
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Version Information with Easter Egg
            EasterEggConfettiWidget(
              onTrigger: () {
                // Additional easter egg logic can be added here
              },
              child: _buildSection(
                context,
                ref,
                title: LocalizationManager.versionInfo(ref),
                content: _buildVersionInfo(ref),
                icon: Icons.info,
                primaryColor: currentPrimaryColor,
                fontFamily: currentFontFamily,
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Support and Legal Section
            _buildSupportSection(
              context,
              ref,
              currentPrimaryColor,
              currentFontFamily,
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Copyright
            Center(
              child: Text(
                AppConfig.copyright,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: currentFontFamily,
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
    required Color primaryColor,
    required String fontFamily,
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
                  color: primaryColor,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDeveloperInfo(WidgetRef ref) {
    return '${LocalizationManager.developerName(ref)}\n${LocalizationManager.madeWithLove(ref)}';
  }

  Widget _buildSupportSection(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  size: AppConstants.iconSizeMedium,
                  color: primaryColor,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Support & Legal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Contact Support
            _buildActionTile(
              context,
              ref,
              title: LocalizationManager.contactSupport(ref),
              subtitle: LocalizationManager.getHelp(ref),
              icon: Icons.email,
              onTap: () => _showContactSupportDialog(context, ref),
              primaryColor: primaryColor,
              fontFamily: fontFamily,
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Privacy Policy
            _buildActionTile(
              context,
              ref,
              title: LocalizationManager.privacyPolicy(ref),
              subtitle: LocalizationManager.privacyPolicySubtitle(ref),
              icon: Icons.privacy_tip,
              onTap: () => NavigationService.pushNamed(AppRoutes.privacyPolicy),
              primaryColor: primaryColor,
              fontFamily: fontFamily,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color primaryColor,
    required String fontFamily,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontFamily: fontFamily),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: primaryColor.withValues(alpha: 0.7),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _buildVersionInfo(WidgetRef ref) {
    return 'Version ${LocalizationManager.appVersion(ref)}\nFlutter App';
  }

  void _showContactSupportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationManager.contactSupport(ref)),
        content: Form(
          key: _feedbackFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send us your feedback or report issues. We\'ll get back to you soon!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Feedback Text Field
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Your Message',
                  border: OutlineInputBorder(),
                  hintText: 'Describe your issue or feedback...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Email Field (Optional)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Your Email (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'your.email@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () => _submitFeedback(context, ref),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback(BuildContext context, WidgetRef ref) async {
    if (!_feedbackFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Store context reference for safe usage
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Create email content
      final emailSubject = 'Ultra 2048 Feedback - $_selectedCategory';
      final emailBody =
          '''
Category: $_selectedCategory
Message: ${_feedbackController.text}
${_emailController.text.isNotEmpty ? 'Reply to: ${_emailController.text}' : ''}

---
App Version: ${LocalizationManager.appVersion(ref)}
Device Info: Flutter App
''';

      // Create mailto URL
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'devisettiupendragames@gmail.com',
        query:
            'subject=${Uri.encodeComponent(emailSubject)}&body=${Uri.encodeComponent(emailBody)}',
      );

      // Try to launch email app
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);

        // Clear form and close dialog
        _feedbackController.clear();
        _emailController.clear();
        _selectedCategory = 'General';

        if (mounted) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Email app opened. Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Fallback: Copy to clipboard
        await Clipboard.setData(
          ClipboardData(
            text:
                'To: devisettiupendragames@gmail.com\nSubject: $emailSubject\n\n$emailBody',
          ),
        );

        if (mounted) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Email content copied to clipboard. Please paste it in your email app.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
