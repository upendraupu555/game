import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/auth_error_handler.dart';
import '../../data/datasources/payment_local_datasource.dart';
import '../../data/datasources/supabase_purchase_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/services/razorpay_payment_service.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/payment_usecases.dart';
import 'theme_providers.dart';
import 'user_providers.dart';

/// Provider for payment local data source
final paymentLocalDataSourceProvider = Provider<PaymentLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PaymentLocalDataSourceImpl(prefs);
});

/// Provider for Supabase purchase data source
final supabasePurchaseDataSourceProvider = Provider<SupabasePurchaseDataSource>(
  (ref) {
    return SupabasePurchaseDataSourceImpl();
  },
);

/// Provider for Razorpay payment service (lazy initialization)
final razorpayPaymentServiceProvider = Provider<RazorpayPaymentService>((ref) {
  final service = RazorpayPaymentService();

  AppLogger.info(
    'Razorpay payment service created (not initialized yet)',
    tag: 'PaymentProviders',
  );

  // Dispose when provider is disposed
  ref.onDispose(() {
    AppLogger.info(
      'Disposing Razorpay payment service',
      tag: 'PaymentProviders',
    );
    service.dispose();
  });

  return service;
});

/// Provider for payment repository
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final localDataSource = ref.watch(paymentLocalDataSourceProvider);
  final paymentService = ref.watch(razorpayPaymentServiceProvider);
  final supabasePurchaseDataSource = ref.watch(
    supabasePurchaseDataSourceProvider,
  );
  return PaymentRepositoryImpl(
    localDataSource,
    paymentService,
    supabasePurchaseDataSource,
  );
});

/// Use case providers
final validateAuthenticationForPaymentUseCaseProvider =
    Provider<ValidateAuthenticationForPaymentUseCase>((ref) {
      return const ValidateAuthenticationForPaymentUseCase();
    });

final processAdRemovalPaymentUseCaseProvider =
    Provider<ProcessAdRemovalPaymentUseCase>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return ProcessAdRemovalPaymentUseCase(repository);
    });

final checkPurchaseStatusUseCaseProvider = Provider<CheckPurchaseStatusUseCase>(
  (ref) {
    final repository = ref.watch(paymentRepositoryProvider);
    return CheckPurchaseStatusUseCase(repository);
  },
);

final areAdsRemovedUseCaseProvider = Provider<AreAdsRemovedUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return AreAdsRemovedUseCase(repository);
});

final getPaymentTransactionsUseCaseProvider =
    Provider<GetPaymentTransactionsUseCase>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return GetPaymentTransactionsUseCase(repository);
    });

final verifyPaymentUseCaseProvider = Provider<VerifyPaymentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return VerifyPaymentUseCase(repository);
});

final handlePaymentSuccessUseCaseProvider =
    Provider<HandlePaymentSuccessUseCase>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return HandlePaymentSuccessUseCase(repository);
    });

final getPaymentConfigUseCaseProvider = Provider<GetPaymentConfigUseCase>((
  ref,
) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetPaymentConfigUseCase(repository);
});

/// Payment state
class PaymentState {
  final bool isProcessing;
  final PaymentEntity? currentPayment;
  final String? error;
  final bool isAdRemovalPurchased;
  final DateTime? purchaseDate;

  const PaymentState({
    this.isProcessing = false,
    this.currentPayment,
    this.error,
    this.isAdRemovalPurchased = false,
    this.purchaseDate,
  });

  PaymentState copyWith({
    bool? isProcessing,
    PaymentEntity? currentPayment,
    String? error,
    bool? isAdRemovalPurchased,
    DateTime? purchaseDate,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      currentPayment: currentPayment ?? this.currentPayment,
      error: error,
      isAdRemovalPurchased: isAdRemovalPurchased ?? this.isAdRemovalPurchased,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentState &&
        other.isProcessing == isProcessing &&
        other.currentPayment == currentPayment &&
        other.error == error &&
        other.isAdRemovalPurchased == isAdRemovalPurchased &&
        other.purchaseDate == purchaseDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      isProcessing,
      currentPayment,
      error,
      isAdRemovalPurchased,
      purchaseDate,
    );
  }

  @override
  String toString() {
    return 'PaymentState('
        'isProcessing: $isProcessing, '
        'currentPayment: $currentPayment, '
        'error: $error, '
        'isAdRemovalPurchased: $isAdRemovalPurchased, '
        'purchaseDate: $purchaseDate'
        ')';
  }
}

