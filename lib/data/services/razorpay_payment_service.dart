import 'dart:async';
import 'dart:math';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';

/// Razorpay payment service for handling payment processing
/// Integrates with Razorpay Flutter SDK for real payment processing
class RazorpayPaymentService {
  Razorpay? _razorpay;
  Completer<PaymentEntity>? _paymentCompleter;
  String? _currentOrderId;
  bool _isInitialized = false;

  /// Initialize Razorpay (lazy initialization)
  void _ensureInitialized() {
    if (_isInitialized) return;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _isInitialized = true;

    AppLogger.info(
      'Razorpay payment service initialized',
      tag: 'RazorpayPaymentService',
    );
  }

  /// Initialize Razorpay (public method for backward compatibility)
  void initialize() {
    _ensureInitialized();
  }

  /// Dispose Razorpay
  void dispose() {
    _razorpay?.clear();
    _isInitialized = false;
    AppLogger.debug(
      'Razorpay payment service disposed',
      tag: 'RazorpayPaymentService',
    );
  }

  /// Process ad removal payment
  Future<PaymentEntity> processAdRemovalPayment({
    required String orderId,
    required Map<String, dynamic> userInfo,
  }) async {
    try {
      // Ensure Razorpay is initialized before processing payment
      _ensureInitialized();

      AppLogger.info(
        'Razorpay service processing payment',
        tag: 'RazorpayPaymentService',
        data: {
          'orderId': orderId,
          'userInfo': userInfo,
          'isInitialized': _isInitialized,
        },
      );

      _currentOrderId = orderId;

      // Create a new completer for this payment
      _paymentCompleter = Completer<PaymentEntity>();

      final options = {
        'key': AppConstants.razorpayKeyId,
        'amount': AppConstants.removeAdsPriceInPaise,
        'currency': AppConstants.paymentCurrency,
        'name': AppConstants.paymentCompanyName,
        'description': AppConstants.removeAdsDescription,
        'order_id': orderId,
        'prefill': {
          'contact': userInfo['phone'] ?? '',
          'email': userInfo['email'] ?? '',
          'name': userInfo['name'] ?? userInfo['username'] ?? 'User',
        },
        'theme': {
          'color': '#D00000', // Using app's primary color
        },
        'notes': {
          'product': AppConstants.removeAdsProductName,
          'user_id': userInfo['gameId'] ?? '',
          'app_version': AppConstants.appVersion,
        },
      };

      AppLogger.info(
        'Starting Razorpay payment',
        tag: 'RazorpayPaymentService',
        data: {
          'orderId': orderId,
          'amount': AppConstants.removeAdsPriceInPaise,
          'currency': AppConstants.paymentCurrency,
          'options': options,
        },
      );

      AppLogger.info(
        'Calling Razorpay.open() with options',
        tag: 'RazorpayPaymentService',
      );

      _razorpay!.open(options);

      AppLogger.info(
        'Razorpay.open() called successfully, waiting for response',
        tag: 'RazorpayPaymentService',
      );

      // Wait for payment completion with timeout
      return await _paymentCompleter!.future.timeout(
        AppConstants.paymentTimeout,
        onTimeout: () {
          AppLogger.error('Payment timeout', tag: 'RazorpayPaymentService');
          throw PaymentProcessingException(
            'Payment timeout after ${AppConstants.paymentTimeout.inMinutes} minutes',
            code: 'PAYMENT_TIMEOUT',
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Failed to process payment',
        tag: 'RazorpayPaymentService',
        error: e,
      );

      if (e is PaymentException) {
        rethrow;
      }

      throw PaymentProcessingException(
        'Failed to process payment: $e',
        originalError: e,
      );
    }
  }

  /// Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    try {
      AppLogger.info(
        'Payment successful',
        tag: 'RazorpayPaymentService',
        data: {
          'paymentId': response.paymentId,
          'orderId': response.orderId,
          'signature': response.signature,
        },
      );

      final payment = PaymentEntity(
        transactionId: response.paymentId ?? '',
        orderId: response.orderId ?? _currentOrderId ?? '',
        amount: AppConstants.removeAdsPriceInPaise,
        currency: AppConstants.paymentCurrency,
        productName: AppConstants.removeAdsProductName,
        description: AppConstants.removeAdsDescription,
        status: PaymentStatus.success,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: {
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
        },
      );

      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.complete(payment);
      }
    } catch (e) {
      AppLogger.error(
        'Error handling payment success',
        tag: 'RazorpayPaymentService',
        error: e,
      );

      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.completeError(
          PaymentProcessingException(
            'Error processing successful payment: $e',
            originalError: e,
          ),
        );
      }
    }
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    try {
      AppLogger.error(
        'Payment failed',
        tag: 'RazorpayPaymentService',
        error: 'Code: ${response.code}, Message: ${response.message}',
      );

      final payment = PaymentEntity(
        transactionId: 'failed_${DateTime.now().millisecondsSinceEpoch}',
        orderId: _currentOrderId ?? '',
        amount: AppConstants.removeAdsPriceInPaise,
        currency: AppConstants.paymentCurrency,
        productName: AppConstants.removeAdsProductName,
        description: AppConstants.removeAdsDescription,
        status: PaymentStatus.failed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        failureReason: '${response.code}: ${response.message}',
        metadata: {
          'error_code': response.code,
          'error_message': response.message,
        },
      );

      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.complete(payment);
      }
    } catch (e) {
      AppLogger.error(
        'Error handling payment failure',
        tag: 'RazorpayPaymentService',
        error: e,
      );

      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.completeError(
          PaymentProcessingException(
            'Error processing payment failure: $e',
            originalError: e,
          ),
        );
      }
    }
  }

  /// Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.info(
      'External wallet selected: ${response.walletName}',
      tag: 'RazorpayPaymentService',
    );

    // For external wallets, we'll treat it as cancelled for now
    // In a real implementation, you might want to handle this differently
    final payment = PaymentEntity(
      transactionId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
      orderId: _currentOrderId ?? '',
      amount: AppConstants.removeAdsPriceInPaise,
      currency: AppConstants.paymentCurrency,
      productName: AppConstants.removeAdsProductName,
      description: AppConstants.removeAdsDescription,
      status: PaymentStatus.cancelled,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      failureReason: 'External wallet selected: ${response.walletName}',
      metadata: {'wallet_name': response.walletName},
    );

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(payment);
    }
  }

  /// Generate unique order ID
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'order_${timestamp}_$random';
  }

  /// Validate payment amount
  static bool validatePaymentAmount(int amount) {
    return amount > 0 && amount == AppConstants.removeAdsPriceInPaise;
  }

  /// Get payment configuration
  static Map<String, dynamic> getPaymentConfig() {
    return {
      'keyId': AppConstants.razorpayKeyId,
      'amount': AppConstants.removeAdsPriceInPaise,
      'currency': AppConstants.paymentCurrency,
      'companyName': AppConstants.paymentCompanyName,
      'productName': AppConstants.removeAdsProductName,
      'description': AppConstants.removeAdsDescription,
      'timeout': AppConstants.paymentTimeout.inMilliseconds,
    };
  }

  /// Test Razorpay initialization (for debugging)
  void testInitialization() {
    try {
      AppLogger.info(
        'Testing Razorpay initialization',
        tag: 'RazorpayPaymentService',
        data: {
          'keyId': AppConstants.razorpayKeyId,
          'isInitialized': _isInitialized,
        },
      );

      // Test if we can create a simple options object
      final testOptions = {
        'key': AppConstants.razorpayKeyId,
        'amount': 100, // Test amount
        'currency': 'INR',
        'name': 'Test',
        'description': 'Test payment',
      };

      AppLogger.info(
        'Test options created successfully',
        tag: 'RazorpayPaymentService',
        data: testOptions,
      );
    } catch (e) {
      AppLogger.error(
        'Razorpay initialization test failed',
        tag: 'RazorpayPaymentService',
        error: e,
      );
    }
  }
}
