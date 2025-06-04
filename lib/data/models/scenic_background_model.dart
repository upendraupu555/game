import 'dart:convert';
import '../../domain/entities/scenic_background_entity.dart';
import '../../domain/repositories/scenic_background_repository.dart';

/// Data model for scenic background with JSON serialization
/// This is the data layer representation that handles persistence
class ScenicBackgroundModel {
  final int index;
  final String assetPath;
  final String name;
  final bool isLoaded;
  final DateTime? lastUsed;

  const ScenicBackgroundModel({
    required this.index,
    required this.assetPath,
    required this.name,
    this.isLoaded = false,
    this.lastUsed,
  });

  /// Convert to domain entity
  ScenicBackgroundEntity toDomain() {
    return ScenicBackgroundEntity(
      index: index,
      assetPath: assetPath,
      name: name,
      isLoaded: isLoaded,
      lastUsed: lastUsed,
    );
  }

  /// Create from domain entity
  factory ScenicBackgroundModel.fromDomain(ScenicBackgroundEntity entity) {
    return ScenicBackgroundModel(
      index: entity.index,
      assetPath: entity.assetPath,
      name: entity.name,
      isLoaded: entity.isLoaded,
      lastUsed: entity.lastUsed,
    );
  }

  /// Create from JSON
  factory ScenicBackgroundModel.fromJson(Map<String, dynamic> json) {
    return ScenicBackgroundModel(
      index: json['index'] as int,
      assetPath: json['assetPath'] as String,
      name: json['name'] as String,
      isLoaded: json['isLoaded'] as bool? ?? false,
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'assetPath': assetPath,
      'name': name,
      'isLoaded': isLoaded,
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  ScenicBackgroundModel copyWith({
    int? index,
    String? assetPath,
    String? name,
    bool? isLoaded,
    DateTime? lastUsed,
  }) {
    return ScenicBackgroundModel(
      index: index ?? this.index,
      assetPath: assetPath ?? this.assetPath,
      name: name ?? this.name,
      isLoaded: isLoaded ?? this.isLoaded,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScenicBackgroundModel &&
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
    return 'ScenicBackgroundModel(index: $index, name: $name, isLoaded: $isLoaded)';
  }
}

/// Data model for scenic mode settings with JSON serialization
class ScenicModeSettingsModel {
  final bool isEnabled;
  final double backgroundOpacity;
  final double backgroundBlur;
  final bool autoChangeBackground;
  final Duration autoChangeInterval;
  final List<int> favoriteBackgrounds;

  const ScenicModeSettingsModel({
    this.isEnabled = true,
    this.backgroundOpacity = 0.3,
    this.backgroundBlur = 2.0,
    this.autoChangeBackground = false,
    this.autoChangeInterval = const Duration(minutes: 5),
    this.favoriteBackgrounds = const [],
  });

  /// Convert to domain entity
  ScenicModeSettings toDomain() {
    return ScenicModeSettings(
      isEnabled: isEnabled,
      backgroundOpacity: backgroundOpacity,
      backgroundBlur: backgroundBlur,
      autoChangeBackground: autoChangeBackground,
      autoChangeInterval: autoChangeInterval,
      favoriteBackgrounds: favoriteBackgrounds,
    );
  }

  /// Create from domain entity
  factory ScenicModeSettingsModel.fromDomain(ScenicModeSettings entity) {
    return ScenicModeSettingsModel(
      isEnabled: entity.isEnabled,
      backgroundOpacity: entity.backgroundOpacity,
      backgroundBlur: entity.backgroundBlur,
      autoChangeBackground: entity.autoChangeBackground,
      autoChangeInterval: entity.autoChangeInterval,
      favoriteBackgrounds: entity.favoriteBackgrounds,
    );
  }

  /// Create from JSON
  factory ScenicModeSettingsModel.fromJson(Map<String, dynamic> json) {
    return ScenicModeSettingsModel(
      isEnabled: json['isEnabled'] as bool? ?? true,
      backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble() ?? 0.3,
      backgroundBlur: (json['backgroundBlur'] as num?)?.toDouble() ?? 2.0,
      autoChangeBackground: json['autoChangeBackground'] as bool? ?? false,
      autoChangeInterval: Duration(
        milliseconds: json['autoChangeIntervalMs'] as int? ?? 300000,
      ),
      favoriteBackgrounds: (json['favoriteBackgrounds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'backgroundOpacity': backgroundOpacity,
      'backgroundBlur': backgroundBlur,
      'autoChangeBackground': autoChangeBackground,
      'autoChangeIntervalMs': autoChangeInterval.inMilliseconds,
      'favoriteBackgrounds': favoriteBackgrounds,
    };
  }

  ScenicModeSettingsModel copyWith({
    bool? isEnabled,
    double? backgroundOpacity,
    double? backgroundBlur,
    bool? autoChangeBackground,
    Duration? autoChangeInterval,
    List<int>? favoriteBackgrounds,
  }) {
    return ScenicModeSettingsModel(
      isEnabled: isEnabled ?? this.isEnabled,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      autoChangeBackground: autoChangeBackground ?? this.autoChangeBackground,
      autoChangeInterval: autoChangeInterval ?? this.autoChangeInterval,
      favoriteBackgrounds: favoriteBackgrounds ?? this.favoriteBackgrounds,
    );
  }

  @override
  String toString() {
    return 'ScenicModeSettingsModel(isEnabled: $isEnabled, opacity: $backgroundOpacity, blur: $backgroundBlur)';
  }
}
