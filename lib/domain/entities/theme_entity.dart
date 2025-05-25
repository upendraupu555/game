import 'package:flutter/material.dart';

/// Domain entity representing theme configuration
/// Following clean architecture principles - this is pure business logic
class ThemeEntity {
  final ThemeModeEntity themeMode;
  final ColorEntity lightPrimaryColor;
  final ColorEntity darkPrimaryColor;

  const ThemeEntity({
    required this.themeMode,
    required this.lightPrimaryColor,
    required this.darkPrimaryColor,
  });

  ThemeEntity copyWith({
    ThemeModeEntity? themeMode,
    ColorEntity? lightPrimaryColor,
    ColorEntity? darkPrimaryColor,
  }) {
    return ThemeEntity(
      themeMode: themeMode ?? this.themeMode,
      lightPrimaryColor: lightPrimaryColor ?? this.lightPrimaryColor,
      darkPrimaryColor: darkPrimaryColor ?? this.darkPrimaryColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeEntity &&
        other.themeMode == themeMode &&
        other.lightPrimaryColor == lightPrimaryColor &&
        other.darkPrimaryColor == darkPrimaryColor;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        lightPrimaryColor.hashCode ^
        darkPrimaryColor.hashCode;
  }

  @override
  String toString() {
    return 'ThemeEntity(themeMode: $themeMode, lightPrimaryColor: $lightPrimaryColor, darkPrimaryColor: $darkPrimaryColor)';
  }
}

/// Domain entity for theme mode
enum ThemeModeEntity {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case ThemeModeEntity.light:
        return 'Light';
      case ThemeModeEntity.dark:
        return 'Dark';
      case ThemeModeEntity.system:
        return 'System';
    }
  }
}

/// Domain entity for color representation
class ColorEntity {
  final int value;
  final String name;

  const ColorEntity({
    required this.value,
    required this.name,
  });

  /// Convert to Flutter Color
  Color toFlutterColor() => Color(value);

  /// Create from Flutter Color with name lookup
  factory ColorEntity.fromFlutterColor(Color color, String? name) {
    return ColorEntity(
      value: color.value,
      name: name ?? 'Custom Color',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorEntity &&
        other.value == value &&
        other.name == name;
  }

  @override
  int get hashCode => value.hashCode ^ name.hashCode;

  @override
  String toString() => 'ColorEntity(value: $value, name: $name)';
}
