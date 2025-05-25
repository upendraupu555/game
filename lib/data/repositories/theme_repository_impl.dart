import 'package:flutter/material.dart' as flutter;
import 'package:flutter/scheduler.dart';
import '../../domain/entities/theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../presentation/theme/colors.dart';
import '../datasources/theme_local_datasource.dart';
import '../models/theme_model.dart';



/// Implementation of theme repository
/// This is the data layer that implements the domain contract
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<ThemeEntity?> loadThemeSettings() async {
    try {
      final themeModel = await _localDataSource.getThemeSettings();
      return themeModel?.toDomain();
    } catch (e) {
      // Log error in production
      return null;
    }
  }

  @override
  Future<void> saveThemeSettings(ThemeEntity themeEntity) async {
    try {
      final themeModel = ThemeModel.fromDomain(themeEntity);
      await _localDataSource.saveThemeSettings(themeModel);
    } catch (e) {
      // Log error in production
      throw Exception('Failed to save theme settings: $e');
    }
  }

  @override
  Future<void> resetThemeSettings() async {
    try {
      await _localDataSource.clearThemeSettings();
    } catch (e) {
      // Log error in production
      throw Exception('Failed to reset theme settings: $e');
    }
  }

  @override
  ThemeEntity getDefaultThemeSettings() {
    return ThemeEntity(
      themeMode: ThemeModeEntity.system,
      lightPrimaryColor: ColorEntity(
        value: AppColors.defaultLightPrimary.value,
        name: AppColors.getColorName(AppColors.defaultLightPrimary),
      ),
      darkPrimaryColor: ColorEntity(
        value: AppColors.defaultDarkPrimary.value,
        name: AppColors.getColorName(AppColors.defaultDarkPrimary),
      ),
    );
  }

  @override
  List<ColorEntity> getAvailableColors() {
    return AppColors.primaryColorOptions.map((color) {
      return ColorEntity(
        value: color.value,
        name: AppColors.getColorName(color),
      );
    }).toList();
  }

  @override
  Brightness getCurrentPlatformBrightness() {
    final platformBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return platformBrightness == flutter.Brightness.dark
        ? Brightness.dark
        : Brightness.light;
  }
}


