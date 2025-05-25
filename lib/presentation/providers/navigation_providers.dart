import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/navigation_service.dart';
import '../../data/datasources/navigation_datasource.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/entities/navigation_entity.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../../domain/usecases/navigation_usecases.dart';

// Data source providers
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return NavigationService.navigatorKey;
});

final navigationDataSourceProvider = Provider<NavigationDataSource>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return NavigationDataSourceImpl(navigatorKey);
});

// Repository providers
final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  final dataSource = ref.watch(navigationDataSourceProvider);
  return NavigationRepositoryImpl(dataSource);
});

// Use case providers
final navigateToUseCaseProvider = Provider<NavigateToUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return NavigateToUseCase(repository);
});

final navigateBackUseCaseProvider = Provider<NavigateBackUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return NavigateBackUseCase(repository);
});

final navigateAndReplaceUseCaseProvider = Provider<NavigateAndReplaceUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return NavigateAndReplaceUseCase(repository);
});

final navigateAndClearStackUseCaseProvider = Provider<NavigateAndClearStackUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return NavigateAndClearStackUseCase(repository);
});

final showModalUseCaseProvider = Provider<ShowModalUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return ShowModalUseCase(repository);
});

final dismissModalUseCaseProvider = Provider<DismissModalUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return DismissModalUseCase(repository);
});

final getCurrentRouteUseCaseProvider = Provider<GetCurrentRouteUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return GetCurrentRouteUseCase(repository);
});

final canNavigateBackUseCaseProvider = Provider<CanNavigateBackUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return CanNavigateBackUseCase(repository);
});

final getNavigationHistoryUseCaseProvider = Provider<GetNavigationHistoryUseCase>((ref) {
  final repository = ref.watch(navigationRepositoryProvider);
  return GetNavigationHistoryUseCase(repository);
});

// Navigation state notifier
class NavigationNotifier extends StateNotifier<NavigationEntity?> {
  NavigationNotifier(this._ref) : super(null);

  final Ref _ref;

  Future<void> navigateTo(NavigationEntity navigation) async {
    final useCase = _ref.read(navigateToUseCaseProvider);
    final result = await useCase.execute(navigation);
    
    if (result.isSuccess) {
      state = navigation;
    }
  }

  Future<void> navigateBack({dynamic result}) async {
    final useCase = _ref.read(navigateBackUseCaseProvider);
    await useCase.execute(result: result);
    _updateCurrentRoute();
  }

  Future<void> navigateAndReplace(NavigationEntity navigation) async {
    final useCase = _ref.read(navigateAndReplaceUseCaseProvider);
    final result = await useCase.execute(navigation);
    
    if (result.isSuccess) {
      state = navigation;
    }
  }

  Future<void> navigateAndClearStack(NavigationEntity navigation) async {
    final useCase = _ref.read(navigateAndClearStackUseCaseProvider);
    final result = await useCase.execute(navigation);
    
    if (result.isSuccess) {
      state = navigation;
    }
  }

  Future<T?> showModal<T>(NavigationEntity navigation) async {
    final useCase = _ref.read(showModalUseCaseProvider);
    final result = await useCase.execute<T>(navigation);
    
    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }

  Future<void> dismissModal({dynamic result}) async {
    final useCase = _ref.read(dismissModalUseCaseProvider);
    await useCase.execute(result: result);
  }

  void _updateCurrentRoute() {
    final getCurrentRouteUseCase = _ref.read(getCurrentRouteUseCaseProvider);
    state = getCurrentRouteUseCase.execute();
  }
}

// Main navigation provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationEntity?>((ref) {
  return NavigationNotifier(ref);
});

// Computed providers for UI convenience
final currentRouteProvider = Provider<NavigationEntity?>((ref) {
  return ref.watch(navigationProvider);
});

final canNavigateBackProvider = Provider<bool>((ref) {
  final useCase = ref.watch(canNavigateBackUseCaseProvider);
  return useCase.execute();
});

final navigationHistoryProvider = Provider<List<NavigationEntity>>((ref) {
  final useCase = ref.watch(getNavigationHistoryUseCaseProvider);
  return useCase.execute();
});

// Route name provider for current route
final currentRouteNameProvider = Provider<String>((ref) {
  final currentRoute = ref.watch(currentRouteProvider);
  return currentRoute?.name ?? 'unknown';
});

// Route path provider for current route
final currentRoutePathProvider = Provider<String>((ref) {
  final currentRoute = ref.watch(currentRouteProvider);
  return currentRoute?.path ?? '/';
});
