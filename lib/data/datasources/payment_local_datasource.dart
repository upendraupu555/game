import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

/// Payment local data source interface
abstract class PaymentLocalDataSource {
  /// Get current purchase status
  Future<PurchaseStatusModel?> getPurchaseStatus();

  /// Save purchase status
  Future<void> savePurchaseStatus(PurchaseStatusModel status);

  /// Save payment transaction
  Future<void> savePaymentTransaction(PaymentModel payment);

  /// Get payment transaction by ID
  Future<PaymentModel?> getPaymentTransaction(String transactionId);

  /// Get all payment transactions
  Future<List<PaymentModel>> getAllPaymentTransactions();

  /// Clear all payment data
  Future<void> clearPaymentData();

  /// Check if ads are removed
  Future<bool> areAdsRemoved();
}

/// Implementation of payment local data source using SharedPreferences
class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final SharedPreferences _prefs;

  const PaymentLocalDataSourceImpl(this._prefs);

  @override
  Future<PurchaseStatusModel?> getPurchaseStatus() async {
    try {
      final statusJson = _prefs.getString(AppConstants.adRemovalPurchaseKey);
      if (statusJson == null) {
        AppLogger.debug(
          'No purchase status found, returning default',
          tag: 'PaymentLocalDataSource',
        );
        return const PurchaseStatusModel(isAdRemovalPurchased: false);
      }

      final status = PurchaseStatusModel.fromJsonString(statusJson);
      AppLogger.debug(
        'Retrieved purchase status: ${status.isAdRemovalPurchased}',
        tag: 'PaymentLocalDataSource',
      );
      return status;
    } catch (e) {
      AppLogger.error(
        'Failed to get purchase status',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      throw PaymentStorageException('Failed to get purchase status: $e');
    }
  }

  @override
  Future<void> savePurchaseStatus(PurchaseStatusModel status) async {
    try {
      final statusJson = status.toJsonString();
      await _prefs.setString(AppConstants.adRemovalPurchaseKey, statusJson);

      AppLogger.info(
        'Purchase status saved: ${status.isAdRemovalPurchased}',
        tag: 'PaymentLocalDataSource',
        data: {
          'isAdRemovalPurchased': status.isAdRemovalPurchased,
          'purchaseDate': status.purchaseDate,
          'transactionId': status.transactionId,
        },
      );
    } catch (e) {
      AppLogger.error(
        'Failed to save purchase status',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      throw PaymentStorageException('Failed to save purchase status: $e');
    }
  }

  @override
  Future<void> savePaymentTransaction(PaymentModel payment) async {
    try {
      // Get existing transactions
      final transactions = await getAllPaymentTransactions();

      // Add or update the transaction
      final existingIndex = transactions.indexWhere(
        (t) => t.transactionId == payment.transactionId,
      );

      if (existingIndex >= 0) {
        transactions[existingIndex] = payment;
      } else {
        transactions.add(payment);
      }

      // Save updated transactions list
      final transactionsJson = jsonEncode(
        transactions.map((t) => t.toJson()).toList(),
      );
      await _prefs.setString(
        AppConstants.paymentTransactionKey,
        transactionsJson,
      );

      AppLogger.info(
        'Payment transaction saved: ${payment.transactionId}',
        tag: 'PaymentLocalDataSource',
        data: {
          'transactionId': payment.transactionId,
          'orderId': payment.orderId,
          'status': payment.status,
          'amount': payment.amount,
        },
      );
    } catch (e) {
      AppLogger.error(
        'Failed to save payment transaction',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      throw PaymentStorageException('Failed to save payment transaction: $e');
    }
  }

  @override
  Future<PaymentModel?> getPaymentTransaction(String transactionId) async {
    try {
      final transactions = await getAllPaymentTransactions();
      final transaction =
          transactions.where((t) => t.transactionId == transactionId).isNotEmpty
          ? transactions.where((t) => t.transactionId == transactionId).first
          : null;

      AppLogger.debug(
        'Retrieved payment transaction: $transactionId',
        tag: 'PaymentLocalDataSource',
        data: {'found': transaction != null},
      );

      return transaction;
    } catch (e) {
      AppLogger.error(
        'Failed to get payment transaction',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      throw PaymentStorageException('Failed to get payment transaction: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getAllPaymentTransactions() async {
    try {
      final transactionsJson = _prefs.getString(
        AppConstants.paymentTransactionKey,
      );
      if (transactionsJson == null) {
        AppLogger.debug(
          'No payment transactions found',
          tag: 'PaymentLocalDataSource',
        );
        return [];
      }

      final transactionsList = jsonDecode(transactionsJson) as List<dynamic>;
      final transactions = transactionsList
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.debug(
        'Retrieved ${transactions.length} payment transactions',
        tag: 'PaymentLocalDataSource',
      );

      return transactions;
    } catch (e) {
      AppLogger.error(
        'Failed to get all payment transactions',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      throw PaymentStorageException('Failed to get payment transactions: $e');
    }
  }

  @override
  Future<void> clearPaymentData() async {
    try {
      await _prefs.remove(AppConstants.adRemovalPurchaseKey);
      await _prefs.remove(AppConstants.paymentTransactionKey);
      await _prefs.remove(AppConstants.lastPaymentAttemptKey);

      AppLogger.info('Payment data cleared', tag: 'PaymentLocalDataSource');
    } catch (e) {
      AppLogger.error(
        'Failed to clear payment data',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      throw PaymentStorageException('Failed to clear payment data: $e');
    }
  }

  @override
  Future<bool> areAdsRemoved() async {
    try {
      final status = await getPurchaseStatus();
      final adsRemoved = status?.isAdRemovalPurchased ?? false;

      AppLogger.debug(
        'Ads removal status: $adsRemoved',
        tag: 'PaymentLocalDataSource',
      );

      return adsRemoved;
    } catch (e) {
      AppLogger.error(
        'Failed to check ads removal status',
        tag: 'PaymentLocalDataSource',
        error: e,
      );
      // Return false as default to show ads if there's an error
      return false;
    }
  }
}
