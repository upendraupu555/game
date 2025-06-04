import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/payment_entity.dart';

/// Supabase purchase data source for handling purchase persistence
/// Manages user purchases in Supabase database
abstract class SupabasePurchaseDataSource {
  /// Save a purchase to Supabase
  Future<void> savePurchase({
    required String userId,
    required PaymentEntity payment,
  });

  /// Get user's ad removal status from Supabase
  Future<bool> getUserAdRemovalStatus(String userId);

  /// Get all purchases for a user
  Future<List<Map<String, dynamic>>> getUserPurchases(String userId);

  /// Update purchase status
  Future<void> updatePurchaseStatus({
    required String userId,
    required String transactionId,
    required String status,
  });

  /// Check if user has active ad removal purchase
  Future<bool> hasActiveAdRemoval(String userId);
}

/// Implementation of Supabase purchase data source
class SupabasePurchaseDataSourceImpl implements SupabasePurchaseDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> savePurchase({
    required String userId,
    required PaymentEntity payment,
  }) async {
    try {
      AppLogger.info(
        'Saving purchase to Supabase',
        tag: 'SupabasePurchaseDataSource',
        data: {
          'userId': userId,
          'transactionId': payment.transactionId,
          'amount': payment.amount,
          'status': payment.status.toString(),
        },
      );

      final purchaseData = {
        AppConstants.purchaseUserIdColumn: userId,
        AppConstants.purchaseProductTypeColumn:
            AppConstants.adRemovalProductType,
        AppConstants.purchaseStatusColumn: _mapPaymentStatusToString(
          payment.status,
        ),
        AppConstants.purchaseTransactionIdColumn: payment.transactionId,
        AppConstants.purchaseAmountColumn: payment.amount,
        AppConstants.purchaseCurrencyColumn: payment.currency,
        AppConstants.purchasePurchasedAtColumn: payment.completedAt
            ?.toIso8601String(),
        AppConstants.purchaseCreatedAtColumn: payment.createdAt
            .toIso8601String(),
        AppConstants.purchaseUpdatedAtColumn: DateTime.now().toIso8601String(),
        AppConstants.purchaseMetadataColumn: payment.metadata ?? {},
      };

      // Use upsert to handle duplicate transactions
      await _supabase
          .from(AppConstants.userPurchasesTable)
          .upsert(
            purchaseData,
            onConflict: AppConstants.purchaseTransactionIdColumn,
          );

      AppLogger.info(
        'Purchase saved successfully to Supabase',
        tag: 'SupabasePurchaseDataSource',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to save purchase to Supabase',
        tag: 'SupabasePurchaseDataSource',
        error: error,
      );
      rethrow;
    }
  }

  @override
  Future<bool> getUserAdRemovalStatus(String userId) async {
    try {
      AppLogger.debug(
        'Checking user ad removal status in Supabase',
        tag: 'SupabasePurchaseDataSource',
        data: {'userId': userId},
      );

      final response = await _supabase
          .from(AppConstants.userPurchasesTable)
          .select(AppConstants.purchaseStatusColumn)
          .eq(AppConstants.purchaseUserIdColumn, userId)
          .eq(
            AppConstants.purchaseProductTypeColumn,
            AppConstants.adRemovalProductType,
          )
          .eq(
            AppConstants.purchaseStatusColumn,
            AppConstants.purchaseStatusCompleted,
          )
          .maybeSingle();

      final hasAdRemoval = response != null;

      AppLogger.debug(
        'User ad removal status retrieved from Supabase',
        tag: 'SupabasePurchaseDataSource',
        data: {'userId': userId, 'hasAdRemoval': hasAdRemoval},
      );

      return hasAdRemoval;
    } catch (error) {
      AppLogger.error(
        'Failed to get user ad removal status from Supabase',
        tag: 'SupabasePurchaseDataSource',
        error: error,
      );
      // Return false as default to show ads if there's an error
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserPurchases(String userId) async {
    try {
      AppLogger.debug(
        'Getting user purchases from Supabase',
        tag: 'SupabasePurchaseDataSource',
        data: {'userId': userId},
      );

      final response = await _supabase
          .from(AppConstants.userPurchasesTable)
          .select('*')
          .eq(AppConstants.purchaseUserIdColumn, userId)
          .order(AppConstants.purchaseCreatedAtColumn, ascending: false);

      AppLogger.debug(
        'User purchases retrieved from Supabase',
        tag: 'SupabasePurchaseDataSource',
        data: {'userId': userId, 'purchaseCount': response.length},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      AppLogger.error(
        'Failed to get user purchases from Supabase',
        tag: 'SupabasePurchaseDataSource',
        error: error,
      );
      return [];
    }
  }

  @override
  Future<void> updatePurchaseStatus({
    required String userId,
    required String transactionId,
    required String status,
  }) async {
    try {
      AppLogger.info(
        'Updating purchase status in Supabase',
        tag: 'SupabasePurchaseDataSource',
        data: {
          'userId': userId,
          'transactionId': transactionId,
          'status': status,
        },
      );

      await _supabase
          .from(AppConstants.userPurchasesTable)
          .update({
            AppConstants.purchaseStatusColumn: status,
            AppConstants.purchaseUpdatedAtColumn: DateTime.now()
                .toIso8601String(),
          })
          .eq(AppConstants.purchaseUserIdColumn, userId)
          .eq(AppConstants.purchaseTransactionIdColumn, transactionId);

      AppLogger.info(
        'Purchase status updated successfully in Supabase',
        tag: 'SupabasePurchaseDataSource',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to update purchase status in Supabase',
        tag: 'SupabasePurchaseDataSource',
        error: error,
      );
      rethrow;
    }
  }

  @override
  Future<bool> hasActiveAdRemoval(String userId) async {
    return await getUserAdRemovalStatus(userId);
  }

  /// Map PaymentStatus to string for database storage
  String _mapPaymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return AppConstants.purchaseStatusCompleted;
      case PaymentStatus.pending:
        return AppConstants.purchaseStatusPending;
      case PaymentStatus.processing:
        return AppConstants.purchaseStatusPending;
      case PaymentStatus.failed:
        return AppConstants.purchaseStatusFailed;
      case PaymentStatus.cancelled:
        return AppConstants.purchaseStatusFailed;
      case PaymentStatus.refunded:
        return AppConstants.purchaseStatusRefunded;
    }
  }
}
