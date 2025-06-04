import 'dart:convert';
import '../../domain/entities/powerup_entity.dart';

/// Data model for powerup persistence
/// Following clean architecture principles - this handles data serialization
class PowerupModel {
  final String type;
  final int movesRemaining;
  final bool isActive;
  final bool isUsed;
  final String? activatedAt;
  final String id;

  const PowerupModel({
    required this.type,
    required this.movesRemaining,
    required this.isActive,
    required this.isUsed,
    required this.id,
    this.activatedAt,
  });

  /// Convert from domain entity
  factory PowerupModel.fromEntity(PowerupEntity entity) {
    return PowerupModel(
      type: entity.type.name,
      movesRemaining: entity.movesRemaining,
      isActive: entity.isActive,
      isUsed: entity.isUsed,
      id: entity.id,
      activatedAt: entity.activatedAt?.toIso8601String(),
    );
  }

  /// Convert to domain entity
  PowerupEntity toEntity() {
    return PowerupEntity(
      type: PowerupType.values.firstWhere((t) => t.name == type),
      movesRemaining: movesRemaining,
      isActive: isActive,
      isUsed: isUsed,
      id: id,
      activatedAt: activatedAt != null ? DateTime.parse(activatedAt!) : null,
    );
  }

  /// Convert from JSON
  factory PowerupModel.fromJson(Map<String, dynamic> json) {
    return PowerupModel(
      type: json['type'] as String,
      movesRemaining: json['movesRemaining'] as int,
      isActive: json['isActive'] as bool,
      isUsed: json['isUsed'] as bool,
      id: json['id'] as String,
      activatedAt: json['activatedAt'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'movesRemaining': movesRemaining,
      'isActive': isActive,
      'isUsed': isUsed,
      'id': id,
      'activatedAt': activatedAt,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory PowerupModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PowerupModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerupModel &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          movesRemaining == other.movesRemaining &&
          isActive == other.isActive &&
          isUsed == other.isUsed &&
          id == other.id &&
          activatedAt == other.activatedAt;

  @override
  int get hashCode =>
      type.hashCode ^
      movesRemaining.hashCode ^
      isActive.hashCode ^
      isUsed.hashCode ^
      id.hashCode ^
      activatedAt.hashCode;

  @override
  String toString() {
    return 'PowerupModel{type: $type, movesRemaining: $movesRemaining, isActive: $isActive, isUsed: $isUsed, id: $id}';
  }
}
