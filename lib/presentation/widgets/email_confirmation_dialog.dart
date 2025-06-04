import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/logging/app_logger.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
import '../providers/user_providers.dart';

/// Dialog for handling email confirmation errors
/// Shows when user's email is not confirmed and provides options to resend confirmation
class EmailConfirmationDialog extends ConsumerStatefulWidget {
  final String email;
  final String? errorMessage;

  const EmailConfirmationDialog({
    super.key,
    required this.email,
    this.errorMessage,
  });

  @override
  ConsumerState<EmailConfirmationDialog> createState() => _EmailConfirmationDialogState();
}

class _EmailConfirmationDialogState extends ConsumerState<EmailConfirmationDialog> {
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      title: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: currentPrimaryColor,
            size: AppConstants.iconSizeMedium,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              LocalizationManager.translate(ref, 'email_not_confirmed_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message if provided
            if (widget.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: AppConstants.iconSizeSmall,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        widget.errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
            ],
            
            // Main message
            Text(
              LocalizationManager.translate(ref, 'email_not_confirmed_message'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Email display
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: currentPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                border: Border.all(color: currentPrimaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: currentPrimaryColor,
                    size: AppConstants.iconSizeSmall,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      widget.email,
                      style: TextStyle(
                        color: currentPrimaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Instructions
            Text(
              LocalizationManager.translate(ref, 'email_not_confirmed_instructions'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(LocalizationManager.translate(ref, 'cancel')),
        ),
        
        // Use different email button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            NavigationService.pushReplacementNamed(AppRoutes.login);
          },
          child: Text(LocalizationManager.translate(ref, 'use_different_email')),
        ),
        
        // Resend confirmation button
        ElevatedButton(
          onPressed: _isResending ? null : _handleResendConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: currentPrimaryColor,
            foregroundColor: _getContrastColor(currentPrimaryColor),
          ),
          child: _isResending
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getContrastColor(currentPrimaryColor),
                    ),
                  ),
                )
              : Text(LocalizationManager.translate(ref, 'resend_confirmation')),
        ),
      ],
    );
  }

  Future<void> _handleResendConfirmation() async {
    setState(() {
      _isResending = true;
    });

    try {
      AppLogger.info(
        'Resending email confirmation',
        tag: 'EmailConfirmationDialog',
        data: {'email': widget.email},
      );

      final resendUseCase = ref.read(resendEmailConfirmationUseCaseProvider);
      await resendUseCase.execute(widget.email);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationManager.translate(ref, 'confirmation_email_sent'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Close dialog with success result
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      AppLogger.error(
        'Failed to resend email confirmation',
        tag: 'EmailConfirmationDialog',
        error: error,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationManager.translate(ref, 'confirmation_email_failed'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  /// Helper method to get contrast color
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Helper function to show email confirmation dialog
Future<bool?> showEmailConfirmationDialog(
  BuildContext context, {
  required String email,
  String? errorMessage,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => EmailConfirmationDialog(
      email: email,
      errorMessage: errorMessage,
    ),
  );
}
