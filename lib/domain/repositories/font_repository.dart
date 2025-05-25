import '../entities/font_entity.dart';

/// Abstract repository interface for font persistence
/// Following clean architecture - domain layer defines the contract
abstract class FontRepository {
  /// Load font settings from persistent storage
  Future<FontEntity?> loadFontSettings();

  /// Save font settings to persistent storage
  Future<void> saveFontSettings(FontEntity fontEntity);

  /// Reset font settings to default values
  Future<void> resetFontSettings();

  /// Get default font settings
  FontEntity getDefaultFontSettings();

  /// Get available font options
  List<FontEntity> getAvailableFonts();
}
