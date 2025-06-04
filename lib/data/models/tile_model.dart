import 'dart:convert';
import '../../domain/entities/tile_entity.dart';

/// Data model for tile serialization/deserialization
/// Following clean architecture - data layer model
class TileModel {
  final int value;
  final int row;
  final int col;
  final String id;
  final bool isNew;
  final bool isMerged;
  final bool isBlocker;

  const TileModel({
    required this.value,
    required this.row,
    required this.col,
    required this.id,
    required this.isNew,
    required this.isMerged,
    required this.isBlocker,
  });

  /// Convert from domain entity
  factory TileModel.fromEntity(TileEntity entity) {
    return TileModel(
      value: entity.value,
      row: entity.row,
      col: entity.col,
      id: entity.id,
      isNew: entity.isNew,
      isMerged: entity.isMerged,
      isBlocker: entity.isBlocker,
    );
  }

  /// Convert to domain entity
  TileEntity toEntity() {
    return TileEntity(
      value: value,
      row: row,
      col: col,
      id: id,
      isNew: isNew,
      isMerged: isMerged,
      isBlocker: isBlocker,
    );
  }

  /// Convert from JSON
  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(
      value: json['value'] as int,
      row: json['row'] as int,
      col: json['col'] as int,
      id: json['id'] as String,
      isNew: json['isNew'] as bool? ?? false,
      isMerged: json['isMerged'] as bool? ?? false,
      isBlocker: json['isBlocker'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'row': row,
      'col': col,
      'id': id,
      'isNew': isNew,
      'isMerged': isMerged,
      'isBlocker': isBlocker,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert from JSON string
  factory TileModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return TileModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileModel &&
        other.value == value &&
        other.row == row &&
        other.col == col &&
        other.id == id &&
        other.isNew == isNew &&
        other.isMerged == isMerged;
  }

  @override
  int get hashCode {
    return Object.hash(value, row, col, id, isNew, isMerged);
  }

  @override
  String toString() {
    return 'TileModel(value: $value, position: ($row, $col), id: $id, isNew: $isNew, isMerged: $isMerged)';
  }
}
