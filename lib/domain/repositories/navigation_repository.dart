import '../entities/navigation_entity.dart';

/// Abstract repository interface for navigation management
/// Following clean architecture - domain layer defines the contract
abstract class NavigationRepository {
  /// Navigate to a specific route
  Future<NavigationResultEntity> navigateTo(NavigationEntity navigation);

  /// Navigate back to previous screen
  Future<NavigationResultEntity> navigateBack({dynamic result});

  /// Navigate and replace current route
  Future<NavigationResultEntity> navigateAndReplace(NavigationEntity navigation);

  /// Navigate and clear entire navigation stack
  Future<NavigationResultEntity> navigateAndClearStack(NavigationEntity navigation);

  /// Pop until a specific route
  Future<NavigationResultEntity> popUntil(String routePath);

  /// Check if can navigate back
  bool canNavigateBack();

  /// Get current route information
  NavigationEntity? getCurrentRoute();

  /// Get navigation history
  List<NavigationEntity> getNavigationHistory();

  /// Clear navigation history
  void clearNavigationHistory();

  /// Show modal dialog/bottom sheet
  Future<NavigationResultEntity<T>> showModal<T>(NavigationEntity navigation);

  /// Dismiss current modal
  Future<NavigationResultEntity> dismissModal({dynamic result});
}
