import '../entities/payment_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/payment_repository.dart';

/// Use case for validating user authentication before payment
class ValidateAuthenticationForPaymentUseCase {
  const ValidateAuthenticationForPaymentUseCase();

  /// Validates if user is authenticated and eligible for payment
  /// Returns user info if valid, throws exception if not
  Map<String, dynamic> execute(UserEntity? user) {
    if (user == null) {
      throw PaymentValidationException(
        'User not found. Please sign in to make a purchase.',
        code: 'USER_NOT_FOUND',
      );
    }

    if (user.isGuest) {
      throw PaymentValidationException(
        'Guest users cannot make purchases. Please sign in with your account.',
        code: 'GUEST_USER_NOT_ALLOWED',
      );
    }

    if (!user.isAuthenticated) {
      throw PaymentValidationException(
        'User not authenticated. Please sign in to make a purchase.',
        code: 'USER_NOT_AUTHENTICATED',
      );
    }

    // Return user info for payment processing
    return {
      'gameId': user.gameId,
      'username': user.username,
      'email': user.email ?? '',
      'name': user.displayName,
      'supabaseUserId': user.supabaseUserId ?? '',
      'isAuthenticated': user.isAuthenticated,
    };
  }
}

/// Use case for processing ad removal payment
class ProcessAdRemovalPaymentUseCase {
  final PaymentRepository _repository;

  const ProcessAdRemovalPaymentUseCase(this._repository);

  Future<PaymentEntity> execute({
    required int amount,
    required String currency,
    required Map<String, dynamic> userInfo,
  }) async {
    // Generate unique order ID
    final orderId = _repository.generateOrderId();

    // Validate payment amount
    if (!_repository.validatePaymentAmount(amount)) {
      throw PaymentValidationException(
        'Invalid payment amount: $amount',
        code: 'INVALID_AMOUNT',
      );
    }

    // Process payment
    return await _repository.processAdRemovalPayment(
      orderId: orderId,
      amount: amount,
      currency: currency,
      userInfo: userInfo,
    );
  }
}

/// Use case for checking purchase status
class CheckPurchaseStatusUseCase {
  final PaymentRepository _repository;

  const CheckPurchaseStatusUseCase(this._repository);

  Future<PurchaseStatusEntity> execute() async {
    return await _repository.getPurchaseStatus();
  }
}

/// Use case for checking if ads are removed
class AreAdsRemovedUseCase {
  final PaymentRepository _repository;

  const AreAdsRemovedUseCase(this._repository);

  Future<bool> execute() async {
    return await _repository.areAdsRemoved();
  }
}

/// Use case for getting payment transactions
class GetPaymentTransactionsUseCase {
  final PaymentRepository _repository;

  const GetPaymentTransactionsUseCase(this._repository);

  Future<List<PaymentEntity>> execute() async {
    return await _repository.getAllPaymentTransactions();
  }
}

/// Use case for getting specific payment transaction
class GetPaymentTransactionUseCase {
  final PaymentRepository _repository;

  const GetPaymentTransactionUseCase(this._repository);

  Future<PaymentEntity?> execute(String transactionId) async {
    return await _repository.getPaymentTransaction(transactionId);
  }
}

/// Use case for verifying payment
class VerifyPaymentUseCase {
  final PaymentRepository _repository;

  const VerifyPaymentUseCase(this._repository);

  Future<bool> execute({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    return await _repository.verifyPayment(
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }
}

/// Use case for handling payment success
class HandlePaymentSuccessUseCase {
  final PaymentRepository _repository;

  const HandlePaymentSuccessUseCase(this._repository);

  Future<void> execute({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    return await _repository.handlePaymentSuccess(
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }
}

/// Use case for handling payment failure
class HandlePaymentFailureUseCase {
  final PaymentRepository _repository;

  const HandlePaymentFailureUseCase(this._repository);

  Future<void> execute({
    required String orderId,
    required String errorCode,
    required String errorDescription,
  }) async {
    return await _repository.handlePaymentFailure(
      orderId: orderId,
      errorCode: errorCode,
      errorDescription: errorDescription,
    );
  }
}

/// Use case for handling payment cancellation
class HandlePaymentCancellationUseCase {
  final PaymentRepository _repository;

  const HandlePaymentCancellationUseCase(this._repository);

  Future<void> execute({required String orderId}) async {
    return await _repository.handlePaymentCancellation(orderId: orderId);
  }
}

/// Use case for clearing payment data
class ClearPaymentDataUseCase {
  final PaymentRepository _repository;

  const ClearPaymentDataUseCase(this._repository);

  Future<void> execute() async {
    return await _repository.clearPaymentData();
  }
}

/// Use case for getting payment configuration
class GetPaymentConfigUseCase {
  final PaymentRepository _repository;

  const GetPaymentConfigUseCase(this._repository);

  Map<String, dynamic> execute() {
    return _repository.getPaymentConfig();
  }
}

/// Use case for updating purchase status
class UpdatePurchaseStatusUseCase {
  final PaymentRepository _repository;

  const UpdatePurchaseStatusUseCase(this._repository);

  Future<void> execute(PurchaseStatusEntity status) async {
    return await _repository.updatePurchaseStatus(status);
  }
}
