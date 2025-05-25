import '../../core/constants/app_constants.dart';
import '../../domain/entities/font_entity.dart';

/// Data model for font settings with JSON serialization
/// This is the data layer representation that handles persistence
class FontModel {
  final String fontFamily;
  final String displayName;

  const FontModel({
    required this.fontFamily,
    required this.displayName,
  });

  /// Convert to domain entity
  FontEntity toDomain() {
    return FontEntity(
      fontFamily: fontFamily,
      displayName: displayName,
    );
  }

  /// Create from domain entity
  factory FontModel.fromDomain(FontEntity entity) {
    return FontModel(
      fontFamily: entity.fontFamily,
      displayName: entity.displayName,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'displayName': displayName,
    };
  }

  /// Create from JSON
  factory FontModel.fromJson(Map<String, dynamic> json) {
    return FontModel(
      fontFamily: json['fontFamily'] ?? AppConstants.defaultFontFamily,
      displayName: json['displayName'] ?? AppConstants.fontNameBubblegumSans,
    );
  }

  /// Get default font model
  factory FontModel.defaultFont() {
    return const FontModel(
      fontFamily: AppConstants.defaultFontFamily,
      displayName: AppConstants.fontNameBubblegumSans,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FontModel &&
        other.fontFamily == fontFamily &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return fontFamily.hashCode ^ displayName.hashCode;
  }

  @override
  String toString() {
    return 'FontModel(fontFamily: $fontFamily, displayName: $displayName)';
  }
}
