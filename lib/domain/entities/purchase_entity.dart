/// Domain entity for user purchases
/// Following clean architecture - domain layer entity
class PurchaseEntity {
  final String id;
  final String userId;
  final String productType;
  final PurchaseStatus status;
  final String transactionId;
  final int amount;
  final String currency;
  final DateTime? purchasedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const PurchaseEntity({
    required this.id,
    required this.userId,
    required this.productType,
    required this.status,
    required this.transactionId,
    required this.amount,
    required this.currency,
    this.purchasedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create ad removal purchase
  factory PurchaseEntity.adRemoval({
    required String id,
    required String userId,
    required String transactionId,
    required int amount,
    required String currency,
    required PurchaseStatus status,
    DateTime? purchasedAt,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return PurchaseEntity(
      id: id,
      userId: userId,
      productType: 'ad_removal',
      status: status,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      purchasedAt: purchasedAt,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// Check if this is an ad removal purchase
  bool get isAdRemoval => productType == 'ad_removal';

  /// Check if purchase is completed
  bool get isCompleted => status == PurchaseStatus.completed;

  /// Check if purchase is active (completed and not refunded)
  bool get isActive => status == PurchaseStatus.completed;

  /// Copy with updated fields
  PurchaseEntity copyWith({
    String? id,
    String? userId,
    String? productType,
    PurchaseStatus? status,
    String? transactionId,
    int? amount,
    String? currency,
    DateTime? purchasedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PurchaseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productType: productType ?? this.productType,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseEntity &&
        other.id == id &&
        other.userId == userId &&
        other.productType == productType &&
        other.status == status &&
        other.transactionId == transactionId &&
        other.amount == amount &&
        other.currency == currency &&
        other.purchasedAt == purchasedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      productType,
      status,
      transactionId,
      amount,
      currency,
      purchasedAt,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'PurchaseEntity('
        'id: $id, '
        'userId: $userId, '
        'productType: $productType, '
        'status: $status, '
        'transactionId: $transactionId, '
        'amount: $amount, '
        'currency: $currency, '
        'purchasedAt: $purchasedAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}

/// Purchase status enumeration
enum PurchaseStatus {
  completed,
  pending,
  failed,
  refunded;

  /// Convert from string
  static PurchaseStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PurchaseStatus.completed;
      case 'pending':
        return PurchaseStatus.pending;
      case 'failed':
        return PurchaseStatus.failed;
      case 'refunded':
        return PurchaseStatus.refunded;
      default:
        return PurchaseStatus.failed;
    }
  }

  /// Convert to string
  @override
  String toString() {
    switch (this) {
      case PurchaseStatus.completed:
        return 'completed';
      case PurchaseStatus.pending:
        return 'pending';
      case PurchaseStatus.failed:
        return 'failed';
      case PurchaseStatus.refunded:
        return 'refunded';
    }
  }

  /// Check if status represents a successful purchase
  bool get isSuccessful => this == PurchaseStatus.completed;

  /// Check if status represents an active purchase
  bool get isActive => this == PurchaseStatus.completed;
}
