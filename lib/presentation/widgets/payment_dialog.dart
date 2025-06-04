import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/repositories/payment_repository.dart';
import '../providers/payment_providers.dart';
import '../providers/theme_providers.dart';
import '../providers/user_providers.dart';

/// Payment dialog for ad removal purchase
class PaymentDialog extends ConsumerStatefulWidget {
  const PaymentDialog({super.key});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final isPaymentProcessing = ref.watch(isPaymentProcessingProvider);
    final paymentError = ref.watch(paymentErrorProvider);
    final user = ref.watch(userProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, currentPrimaryColor),

            const SizedBox(height: AppConstants.paddingMedium),

            // Content
            _buildContent(context, currentPrimaryColor),

            const SizedBox(height: AppConstants.paddingLarge),

            // Error message
            if (paymentError != null) ...[
              _buildErrorMessage(context, paymentError),
              const SizedBox(height: AppConstants.paddingMedium),
            ],

            // Action buttons
            _buildActionButtons(
              context,
              currentPrimaryColor,
              isPaymentProcessing || _isProcessing,
              user,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Icon(
            Icons.block,
            color: primaryColor,
            size: AppConstants.iconSizeLarge,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove Ads',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                'Enjoy ad-free gaming experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        // Price display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '₹${AppConstants.removeAdsPrice}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                'One-time purchase',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.paddingMedium),

        // Benefits list
        _buildBenefitsList(context, primaryColor),
      ],
    );
  }

  Widget _buildBenefitsList(BuildContext context, Color primaryColor) {
    final benefits = [
      'Remove all banner advertisements',
      'Remove all interstitial ads',
      'Uninterrupted gaming experience',
      'Permanent - no subscription required',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you get:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        ...benefits.map(
          (benefit) => Padding(
            padding: const EdgeInsets.only(
              bottom: AppConstants.paddingSmall / 2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: AppConstants.iconSizeSmall,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    benefit,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
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
              error,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Color primaryColor,
    bool isProcessing,
    dynamic user,
  ) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: isProcessing
                ? null
                : () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.buttonPaddingVertical,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),

        const SizedBox(width: AppConstants.paddingMedium),

        // Purchase button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isProcessing ? null : () => _handlePurchase(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: _getContrastColor(primaryColor),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.buttonPaddingVertical,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Purchase ₹100'),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Clear any previous errors
      ref.read(paymentProvider.notifier).clearError();

      // Get current user from provider
      final userState = ref.read(userProvider);
      final user = userState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      AppLogger.info(
        'Starting payment process from dialog',
        tag: 'PaymentDialog',
        data: {
          'user': user?.username ?? 'Unknown',
          'isAuthenticated': user?.isAuthenticated ?? false,
          'userType': user?.isGuest == true ? 'guest' : 'authenticated',
          'supabaseUserId': user?.supabaseUserId ?? 'none',
        },
      );

      // Validate user state before proceeding
      if (user == null) {
        throw PaymentValidationException(
          'User not found. Please try again.',
          code: 'USER_NOT_FOUND',
        );
      }

      if (user.isGuest) {
        throw PaymentValidationException(
          'Guest users cannot make purchases. Please sign in first.',
          code: 'GUEST_USER_NOT_ALLOWED',
        );
      }

      if (!user.isAuthenticated) {
        throw PaymentValidationException(
          'User not authenticated. Please sign in first.',
          code: 'USER_NOT_AUTHENTICATED',
        );
      }

      AppLogger.info(
        'User validation passed, proceeding with payment',
        tag: 'PaymentDialog',
      );

      // Test Razorpay service availability
      try {
        final paymentService = ref.read(razorpayPaymentServiceProvider);
        paymentService.testInitialization();
        AppLogger.info('Razorpay service test passed', tag: 'PaymentDialog');
      } catch (e) {
        AppLogger.error(
          'Razorpay service test failed',
          tag: 'PaymentDialog',
          error: e,
        );
        throw PaymentProcessingException(
          'Payment service not available. Please try again.',
          code: 'SERVICE_UNAVAILABLE',
        );
      }

      // Process payment (authentication validation is handled internally)
      final success = await ref
          .read(paymentProvider.notifier)
          .processAdRemovalPayment();

      if (success && mounted) {
        AppLogger.info(
          'Payment successful, closing dialog',
          tag: 'PaymentDialog',
        );
        Navigator.of(context).pop(true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🎉 Ads removed successfully! Enjoy ad-free gaming.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      AppLogger.error(
        'Payment process failed',
        tag: 'PaymentDialog',
        error: error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Helper function to show payment dialog
Future<bool?> showPaymentDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PaymentDialog(),
  );
}
