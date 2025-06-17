import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/auth_error_handler.dart';
import '../providers/user_providers.dart';
import '../providers/theme_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userProvider.notifier).resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
        });

        // Show success dialog
        ErrorHandler.showSuccessDialog(
          context,
          ref,
          LocalizationManager.translate(ref, 'password_reset_email_sent'),
          title: LocalizationManager.translate(ref, 'success_dialog_title'),
          onOk: () {
            // Navigate back to login screen
            NavigationService.pop();
          },
        );
      }
    } catch (error) {
      if (mounted) {
        // Use the enhanced auth error handler
        AuthErrorHandler.showAuthErrorDialog(
          context,
          ref,
          error,
          email: _emailController.text.trim(),
          onRetry: () => _handlePasswordReset(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          LocalizationManager.translate(ref, 'forgot_password'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: currentPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: currentPrimaryColor),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.paddingExtraLarge),

                // Header Icon
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: currentPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: currentPrimaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Title
                Text(
                  LocalizationManager.translate(ref, 'reset_your_password'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: currentPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Description
                Text(
                  LocalizationManager.translate(ref, 'password_reset_description'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingExtraLarge),

                // Email Field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_emailSent,
                      decoration: InputDecoration(
                        labelText: LocalizationManager.translate(ref, 'email'),
                        prefixIcon: Icon(Icons.email, color: currentPrimaryColor),
                        border: InputBorder.none,
                        hintText: LocalizationManager.translate(ref, 'enter_your_email'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocalizationManager.translate(ref, 'email_required');
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return LocalizationManager.translate(ref, 'invalid_email_format');
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Reset Password Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _emailSent ? null : (_isLoading ? null : _handlePasswordReset),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _emailSent 
                                ? LocalizationManager.translate(ref, 'email_sent')
                                : LocalizationManager.translate(ref, 'send_reset_link'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Success Message (if email sent)
                if (_emailSent) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          LocalizationManager.translate(ref, 'check_your_email'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          LocalizationManager.translate(ref, 'password_reset_email_instructions'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Back to Login Button
                TextButton(
                  onPressed: () => NavigationService.pop(),
                  child: Text(
                    LocalizationManager.translate(ref, 'back_to_login'),
                    style: TextStyle(
                      color: currentPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: currentPrimaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: currentPrimaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: currentPrimaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        LocalizationManager.translate(ref, 'password_reset_help'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: currentPrimaryColor.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
