import 'package:flutter/material.dart';
import '../../core/navigation/navigation_service.dart';
import '../models/navigation_model.dart';

/// Navigation data source for handling Flutter navigation
abstract class NavigationDataSource {
  Future<bool> navigateTo(NavigationModel navigation);
  Future<bool> navigateBack({dynamic result});
  Future<bool> navigateAndReplace(NavigationModel navigation);
  Future<bool> navigateAndClearStack(NavigationModel navigation);
  Future<bool> popUntil(String routePath);
  bool canNavigateBack();
  NavigationModel? getCurrentRoute();
  List<NavigationModel> getNavigationHistory();
  void clearNavigationHistory();
  Future<T?> showModal<T>(NavigationModel navigation);
  Future<bool> dismissModal({dynamic result});
}

class NavigationDataSourceImpl implements NavigationDataSource {
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<NavigationModel> _navigationHistory = [];
  NavigationModel? _currentRoute;

  NavigationDataSourceImpl(this._navigatorKey);

  NavigatorState? get _navigator => _navigatorKey.currentState;

  @override
  Future<bool> navigateTo(NavigationModel navigation) async {
    try {
      if (_navigator == null) return false;

      final route = _createRoute(navigation);
      if (route == null) return false;

      await _navigator!.push(route);
      _addToHistory(navigation);
      _currentRoute = navigation;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> navigateBack({dynamic result}) async {
    try {
      if (_navigator == null || !canNavigateBack()) return false;

      _navigator!.pop(result);
      _removeFromHistory();
      _updateCurrentRoute();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> navigateAndReplace(NavigationModel navigation) async {
    try {
      if (_navigator == null) return false;

      final route = _createRoute(navigation);
      if (route == null) return false;

      await _navigator!.pushReplacement(route);
      _replaceInHistory(navigation);
      _currentRoute = navigation;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> navigateAndClearStack(NavigationModel navigation) async {
    try {
      if (_navigator == null) return false;

      final route = _createRoute(navigation);
      if (route == null) return false;

      await _navigator!.pushAndRemoveUntil(route, (route) => false);
      _clearHistoryAndAdd(navigation);
      _currentRoute = navigation;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> popUntil(String routePath) async {
    try {
      if (_navigator == null) return false;

      _navigator!.popUntil(ModalRoute.withName(routePath));
      _popHistoryUntil(routePath);
      _updateCurrentRoute();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool canNavigateBack() {
    return _navigator?.canPop() ?? false;
  }

  @override
  NavigationModel? getCurrentRoute() {
    return _currentRoute;
  }

  @override
  List<NavigationModel> getNavigationHistory() {
    return List.unmodifiable(_navigationHistory);
  }

  @override
  void clearNavigationHistory() {
    _navigationHistory.clear();
    _currentRoute = null;
  }

  @override
  Future<T?> showModal<T>(NavigationModel navigation) async {
    try {
      if (_navigator == null) return null;

      if (navigation.isModal) {
        // Show as dialog
        return await showDialog<T>(
          context: _navigator!.context,
          builder: (context) => _buildModalContent(navigation),
        );
      } else {
        // Show as bottom sheet
        return await showModalBottomSheet<T>(
          context: _navigator!.context,
          builder: (context) => _buildModalContent(navigation),
        );
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> dismissModal({dynamic result}) async {
    try {
      if (_navigator == null) return false;

      _navigator!.pop(result);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create route based on navigation model
  Route<dynamic>? _createRoute(NavigationModel navigation) {
    final widget = _getWidgetForRoute(navigation.path, navigation.arguments);
    if (widget == null) return null;

    return MaterialPageRoute(
      builder: (context) => widget,
      settings: RouteSettings(
        name: navigation.path,
        arguments: navigation.arguments,
      ),
    );
  }

  /// Get widget for specific route path
  Widget? _getWidgetForRoute(String path, Map<String, dynamic>? arguments) {
    // Use the NavigationService to generate the route
    final route = NavigationService.generateRoute(RouteSettings(
      name: path,
      arguments: arguments,
    ));

    if (route is MaterialPageRoute) {
      return route.builder(_navigator!.context);
    }

    return null;
  }

  /// Build modal content
  Widget _buildModalContent(NavigationModel navigation) {
    final widget = _getWidgetForRoute(navigation.path, navigation.arguments);
    return widget ?? const SizedBox.shrink();
  }

  /// History management methods
  void _addToHistory(NavigationModel navigation) {
    _navigationHistory.add(navigation);
  }

  void _removeFromHistory() {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
    }
  }

  void _replaceInHistory(NavigationModel navigation) {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
    }
    _navigationHistory.add(navigation);
  }

  void _clearHistoryAndAdd(NavigationModel navigation) {
    _navigationHistory.clear();
    _navigationHistory.add(navigation);
  }

  void _popHistoryUntil(String routePath) {
    while (_navigationHistory.isNotEmpty &&
           _navigationHistory.last.path != routePath) {
      _navigationHistory.removeLast();
    }
  }

  void _updateCurrentRoute() {
    _currentRoute = _navigationHistory.isNotEmpty ? _navigationHistory.last : null;
  }
}
