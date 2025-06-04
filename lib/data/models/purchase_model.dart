import 'dart:convert';
import '../../domain/entities/purchase_entity.dart';

/// Data model for purchase serialization/deserialization
/// Following clean architecture - data layer model
class PurchaseModel {
  final String id;
  final String userId;
  final String productType;
  final String status;
  final String transactionId;
  final int amount;
  final String currency;
  final String? purchasedAt;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? metadata;

  const PurchaseModel({
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

  /// Convert from domain entity
  factory PurchaseModel.fromEntity(PurchaseEntity entity) {
    return PurchaseModel(
      id: entity.id,
      userId: entity.userId,
      productType: entity.productType,
      status: entity.status.toString(),
      transactionId: entity.transactionId,
      amount: entity.amount,
      currency: entity.currency,
      purchasedAt: entity.purchasedAt?.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      metadata: entity.metadata,
    );
  }

  /// Convert to domain entity
  PurchaseEntity toEntity() {
    return PurchaseEntity(
      id: id,
      userId: userId,
      productType: productType,
      status: PurchaseStatus.fromString(status),
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      purchasedAt: purchasedAt != null ? DateTime.parse(purchasedAt!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      metadata: metadata,
    );
  }

  /// Convert from JSON (Supabase response)
  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      amount: json['amount'] as int? ?? 0,
      currency: json['currency']?.toString() ?? '',
      purchasedAt: json['purchased_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_type': productType,
      'status': status,
      'transaction_id': transactionId,
      'amount': amount,
      'currency': currency,
      'purchased_at': purchasedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'metadata': metadata,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory PurchaseModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PurchaseModel.fromJson(json);
  }

  /// Copy with updated fields
  PurchaseModel copyWith({
    String? id,
    String? userId,
    String? productType,
    String? status,
    String? transactionId,
    int? amount,
    String? currency,
    String? purchasedAt,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PurchaseModel(
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
    return other is PurchaseModel &&
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
    return 'PurchaseModel('
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
