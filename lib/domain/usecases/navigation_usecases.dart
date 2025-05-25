import '../entities/navigation_entity.dart';
import '../repositories/navigation_repository.dart';

/// Use case for navigating to a specific screen
class NavigateToUseCase {
  final NavigationRepository _repository;

  NavigateToUseCase(this._repository);

  Future<NavigationResultEntity> execute(NavigationEntity navigation) async {
    try {
      return await _repository.navigateTo(navigation);
    } catch (e) {
      return NavigationResultEntity.failure('Navigation failed: $e');
    }
  }
}

/// Use case for navigating back
class NavigateBackUseCase {
  final NavigationRepository _repository;

  NavigateBackUseCase(this._repository);

  Future<NavigationResultEntity> execute({dynamic result}) async {
    try {
      if (!_repository.canNavigateBack()) {
        return NavigationResultEntity.failure('Cannot navigate back');
      }
      return await _repository.navigateBack(result: result);
    } catch (e) {
      return NavigationResultEntity.failure('Navigate back failed: $e');
    }
  }
}

/// Use case for replacing current route
class NavigateAndReplaceUseCase {
  final NavigationRepository _repository;

  NavigateAndReplaceUseCase(this._repository);

  Future<NavigationResultEntity> execute(NavigationEntity navigation) async {
    try {
      return await _repository.navigateAndReplace(navigation);
    } catch (e) {
      return NavigationResultEntity.failure('Navigate and replace failed: $e');
    }
  }
}

/// Use case for clearing navigation stack
class NavigateAndClearStackUseCase {
  final NavigationRepository _repository;

  NavigateAndClearStackUseCase(this._repository);

  Future<NavigationResultEntity> execute(NavigationEntity navigation) async {
    try {
      return await _repository.navigateAndClearStack(navigation);
    } catch (e) {
      return NavigationResultEntity.failure('Navigate and clear stack failed: $e');
    }
  }
}

/// Use case for showing modals
class ShowModalUseCase {
  final NavigationRepository _repository;

  ShowModalUseCase(this._repository);

  Future<NavigationResultEntity<T>> execute<T>(NavigationEntity navigation) async {
    try {
      return await _repository.showModal<T>(navigation);
    } catch (e) {
      return NavigationResultEntity.failure('Show modal failed: $e');
    }
  }
}

/// Use case for dismissing modals
class DismissModalUseCase {
  final NavigationRepository _repository;

  DismissModalUseCase(this._repository);

  Future<NavigationResultEntity> execute({dynamic result}) async {
    try {
      return await _repository.dismissModal(result: result);
    } catch (e) {
      return NavigationResultEntity.failure('Dismiss modal failed: $e');
    }
  }
}

/// Use case for getting current route
class GetCurrentRouteUseCase {
  final NavigationRepository _repository;

  GetCurrentRouteUseCase(this._repository);

  NavigationEntity? execute() {
    try {
      return _repository.getCurrentRoute();
    } catch (e) {
      return null;
    }
  }
}

/// Use case for checking if can navigate back
class CanNavigateBackUseCase {
  final NavigationRepository _repository;

  CanNavigateBackUseCase(this._repository);

  bool execute() {
    try {
      return _repository.canNavigateBack();
    } catch (e) {
      return false;
    }
  }
}

/// Use case for getting navigation history
class GetNavigationHistoryUseCase {
  final NavigationRepository _repository;

  GetNavigationHistoryUseCase(this._repository);

  List<NavigationEntity> execute() {
    try {
      return _repository.getNavigationHistory();
    } catch (e) {
      return [];
    }
  }
}
