/// Domain entity representing a navigation route
/// Following clean architecture principles - this is pure business logic
class NavigationEntity {
  final String path;
  final String name;
  final Map<String, dynamic>? arguments;
  final bool isModal;
  final bool clearStack;

  const NavigationEntity({
    required this.path,
    required this.name,
    this.arguments,
    this.isModal = false,
    this.clearStack = false,
  });

  NavigationEntity copyWith({
    String? path,
    String? name,
    Map<String, dynamic>? arguments,
    bool? isModal,
    bool? clearStack,
  }) {
    return NavigationEntity(
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
    return other is NavigationEntity &&
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
    return 'NavigationEntity(path: $path, name: $name, arguments: $arguments, isModal: $isModal, clearStack: $clearStack)';
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

/// Navigation result entity for handling navigation results
class NavigationResultEntity<T> {
  final T? data;
  final bool isSuccess;
  final String? error;

  const NavigationResultEntity({
    this.data,
    required this.isSuccess,
    this.error,
  });

  NavigationResultEntity.success(T? data)
      : data = data,
        isSuccess = true,
        error = null;

  NavigationResultEntity.failure(String error)
      : data = null,
        isSuccess = false,
        error = error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationResultEntity<T> &&
        other.data == data &&
        other.isSuccess == isSuccess &&
        other.error == error;
  }

  @override
  int get hashCode {
    return data.hashCode ^ isSuccess.hashCode ^ (error?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'NavigationResultEntity(data: $data, isSuccess: $isSuccess, error: $error)';
  }
}
