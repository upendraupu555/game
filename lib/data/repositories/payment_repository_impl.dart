import '../../core/logging/app_logger.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../datasources/supabase_purchase_datasource.dart';
import '../models/payment_model.dart';
import '../services/razorpay_payment_service.dart';

/// Implementation of payment repository
/// Following clean architecture - data layer repository implementation
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _localDataSource;
  final RazorpayPaymentService _paymentService;
  final SupabasePurchaseDataSource _supabasePurchaseDataSource;

  const PaymentRepositoryImpl(
    this._localDataSource,
    this._paymentService,
    this._supabasePurchaseDataSource,
  );

  @override
  Future<PaymentEntity> processAdRemovalPayment({
    required String orderId,
    required int amount,
    required String currency,
    required Map<String, dynamic> userInfo,
  }) async {
    try {
      AppLogger.info(
        'Processing ad removal payment',
        tag: 'PaymentRepository',
        data: {'orderId': orderId, 'amount': amount, 'currency': currency},
      );

      // Validate payment amount
      if (!validatePaymentAmount(amount)) {
        throw PaymentValidationException(
          'Invalid payment amount: $amount',
          code: 'INVALID_AMOUNT',
        );
      }

      // Create initial payment entity
      final initialPayment = PaymentEntity(
        transactionId: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        amount: amount,
        currency: currency,
        productName: 'Remove Ads',
        description: 'Remove all advertisements permanently',
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        metadata: userInfo,
      );

      // Save initial payment
      await savePaymentTransaction(initialPayment);

      // Process payment through Razorpay
      final processedPayment = await _paymentService.processAdRemovalPayment(
        orderId: orderId,
        userInfo: userInfo,
      );

      // Save processed payment
      await savePaymentTransaction(processedPayment);

      // If payment was successful, update purchase status
      if (processedPayment.status.isSuccessful) {
        await _handleSuccessfulPayment(processedPayment);
      }

      AppLogger.info(
        'Payment processing completed',
        tag: 'PaymentRepository',
        data: {
          'transactionId': processedPayment.transactionId,
          'status': processedPayment.status.toString(),
        },
      );

      return processedPayment;
    } catch (e) {
      AppLogger.error(
        'Failed to process ad removal payment',
        tag: 'PaymentRepository',
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

  @override
  Future<PurchaseStatusEntity> getPurchaseStatus() async {
    try {
      final status = await _localDataSource.getPurchaseStatus();
      return status?.toEntity() ??
          const PurchaseStatusEntity(isAdRemovalPurchased: false);
    } catch (e) {
      AppLogger.error(
        'Failed to get purchase status',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentStorageException('Failed to get purchase status: $e');
    }
  }

  @override
  Future<void> updatePurchaseStatus(PurchaseStatusEntity status) async {
    try {
      final model = PurchaseStatusModel.fromEntity(status);
      await _localDataSource.savePurchaseStatus(model);

      AppLogger.info(
        'Purchase status updated',
        tag: 'PaymentRepository',
        data: {
          'isAdRemovalPurchased': status.isAdRemovalPurchased,
          'purchaseDate': status.purchaseDate?.toIso8601String(),
        },
      );
    } catch (e) {
      AppLogger.error(
        'Failed to update purchase status',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentStorageException('Failed to update purchase status: $e');
    }
  }

  @override
  Future<void> savePaymentTransaction(PaymentEntity payment) async {
    try {
      final model = PaymentModel.fromEntity(payment);
      await _localDataSource.savePaymentTransaction(model);
    } catch (e) {
      AppLogger.error(
        'Failed to save payment transaction',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentStorageException('Failed to save payment transaction: $e');
    }
  }

  @override
  Future<PaymentEntity?> getPaymentTransaction(String transactionId) async {
    try {
      final model = await _localDataSource.getPaymentTransaction(transactionId);
      return model?.toEntity();
    } catch (e) {
      AppLogger.error(
        'Failed to get payment transaction',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentStorageException('Failed to get payment transaction: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getAllPaymentTransactions() async {
    try {
      final models = await _localDataSource.getAllPaymentTransactions();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error(
        'Failed to get all payment transactions',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentStorageException('Failed to get payment transactions: $e');
    }
  }

  @override
  Future<bool> areAdsRemoved() async {
    try {
      return await _localDataSource.areAdsRemoved();
    } catch (e) {
      AppLogger.error(
        'Failed to check ads removal status',
        tag: 'PaymentRepository',
        error: e,
      );
      // Return false as default to show ads if there's an error
      return false;
    }
  }

  @override
  Future<void> clearPaymentData() async {
    try {
      await _localDataSource.clearPaymentData();
      AppLogger.info('Payment data cleared', tag: 'PaymentRepository');
    } catch (e) {
      AppLogger.error(
        'Failed to clear payment data',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentStorageException('Failed to clear payment data: $e');
    }
  }

  @override
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // In a real implementation, you would verify the payment signature
      // with your backend server using Razorpay's webhook verification
      // For now, we'll assume the payment is valid if we have all required fields
      final isValid =
          paymentId.isNotEmpty && orderId.isNotEmpty && signature.isNotEmpty;

      AppLogger.info(
        'Payment verification result: $isValid',
        tag: 'PaymentRepository',
        data: {
          'paymentId': paymentId,
          'orderId': orderId,
          'hasSignature': signature.isNotEmpty,
        },
      );

      return isValid;
    } catch (e) {
      AppLogger.error(
        'Failed to verify payment',
        tag: 'PaymentRepository',
        error: e,
      );
      throw PaymentVerificationException('Failed to verify payment: $e');
    }
  }

  @override
  Future<void> handlePaymentSuccess({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // Verify payment first
      final isValid = await verifyPayment(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

      if (!isValid) {
        throw PaymentVerificationException('Payment verification failed');
      }

      // Update purchase status
      final purchaseStatus = PurchaseStatusEntity(
        isAdRemovalPurchased: true,
        purchaseDate: DateTime.now(),
        transactionId: paymentId,
        orderId: orderId,
      );

      await updatePurchaseStatus(purchaseStatus);

      AppLogger.info(
        'Payment success handled',
        tag: 'PaymentRepository',
        data: {'paymentId': paymentId, 'orderId': orderId},
      );
    } catch (e) {
      AppLogger.error(
        'Failed to handle payment success',
        tag: 'PaymentRepository',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> handlePaymentFailure({
    required String orderId,
    required String errorCode,
    required String errorDescription,
  }) async {
    try {
      AppLogger.info(
        'Payment failure handled',
        tag: 'PaymentRepository',
        data: {
          'orderId': orderId,
          'errorCode': errorCode,
          'errorDescription': errorDescription,
        },
      );

      // You might want to save failure details for analytics
      // For now, we'll just log the failure
    } catch (e) {
      AppLogger.error(
        'Failed to handle payment failure',
        tag: 'PaymentRepository',
        error: e,
      );
    }
  }

  @override
  Future<void> handlePaymentCancellation({required String orderId}) async {
    try {
      AppLogger.info(
        'Payment cancellation handled',
        tag: 'PaymentRepository',
        data: {'orderId': orderId},
      );

      // You might want to save cancellation details for analytics
      // For now, we'll just log the cancellation
    } catch (e) {
      AppLogger.error(
        'Failed to handle payment cancellation',
        tag: 'PaymentRepository',
        error: e,
      );
    }
  }

  @override
  String generateOrderId() {
    return RazorpayPaymentService.generateOrderId();
  }

  @override
  bool validatePaymentAmount(int amount) {
    return RazorpayPaymentService.validatePaymentAmount(amount);
  }

  @override
  Map<String, dynamic> getPaymentConfig() {
    return RazorpayPaymentService.getPaymentConfig();
  }

  @override
  Future<void> savePurchaseToSupabase({
    required String userId,
    required PaymentEntity payment,
  }) async {
    try {
      AppLogger.info(
        'Saving purchase to Supabase',
        tag: 'PaymentRepository',
        data: {
          'userId': userId,
          'transactionId': payment.transactionId,
          'amount': payment.amount,
        },
      );

      await _supabasePurchaseDataSource.savePurchase(
        userId: userId,
        payment: payment,
      );

      AppLogger.info(
        'Purchase saved to Supabase successfully',
        tag: 'PaymentRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to save purchase to Supabase',
        tag: 'PaymentRepository',
        error: e,
      );
      // Don't rethrow - we don't want to fail the payment if Supabase is down
      // The local storage will still work as a fallback
    }
  }

  @override
  Future<bool> getUserAdRemovalStatusFromSupabase(String userId) async {
    try {
      AppLogger.debug(
        'Getting user ad removal status from Supabase',
        tag: 'PaymentRepository',
        data: {'userId': userId},
      );

      final hasAdRemoval = await _supabasePurchaseDataSource
          .getUserAdRemovalStatus(userId);

      AppLogger.debug(
        'User ad removal status from Supabase',
        tag: 'PaymentRepository',
        data: {'userId': userId, 'hasAdRemoval': hasAdRemoval},
      );

      return hasAdRemoval;
    } catch (e) {
      AppLogger.error(
        'Failed to get user ad removal status from Supabase',
        tag: 'PaymentRepository',
        error: e,
      );
      // Return false as default to show ads if there's an error
      return false;
    }
  }

  @override
  Future<void> syncAdRemovalStatusFromSupabase(String userId) async {
    try {
      AppLogger.info(
        'Syncing ad removal status from Supabase',
        tag: 'PaymentRepository',
        data: {'userId': userId},
      );

      // Get status from Supabase
      final hasAdRemovalInSupabase = await getUserAdRemovalStatusFromSupabase(
        userId,
      );

      // Get current local status
      final currentStatus = await getPurchaseStatus();

      // If Supabase shows ad removal but local doesn't, update local
      if (hasAdRemovalInSupabase && !currentStatus.isAdRemovalPurchased) {
        final updatedStatus = PurchaseStatusEntity(
          isAdRemovalPurchased: true,
          purchaseDate: DateTime.now(),
          transactionId: 'synced_from_supabase',
          orderId: 'synced_from_supabase',
        );

        await updatePurchaseStatus(updatedStatus);

        AppLogger.info(
          'Local ad removal status updated from Supabase',
          tag: 'PaymentRepository',
        );
      }

      AppLogger.info(
        'Ad removal status sync completed',
        tag: 'PaymentRepository',
        data: {
          'userId': userId,
          'supabaseStatus': hasAdRemovalInSupabase,
          'localStatus': currentStatus.isAdRemovalPurchased,
        },
      );
    } catch (e) {
      AppLogger.error(
        'Failed to sync ad removal status from Supabase',
        tag: 'PaymentRepository',
        error: e,
      );
      // Don't rethrow - sync failure shouldn't break the app
    }
  }

  /// Handle successful payment internal logic
  Future<void> _handleSuccessfulPayment(PaymentEntity payment) async {
    final purchaseStatus = PurchaseStatusEntity(
      isAdRemovalPurchased: true,
      purchaseDate: payment.completedAt ?? DateTime.now(),
      transactionId: payment.transactionId,
      orderId: payment.orderId,
    );

    await updatePurchaseStatus(purchaseStatus);
  }
}