/// Payment state notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier(this._ref) : super(const PaymentState()) {
    _loadPurchaseStatus();
  }

  final Ref _ref;

  /// Load purchase status on initialization
  Future<void> _loadPurchaseStatus() async {
    try {
      final useCase = _ref.read(checkPurchaseStatusUseCaseProvider);
      final purchaseStatus = await useCase.execute();

      state = state.copyWith(
        isAdRemovalPurchased: purchaseStatus.isAdRemovalPurchased,
        purchaseDate: purchaseStatus.purchaseDate,
      );

      AppLogger.debug(
        'Purchase status loaded: ${purchaseStatus.isAdRemovalPurchased}',
        tag: 'PaymentNotifier',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to load purchase status',
        tag: 'PaymentNotifier',
        error: error,
      );

      state = state.copyWith(error: 'Failed to load purchase status: $error');
    }
  }

  /// Process ad removal payment with authentication validation
  Future<bool> processAdRemovalPayment() async {
    if (state.isProcessing) {
      AppLogger.warning('Payment already in progress', tag: 'PaymentNotifier');
      return false;
    }

    try {
      state = state.copyWith(isProcessing: true, error: null);

      // Get current user for authentication validation
      final userState = _ref.read(userProvider);
      final user = userState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      // Validate authentication before proceeding
      final authValidationUseCase = _ref.read(
        validateAuthenticationForPaymentUseCaseProvider,
      );
      final userInfo = authValidationUseCase.execute(user);

      AppLogger.info(
        'Starting ad removal payment process',
        tag: 'PaymentNotifier',
        data: {
          'amount': AppConstants.removeAdsPriceInPaise,
          'currency': AppConstants.paymentCurrency,
          'user': userInfo['username'],
          'isAuthenticated': userInfo['isAuthenticated'],
        },
      );

      final useCase = _ref.read(processAdRemovalPaymentUseCaseProvider);
      final payment = await useCase.execute(
        amount: AppConstants.removeAdsPriceInPaise,
        currency: AppConstants.paymentCurrency,
        userInfo: userInfo,
      );

      state = state.copyWith(isProcessing: false, currentPayment: payment);

      if (payment.status.isSuccessful) {
        // Save purchase to Supabase for authenticated users
        if (user != null && !user.isGuest && user.supabaseUserId != null) {
          try {
            final repository = _ref.read(paymentRepositoryProvider);
            await repository.savePurchaseToSupabase(
              userId: user.supabaseUserId!,
              payment: payment,
            );

            AppLogger.info(
              'Purchase saved to Supabase successfully',
              tag: 'PaymentNotifier',
            );
          } catch (e) {
            AppLogger.error(
              'Failed to save purchase to Supabase, but payment was successful',
              tag: 'PaymentNotifier',
              error: e,
            );
            // Don't fail the payment if Supabase save fails
          }
        }

        // Reload purchase status to reflect the successful purchase
        await _loadPurchaseStatus();

        AppLogger.info(
          'Ad removal payment successful',
          tag: 'PaymentNotifier',
          data: {
            'transactionId': payment.transactionId,
            'orderId': payment.orderId,
          },
        );

        return true;
      } else {
        AppLogger.warning(
          'Ad removal payment failed or cancelled',
          tag: 'PaymentNotifier',
          data: {
            'status': payment.status.toString(),
            'failureReason': payment.failureReason,
          },
        );

        state = state.copyWith(
          error: payment.failureReason ?? 'Payment failed',
        );

        return false;
      }
    } catch (error) {
      AppLogger.error(
        'Failed to process ad removal payment',
        tag: 'PaymentNotifier',
        error: error,
      );

      // Handle authentication-specific errors
      String errorMessage = 'Payment failed: $error';
      if (error is PaymentValidationException) {
        switch (error.code) {
          case 'USER_NOT_FOUND':
          case 'USER_NOT_AUTHENTICATED':
          case 'GUEST_USER_NOT_ALLOWED':
            errorMessage = error.message;
            break;
          default:
            errorMessage = error.message;
        }
      } else if (error is AuthenticationError) {
        // Handle enhanced authentication errors
        errorMessage = error.userFriendlyMessage;

        // Log additional context for email confirmation errors
        if (error.isEmailNotConfirmed) {
          AppLogger.warning(
            'Payment blocked due to unconfirmed email',
            tag: 'PaymentNotifier',
          );
        }
      }

      state = state.copyWith(isProcessing: false, error: errorMessage);

      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh purchase status
  Future<void> refreshPurchaseStatus() async {
    await _loadPurchaseStatus();
  }

  /// Sync ad removal status from Supabase for authenticated users
  Future<void> syncAdRemovalStatusFromSupabase() async {
    try {
      // Get current user
      final userState = _ref.read(userProvider);
      final user = userState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      // Only sync for authenticated users with Supabase ID
      if (user != null && !user.isGuest && user.supabaseUserId != null) {
        AppLogger.info(
          'Syncing ad removal status from Supabase',
          tag: 'PaymentNotifier',
          data: {'userId': user.supabaseUserId},
        );

        final repository = _ref.read(paymentRepositoryProvider);
        await repository.syncAdRemovalStatusFromSupabase(user.supabaseUserId!);

        // Reload local status after sync
        await _loadPurchaseStatus();

        AppLogger.info(
          'Ad removal status sync completed',
          tag: 'PaymentNotifier',
        );
      } else {
        AppLogger.debug(
          'Skipping Supabase sync for guest user',
          tag: 'PaymentNotifier',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to sync ad removal status from Supabase',
        tag: 'PaymentNotifier',
        error: e,
      );
      // Don't rethrow - sync failure shouldn't break the app
    }
  }
}

/// Payment state provider
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((
  ref,
) {
  return PaymentNotifier(ref);
});

/// Computed provider for ads removal status
final areAdsRemovedProvider = Provider<bool>((ref) {
  final paymentState = ref.watch(paymentProvider);
  return paymentState.isAdRemovalPurchased;
});

/// Computed provider for payment processing status
final isPaymentProcessingProvider = Provider<bool>((ref) {
  final paymentState = ref.watch(paymentProvider);
  return paymentState.isProcessing;
});

/// Computed provider for payment error
final paymentErrorProvider = Provider<String?>((ref) {
  final paymentState = ref.watch(paymentProvider);
  return paymentState.error;
});

/// Computed provider for current payment
final currentPaymentProvider = Provider<PaymentEntity?>((ref) {
  final paymentState = ref.watch(paymentProvider);
  return paymentState.currentPayment;
});

/// Computed provider for purchase date
final purchaseDateProvider = Provider<DateTime?>((ref) {
  final paymentState = ref.watch(paymentProvider);
  return paymentState.purchaseDate;
});
