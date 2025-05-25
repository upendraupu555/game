import '../entities/font_entity.dart';
import '../repositories/font_repository.dart';

/// Use case for getting current font settings
class GetFontSettingsUseCase {
  final FontRepository _repository;

  GetFontSettingsUseCase(this._repository);

  Future<FontEntity> execute() async {
    final savedFont = await _repository.loadFontSettings();
    return savedFont ?? _repository.getDefaultFontSettings();
  }
}

/// Use case for updating font family
class UpdateFontFamilyUseCase {
  final FontRepository _repository;

  UpdateFontFamilyUseCase(this._repository);

  Future<FontEntity> execute(FontEntity newFont) async {
    await _repository.saveFontSettings(newFont);
    return newFont;
  }
}

/// Use case for resetting font to default
class ResetFontUseCase {
  final FontRepository _repository;

  ResetFontUseCase(this._repository);

  Future<FontEntity> execute() async {
    await _repository.resetFontSettings();
    return _repository.getDefaultFontSettings();
  }
}

/// Use case for getting available font options
class GetAvailableFontsUseCase {
  final FontRepository _repository;

  GetAvailableFontsUseCase(this._repository);

  List<FontEntity> execute() {
    return _repository.getAvailableFonts();
  }
}
