import 'dart:convert';
import '../../domain/entities/sound_entity.dart';
import '../../core/constants/app_constants.dart';

/// Data model for sound settings with JSON serialization
/// This handles the conversion between domain entities and data storage
class SoundModel {
  final bool soundEnabled;
  final double masterVolume;
  final double uiVolume;
  final double gameVolume;
  final double powerupVolume;
  final double timerVolume;

  const SoundModel({
    required this.soundEnabled,
    required this.masterVolume,
    required this.uiVolume,
    required this.gameVolume,
    required this.powerupVolume,
    required this.timerVolume,
  });

  /// Create SoundModel from domain entity
  factory SoundModel.fromDomain(SoundEntity entity) {
    return SoundModel(
      soundEnabled: entity.soundEnabled,
      masterVolume: entity.masterVolume,
      uiVolume: entity.uiVolume,
      gameVolume: entity.gameVolume,
      powerupVolume: entity.powerupVolume,
      timerVolume: entity.timerVolume,
    );
  }

  /// Convert to domain entity
  SoundEntity toDomain() {
    return SoundEntity(
      soundEnabled: soundEnabled,
      masterVolume: masterVolume,
      uiVolume: uiVolume,
      gameVolume: gameVolume,
      powerupVolume: powerupVolume,
      timerVolume: timerVolume,
    );
  }

  /// Create from JSON map
  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      soundEnabled: json['soundEnabled'] as bool? ?? AppConstants.defaultSoundEnabled,
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? AppConstants.defaultMasterVolume,
      uiVolume: (json['uiVolume'] as num?)?.toDouble() ?? AppConstants.defaultUIVolume,
      gameVolume: (json['gameVolume'] as num?)?.toDouble() ?? AppConstants.defaultGameVolume,
      powerupVolume: (json['powerupVolume'] as num?)?.toDouble() ?? AppConstants.defaultPowerupVolume,
      timerVolume: (json['timerVolume'] as num?)?.toDouble() ?? AppConstants.defaultTimerVolume,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'masterVolume': masterVolume,
      'uiVolume': uiVolume,
      'gameVolume': gameVolume,
      'powerupVolume': powerupVolume,
      'timerVolume': timerVolume,
    };
  }

  /// Create from JSON string
  factory SoundModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SoundModel.fromJson(json);
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create default sound model
  factory SoundModel.defaultSettings() {
    return const SoundModel(
      soundEnabled: AppConstants.defaultSoundEnabled,
      masterVolume: AppConstants.defaultMasterVolume,
      uiVolume: AppConstants.defaultUIVolume,
      gameVolume: AppConstants.defaultGameVolume,
      powerupVolume: AppConstants.defaultPowerupVolume,
      timerVolume: AppConstants.defaultTimerVolume,
    );
  }

  /// Create a copy with updated values
  SoundModel copyWith({
    bool? soundEnabled,
    double? masterVolume,
    double? uiVolume,
    double? gameVolume,
    double? powerupVolume,
    double? timerVolume,
  }) {
    return SoundModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      uiVolume: uiVolume ?? this.uiVolume,
      gameVolume: gameVolume ?? this.gameVolume,
      powerupVolume: powerupVolume ?? this.powerupVolume,
      timerVolume: timerVolume ?? this.timerVolume,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundModel &&
        other.soundEnabled == soundEnabled &&
        other.masterVolume == masterVolume &&
        other.uiVolume == uiVolume &&
        other.gameVolume == gameVolume &&
        other.powerupVolume == powerupVolume &&
        other.timerVolume == timerVolume;
  }

  @override
  int get hashCode {
    return Object.hash(
      soundEnabled,
      masterVolume,
      uiVolume,
      gameVolume,
      powerupVolume,
      timerVolume,
    );
  }

  @override
  String toString() {
    return 'SoundModel('
        'soundEnabled: $soundEnabled, '
        'masterVolume: $masterVolume, '
        'uiVolume: $uiVolume, '
        'gameVolume: $gameVolume, '
        'powerupVolume: $powerupVolume, '
        'timerVolume: $timerVolume'
        ')';
  }
}
