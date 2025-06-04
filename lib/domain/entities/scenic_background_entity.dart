/// Domain entity representing a scenic background
/// Following clean architecture principles - this is pure business logic
class ScenicBackgroundEntity {
  final int index;
  final String assetPath;
  final String name;
  final bool isLoaded;
  final DateTime? lastUsed;

  const ScenicBackgroundEntity({
    required this.index,
    required this.assetPath,
    required this.name,
    this.isLoaded = false,
    this.lastUsed,
  });

  /// Create a copy with updated values
  ScenicBackgroundEntity copyWith({
    int? index,
    String? assetPath,
    String? name,
    bool? isLoaded,
    DateTime? lastUsed,
  }) {
    return ScenicBackgroundEntity(
      index: index ?? this.index,
      assetPath: assetPath ?? this.assetPath,
      name: name ?? this.name,
      isLoaded: isLoaded ?? this.isLoaded,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  /// Mark as loaded
  ScenicBackgroundEntity markAsLoaded() {
    return copyWith(isLoaded: true);
  }

  /// Mark as used
  ScenicBackgroundEntity markAsUsed() {
    return copyWith(lastUsed: DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScenicBackgroundEntity &&
        other.index == index &&
        other.assetPath == assetPath &&
        other.name == name &&
        other.isLoaded == isLoaded &&
        other.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return Object.hash(
      index,
      assetPath,
      name,
      isLoaded,
      lastUsed,
    );
  }

  @override
  String toString() {
    return 'ScenicBackgroundEntity(index: $index, name: $name, isLoaded: $isLoaded)';
  }
}
