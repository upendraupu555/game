import '../entities/payment_entity.dart';

/// Payment repository interface
/// Following clean architecture - domain layer repository interface
abstract class PaymentRepository {
  /// Process a payment for ad removal
  /// Returns the payment entity with updated status
  Future<PaymentEntity> processAdRemovalPayment({
    required String orderId,
    required int amount,
    required String currency,
    required Map<String, dynamic> userInfo,
  });

  /// Get current purchase status
  Future<PurchaseStatusEntity> getPurchaseStatus();

  /// Update purchase status after successful payment
  Future<void> updatePurchaseStatus(PurchaseStatusEntity status);

  /// Save payment transaction details
  Future<void> savePaymentTransaction(PaymentEntity payment);

  /// Get payment transaction by ID
  Future<PaymentEntity?> getPaymentTransaction(String transactionId);

  /// Get all payment transactions
  Future<List<PaymentEntity>> getAllPaymentTransactions();

  /// Check if ads are removed (convenience method)
  Future<bool> areAdsRemoved();

  /// Clear all payment data (for testing/reset purposes)
  Future<void> clearPaymentData();

  /// Verify payment with server (if needed for additional security)
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  });

  /// Handle payment success
  Future<void> handlePaymentSuccess({
    required String paymentId,
    required String orderId,
    required String signature,
  });

  /// Handle payment failure
  Future<void> handlePaymentFailure({
    required String orderId,
    required String errorCode,
    required String errorDescription,
  });

  /// Handle payment cancellation
  Future<void> handlePaymentCancellation({required String orderId});

  /// Generate unique order ID
  String generateOrderId();

  /// Validate payment amount
  bool validatePaymentAmount(int amount);

  /// Get payment configuration
  Map<String, dynamic> getPaymentConfig();

  /// Save purchase to Supabase
  Future<void> savePurchaseToSupabase({
    required String userId,
    required PaymentEntity payment,
  });

  /// Get user's ad removal status from Supabase
  Future<bool> getUserAdRemovalStatusFromSupabase(String userId);

  /// Sync ad removal status from Supabase to local storage
  Future<void> syncAdRemovalStatusFromSupabase(String userId);
}

/// Payment exceptions
class PaymentException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const PaymentException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    return 'PaymentException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Payment validation exception
class PaymentValidationException extends PaymentException {
  const PaymentValidationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Payment processing exception
class PaymentProcessingException extends PaymentException {
  const PaymentProcessingException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Payment verification exception
class PaymentVerificationException extends PaymentException {
  const PaymentVerificationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Payment storage exception
class PaymentStorageException extends PaymentException {
  const PaymentStorageException(
    super.message, {
    super.code,
    super.originalError,
  });
}
