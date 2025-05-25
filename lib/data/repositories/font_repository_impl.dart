import '../../core/constants/app_constants.dart';
import '../../domain/entities/font_entity.dart';
import '../../domain/repositories/font_repository.dart';
import '../datasources/font_local_datasource.dart';
import '../models/font_model.dart';

/// Implementation of font repository
/// This is the data layer that implements the domain contract
class FontRepositoryImpl implements FontRepository {
  final FontLocalDataSource _localDataSource;

  FontRepositoryImpl(this._localDataSource);

  @override
  Future<FontEntity?> loadFontSettings() async {
    try {
      final fontModel = await _localDataSource.getFontSettings();
      return fontModel?.toDomain();
    } catch (e) {
      // Log error in production
      return null;
    }
  }

  @override
  Future<void> saveFontSettings(FontEntity fontEntity) async {
    try {
      final fontModel = FontModel.fromDomain(fontEntity);
      await _localDataSource.saveFontSettings(fontModel);
    } catch (e) {
      // Log error in production
      throw Exception('Failed to save font settings: $e');
    }
  }

  @override
  Future<void> resetFontSettings() async {
    try {
      await _localDataSource.clearFontSettings();
    } catch (e) {
      // Log error in production
      throw Exception('Failed to reset font settings: $e');
    }
  }

  @override
  FontEntity getDefaultFontSettings() {
    return const FontEntity(
      fontFamily: AppConstants.defaultFontFamily,
      displayName: AppConstants.fontNameBubblegumSans,
    );
  }

  @override
  List<FontEntity> getAvailableFonts() {
    return const [
      FontEntity(
        fontFamily: AppConstants.fontFamilyBubblegumSans,
        displayName: AppConstants.fontNameBubblegumSans,
      ),
      FontEntity(
        fontFamily: AppConstants.fontFamilyChewy,
        displayName: AppConstants.fontNameChewy,
      ),
      FontEntity(
        fontFamily: AppConstants.fontFamilyComicNeue,
        displayName: AppConstants.fontNameComicNeue,
      ),
    ];
  }
}
