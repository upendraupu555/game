import '../entities/scenic_background_entity.dart';

/// Abstract repository interface for scenic background operations
/// Following clean architecture principles - domain layer defines the contract
abstract class ScenicBackgroundRepository {
  /// Get all available scenic backgrounds
  Future<List<ScenicBackgroundEntity>> getAllBackgrounds();

  /// Get a random scenic background
  Future<ScenicBackgroundEntity> getRandomBackground();

  /// Get a specific background by index
  Future<ScenicBackgroundEntity?> getBackgroundByIndex(int index);

  /// Preload background images for better performance
  Future<void> preloadBackgrounds(List<int> indices);

  /// Save the current background index
  Future<void> saveCurrentBackgroundIndex(int index);

  /// Load the saved background index
  Future<int?> loadCurrentBackgroundIndex();

  /// Clear cached backgrounds
  Future<void> clearCache();

  /// Check if a background is cached/loaded
  Future<bool> isBackgroundLoaded(int index);

  /// Get scenic mode settings
  Future<ScenicModeSettings> getScenicModeSettings();

  /// Save scenic mode settings
  Future<void> saveScenicModeSettings(ScenicModeSettings settings);
}

/// Settings for scenic mode
class ScenicModeSettings {
  final bool isEnabled;
  final double backgroundOpacity;
  final double backgroundBlur;
  final bool autoChangeBackground;
  final Duration autoChangeInterval;
  final List<int> favoriteBackgrounds;

  const ScenicModeSettings({
    this.isEnabled = true,
    this.backgroundOpacity = 0.3,
    this.backgroundBlur = 2.0,
    this.autoChangeBackground = false,
    this.autoChangeInterval = const Duration(minutes: 5),
    this.favoriteBackgrounds = const [],
  });

  ScenicModeSettings copyWith({
    bool? isEnabled,
    double? backgroundOpacity,
    double? backgroundBlur,
    bool? autoChangeBackground,
    Duration? autoChangeInterval,
    List<int>? favoriteBackgrounds,
  }) {
    return ScenicModeSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      autoChangeBackground: autoChangeBackground ?? this.autoChangeBackground,
      autoChangeInterval: autoChangeInterval ?? this.autoChangeInterval,
      favoriteBackgrounds: favoriteBackgrounds ?? this.favoriteBackgrounds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScenicModeSettings &&
        other.isEnabled == isEnabled &&
        other.backgroundOpacity == backgroundOpacity &&
        other.backgroundBlur == backgroundBlur &&
        other.autoChangeBackground == autoChangeBackground &&
        other.autoChangeInterval == autoChangeInterval &&
        _listEquals(other.favoriteBackgrounds, favoriteBackgrounds);
  }

  bool _listEquals(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      isEnabled,
      backgroundOpacity,
      backgroundBlur,
      autoChangeBackground,
      autoChangeInterval,
      favoriteBackgrounds.length,
    );
  }

  @override
  String toString() {
    return 'ScenicModeSettings(isEnabled: $isEnabled, opacity: $backgroundOpacity, blur: $backgroundBlur)';
  }
}
