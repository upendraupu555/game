import 'dart:convert';
import '../../domain/entities/navigation_entity.dart';

/// Data model for navigation with JSON serialization
/// This is the data layer representation that handles persistence and routing
class NavigationModel {
  final String path;
  final String name;
  final Map<String, dynamic>? arguments;
  final bool isModal;
  final bool clearStack;

  const NavigationModel({
    required this.path,
    required this.name,
    this.arguments,
    this.isModal = false,
    this.clearStack = false,
  });

  /// Convert to domain entity
  NavigationEntity toDomain() {
    return NavigationEntity(
      path: path,
      name: name,
      arguments: arguments,
      isModal: isModal,
      clearStack: clearStack,
    );
  }

  /// Create from domain entity
  factory NavigationModel.fromDomain(NavigationEntity entity) {
    return NavigationModel(
      path: entity.path,
      name: entity.name,
      arguments: entity.arguments,
      isModal: entity.isModal,
      clearStack: entity.clearStack,
    );
  }

  /// Create from JSON string
  factory NavigationModel.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return NavigationModel.fromMap(json);
    } catch (e) {
      throw Exception('Failed to parse navigation JSON: $e');
    }
  }

  /// Create from Map
  factory NavigationModel.fromMap(Map<String, dynamic> map) {
    return NavigationModel(
      path: map['path'] ?? '/',
      name: map['name'] ?? 'unknown',
      arguments: map['arguments'] as Map<String, dynamic>?,
      isModal: map['isModal'] ?? false,
      clearStack: map['clearStack'] ?? false,
    );
  }

  /// Convert to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'name': name,
      'arguments': arguments,
      'isModal': isModal,
      'clearStack': clearStack,
    };
  }

  NavigationModel copyWith({
    String? path,
    String? name,
    Map<String, dynamic>? arguments,
    bool? isModal,
    bool? clearStack,
  }) {
    return NavigationModel(
      path: path ?? this.path,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      isModal: isModal ?? this.isModal,
      clearStack: clearStack ?? this.clearStack,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationModel &&
        other.path == path &&
        other.name == name &&
        _mapEquals(other.arguments, arguments) &&
        other.isModal == isModal &&
        other.clearStack == clearStack;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        name.hashCode ^
        (arguments?.hashCode ?? 0) ^
        isModal.hashCode ^
        clearStack.hashCode;
  }

  @override
  String toString() {
    return 'NavigationModel(path: $path, name: $name, arguments: $arguments, isModal: $isModal, clearStack: $clearStack)';
  }

  /// Deep equality check for maps
  bool _mapEquals(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}
