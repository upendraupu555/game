/// Payment entity representing a payment transaction
/// Following clean architecture - domain layer entity
class PaymentEntity {
  final String transactionId;
  final String orderId;
  final int amount; // Amount in paise
  final String currency;
  final String productName;
  final String description;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  const PaymentEntity({
    required this.transactionId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.productName,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.metadata,
  });

  /// Create a copy with updated fields
  PaymentEntity copyWith({
    String? transactionId,
    String? orderId,
    int? amount,
    String? currency,
    String? productName,
    String? description,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentEntity(
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentEntity &&
        other.transactionId == transactionId &&
        other.orderId == orderId &&
        other.amount == amount &&
        other.currency == currency &&
        other.productName == productName &&
        other.description == description &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.failureReason == failureReason;
  }

  @override
  int get hashCode {
    return Object.hash(
      transactionId,
      orderId,
      amount,
      currency,
      productName,
      description,
      status,
      createdAt,
      completedAt,
      failureReason,
    );
  }

  @override
  String toString() {
    return 'PaymentEntity('
        'transactionId: $transactionId, '
        'orderId: $orderId, '
        'amount: $amount, '
        'currency: $currency, '
        'productName: $productName, '
        'status: $status, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled,
  refunded;

  /// Convert from string representation
  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  /// Convert to string representation
  @override
  String toString() {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.success:
        return 'success';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.cancelled:
        return 'cancelled';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  /// Check if payment is completed (success or failed)
  bool get isCompleted {
    return this == PaymentStatus.success ||
        this == PaymentStatus.failed ||
        this == PaymentStatus.cancelled ||
        this == PaymentStatus.refunded;
  }

  /// Check if payment was successful
  bool get isSuccessful {
    return this == PaymentStatus.success;
  }

  /// Check if payment is in progress
  bool get isInProgress {
    return this == PaymentStatus.pending || this == PaymentStatus.processing;
  }
}

/// Purchase status entity for tracking ad removal purchase
class PurchaseStatusEntity {
  final bool isAdRemovalPurchased;
  final DateTime? purchaseDate;
  final String? transactionId;
  final String? orderId;

  const PurchaseStatusEntity({
    required this.isAdRemovalPurchased,
    this.purchaseDate,
    this.transactionId,
    this.orderId,
  });

  /// Create a copy with updated fields
  PurchaseStatusEntity copyWith({
    bool? isAdRemovalPurchased,
    DateTime? purchaseDate,
    String? transactionId,
    String? orderId,
  }) {
    return PurchaseStatusEntity(
      isAdRemovalPurchased: isAdRemovalPurchased ?? this.isAdRemovalPurchased,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseStatusEntity &&
        other.isAdRemovalPurchased == isAdRemovalPurchased &&
        other.purchaseDate == purchaseDate &&
        other.transactionId == transactionId &&
        other.orderId == orderId;
  }

  @override
  int get hashCode {
    return Object.hash(
      isAdRemovalPurchased,
      purchaseDate,
      transactionId,
      orderId,
    );
  }

  @override
  String toString() {
    return 'PurchaseStatusEntity('
        'isAdRemovalPurchased: $isAdRemovalPurchased, '
        'purchaseDate: $purchaseDate, '
        'transactionId: $transactionId, '
        'orderId: $orderId'
        ')';
  }
}
