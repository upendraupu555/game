import 'dart:convert';
import '../../domain/entities/payment_entity.dart';

/// Data model for payment serialization/deserialization
/// Following clean architecture - data layer model
class PaymentModel {
  final String transactionId;
  final String orderId;
  final int amount;
  final String currency;
  final String productName;
  final String description;
  final String status;
  final String createdAt;
  final String? completedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  const PaymentModel({
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

  /// Convert from domain entity
  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      transactionId: entity.transactionId,
      orderId: entity.orderId,
      amount: entity.amount,
      currency: entity.currency,
      productName: entity.productName,
      description: entity.description,
      status: entity.status.toString(),
      createdAt: entity.createdAt.toIso8601String(),
      completedAt: entity.completedAt?.toIso8601String(),
      failureReason: entity.failureReason,
      metadata: entity.metadata,
    );
  }

  /// Convert to domain entity
  PaymentEntity toEntity() {
    return PaymentEntity(
      transactionId: transactionId,
      orderId: orderId,
      amount: amount,
      currency: currency,
      productName: productName,
      description: description,
      status: PaymentStatus.fromString(status),
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      failureReason: failureReason,
      metadata: metadata,
    );
  }

  /// Convert from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      transactionId: json['transactionId'] as String,
      orderId: json['orderId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      productName: json['productName'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      failureReason: json['failureReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'productName': productName,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory PaymentModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PaymentModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel &&
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
    return 'PaymentModel('
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

/// Data model for purchase status serialization/deserialization
class PurchaseStatusModel {
  final bool isAdRemovalPurchased;
  final String? purchaseDate;
  final String? transactionId;
  final String? orderId;

  const PurchaseStatusModel({
    required this.isAdRemovalPurchased,
    this.purchaseDate,
    this.transactionId,
    this.orderId,
  });

  /// Convert from domain entity
  factory PurchaseStatusModel.fromEntity(PurchaseStatusEntity entity) {
    return PurchaseStatusModel(
      isAdRemovalPurchased: entity.isAdRemovalPurchased,
      purchaseDate: entity.purchaseDate?.toIso8601String(),
      transactionId: entity.transactionId,
      orderId: entity.orderId,
    );
  }

  /// Convert to domain entity
  PurchaseStatusEntity toEntity() {
    return PurchaseStatusEntity(
      isAdRemovalPurchased: isAdRemovalPurchased,
      purchaseDate: purchaseDate != null ? DateTime.parse(purchaseDate!) : null,
      transactionId: transactionId,
      orderId: orderId,
    );
  }

  /// Convert from JSON
  factory PurchaseStatusModel.fromJson(Map<String, dynamic> json) {
    return PurchaseStatusModel(
      isAdRemovalPurchased: json['isAdRemovalPurchased'] as bool,
      purchaseDate: json['purchaseDate'] as String?,
      transactionId: json['transactionId'] as String?,
      orderId: json['orderId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isAdRemovalPurchased': isAdRemovalPurchased,
      'purchaseDate': purchaseDate,
      'transactionId': transactionId,
      'orderId': orderId,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory PurchaseStatusModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PurchaseStatusModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseStatusModel &&
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
    return 'PurchaseStatusModel('
        'isAdRemovalPurchased: $isAdRemovalPurchased, '
        'purchaseDate: $purchaseDate, '
        'transactionId: $transactionId, '
        'orderId: $orderId'
        ')';
  }
}
