import '../../domain/entities/navigation_entity.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../datasources/navigation_datasource.dart';
import '../models/navigation_model.dart';

/// Implementation of navigation repository
/// This is the data layer that implements the domain contract
class NavigationRepositoryImpl implements NavigationRepository {
  final NavigationDataSource _dataSource;

  NavigationRepositoryImpl(this._dataSource);

  @override
  Future<NavigationResultEntity> navigateTo(NavigationEntity navigation) async {
    try {
      final navigationModel = NavigationModel.fromDomain(navigation);
      final success = await _dataSource.navigateTo(navigationModel);

      if (success) {
        return NavigationResultEntity.success(navigation);
      } else {
        return NavigationResultEntity.failure('Failed to navigate to ${navigation.path}');
      }
    } catch (e) {
      return NavigationResultEntity.failure('Navigation error: $e');
    }
  }

  @override
  Future<NavigationResultEntity> navigateBack({dynamic result}) async {
    try {
      final success = await _dataSource.navigateBack(result: result);

      if (success) {
        return NavigationResultEntity.success(result);
      } else {
        return NavigationResultEntity.failure('Failed to navigate back');
      }
    } catch (e) {
      return NavigationResultEntity.failure('Navigate back error: $e');
    }
  }

  @override
  Future<NavigationResultEntity> navigateAndReplace(NavigationEntity navigation) async {
    try {
      final navigationModel = NavigationModel.fromDomain(navigation);
      final success = await _dataSource.navigateAndReplace(navigationModel);

      if (success) {
        return NavigationResultEntity.success(navigation);
      } else {
        return NavigationResultEntity.failure('Failed to navigate and replace to ${navigation.path}');
      }
    } catch (e) {
      return NavigationResultEntity.failure('Navigate and replace error: $e');
    }
  }

  @override
  Future<NavigationResultEntity> navigateAndClearStack(NavigationEntity navigation) async {
    try {
      final navigationModel = NavigationModel.fromDomain(navigation);
      final success = await _dataSource.navigateAndClearStack(navigationModel);

      if (success) {
        return NavigationResultEntity.success(navigation);
      } else {
        return NavigationResultEntity.failure('Failed to navigate and clear stack to ${navigation.path}');
      }
    } catch (e) {
      return NavigationResultEntity.failure('Navigate and clear stack error: $e');
    }
  }

  @override
  Future<NavigationResultEntity> popUntil(String routePath) async {
    try {
      final success = await _dataSource.popUntil(routePath);

      if (success) {
        return NavigationResultEntity.success(routePath);
      } else {
        return NavigationResultEntity.failure('Failed to pop until $routePath');
      }
    } catch (e) {
      return NavigationResultEntity.failure('Pop until error: $e');
    }
  }

  @override
  bool canNavigateBack() {
    try {
      return _dataSource.canNavigateBack();
    } catch (e) {
      return false;
    }
  }

  @override
  NavigationEntity? getCurrentRoute() {
    try {
      final currentModel = _dataSource.getCurrentRoute();
      return currentModel?.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  List<NavigationEntity> getNavigationHistory() {
    try {
      final historyModels = _dataSource.getNavigationHistory();
      return historyModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  void clearNavigationHistory() {
    try {
      _dataSource.clearNavigationHistory();
    } catch (e) {
      // Log error in production
    }
  }

  @override
  Future<NavigationResultEntity<T>> showModal<T>(NavigationEntity navigation) async {
    try {
      final navigationModel = NavigationModel.fromDomain(navigation);
      final result = await _dataSource.showModal<T>(navigationModel);

      return NavigationResultEntity<T>.success(result);
    } catch (e) {
      return NavigationResultEntity<T>.failure('Show modal error: $e');
    }
  }

  @override
  Future<NavigationResultEntity> dismissModal({dynamic result}) async {
    try {
      final success = await _dataSource.dismissModal(result: result);

      if (success) {
        return NavigationResultEntity.success(result);
      } else {
        return NavigationResultEntity.failure('Failed to dismiss modal');
      }
    } catch (e) {
      return NavigationResultEntity.failure('Dismiss modal error: $e');
    }
  }
}
