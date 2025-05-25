# 🧭 Navigation System Documentation

## Overview

The application implements a comprehensive navigation system following **Clean Architecture** principles. The system provides type-safe, consistent navigation throughout the entire application with proper separation of concerns.

## 🏗️ Architecture

### Domain Layer
- **NavigationEntity**: Core navigation data structure
- **NavigationRepository**: Abstract navigation contract
- **NavigationUseCases**: Business logic for navigation operations

### Data Layer
- **NavigationModel**: Data representation with JSON serialization
- **NavigationDataSource**: Flutter navigation implementation
- **NavigationRepositoryImpl**: Repository implementation

### Presentation Layer
- **NavigationService**: Core navigation service with route mapping
- **NavigationProviders**: Riverpod providers for state management
- **NavigationHelper**: Convenient navigation methods and extensions

## 🎯 Key Features

### ✅ **Type-Safe Navigation**
```dart
// Strongly typed navigation with compile-time checking
await ref.toThemeSettings();
await ref.toGame(arguments: {'level': 1});
```

### ✅ **Clean Architecture**
- Domain entities define navigation contracts
- Use cases handle business logic
- Repository pattern for data access
- Providers for state management

### ✅ **Consistent API**
- Same navigation system used throughout the app
- Extension methods for easy access
- Mixin support for stateful widgets

### ✅ **Route Management**
- Centralized route definitions in `AppRoutes`
- Named route generation
- Argument passing support
- Error handling for unknown routes

### ✅ **State Management**
- Navigation history tracking
- Current route monitoring
- Back navigation capability checking
- Riverpod integration

## 📁 File Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart      # Route constants
│   └── navigation/navigation_service.dart # Core navigation service
├── domain/
│   ├── entities/navigation_entity.dart   # Navigation domain model
│   ├── repositories/navigation_repository.dart # Abstract contract
│   └── usecases/navigation_usecases.dart # Business logic
├── data/
│   ├── models/navigation_model.dart      # Data model
│   ├── datasources/navigation_datasource.dart # Flutter implementation
│   └── repositories/navigation_repository_impl.dart # Repository impl
└── presentation/
    ├── providers/navigation_providers.dart # Riverpod providers
    └── widgets/navigation_helper.dart     # Helper methods & extensions
```

## 🚀 Usage Examples

### Basic Navigation
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => ref.toThemeSettings(),
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => ref.toGame(),
            child: Text('Start Game'),
          ),
          ElevatedButton(
            onPressed: () => ref.goBack(),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
```

### Navigation with Arguments
```dart
// Navigate with arguments
await ref.toGame(arguments: {
  'level': 5,
  'difficulty': 'hard',
  'playerName': 'John',
});

// Access arguments in destination screen
class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final level = args?['level'] ?? 1;
    final difficulty = args?['difficulty'] ?? 'easy';
    
    return Scaffold(
      appBar: AppBar(title: Text('Game - Level $level')),
      body: Text('Difficulty: $difficulty'),
    );
  }
}
```

### Using NavigationService Directly
```dart
// For more control, use NavigationService directly
NavigationService.pushNamed(AppRoutes.themeSettings);
NavigationService.pushReplacementNamed(AppRoutes.home);
NavigationService.pop();

// Show dialogs and bottom sheets
NavigationService.showAppDialog(
  child: AlertDialog(
    title: Text('Confirmation'),
    content: Text('Are you sure?'),
  ),
);
```

### Navigation Mixin for Stateful Widgets
```dart
class MyStatefulWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> 
    with NavigationMixin {
  
  void _handleButtonPress() async {
    // Use mixin methods directly
    await toThemeSettings();
    
    if (canGoBack) {
      await goBack();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: _handleButtonPress,
        child: Text('Navigate'),
      ),
    );
  }
}
```

## 🛣️ Route Configuration

### Route Constants
```dart
class AppRoutes {
  // Main routes
  static const String home = '/';
  static const String game = '/game';
  
  // Settings routes
  static const String themeSettings = '/settings/theme';
  static const String fontSettings = '/settings/font';
  static const String languageSettings = '/settings/language';
  
  // Route names for analytics
  static const String homeRouteName = 'home';
  static const String gameRouteName = 'game';
  static const String themeSettingsRouteName = 'theme_settings';
}
```

### Adding New Routes
1. **Add route constant** in `AppRoutes`
2. **Update NavigationService.generateRoute()** with new case
3. **Add convenience method** to NavigationHelper
4. **Update extension methods** if needed

```dart
// 1. Add to AppRoutes
static const String newScreen = '/new-screen';
static const String newScreenRouteName = 'new_screen';

// 2. Add to NavigationService.generateRoute()
case AppRoutes.newScreen:
  page = const NewScreen();
  break;

// 3. Add to NavigationHelper
static Future<void> toNewScreen(WidgetRef ref) async {
  final navigation = NavigationEntity(
    path: AppRoutes.newScreen,
    name: AppRoutes.newScreenRouteName,
  );
  await ref.read(navigationProvider.notifier).navigateTo(navigation);
}

// 4. Add to extension
extension NavigationExtension on WidgetRef {
  Future<void> toNewScreen() => NavigationHelper.toNewScreen(this);
}
```

## 🧪 Testing

### Navigation Tests
```dart
testWidgets('should navigate to theme settings', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        onGenerateRoute: NavigationService.generateRoute,
        home: Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: () => ref.toThemeSettings(),
              child: Text('Settings'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();

  expect(find.byType(ThemeSettingsScreen), findsOneWidget);
});
```

## 🔧 Configuration

### MaterialApp Setup
```dart
MaterialApp(
  navigatorKey: NavigationService.navigatorKey,
  onGenerateRoute: NavigationService.generateRoute,
  initialRoute: AppRoutes.home,
  // ... other properties
)
```

### Provider Setup
```dart
// Navigation providers are automatically available
// No additional setup required beyond ProviderScope
```

## 🎨 Best Practices

1. **Use Extension Methods**: Prefer `ref.toThemeSettings()` over direct service calls
2. **Consistent Naming**: Follow route naming conventions
3. **Type Safety**: Always use strongly typed navigation
4. **Error Handling**: Handle navigation errors gracefully
5. **Testing**: Write tests for navigation flows
6. **Documentation**: Document new routes and their purposes

## 🔄 Integration

The navigation system is fully integrated with:
- ✅ **Theme System**: Consistent navigation across themes
- ✅ **Localization**: Localized navigation labels
- ✅ **Font System**: Proper font rendering in navigation
- ✅ **State Management**: Riverpod integration throughout

## 📊 Benefits

- **🎯 Type Safety**: Compile-time navigation checking
- **🏗️ Clean Architecture**: Proper separation of concerns
- **🔄 Consistency**: Same navigation API throughout app
- **🧪 Testability**: Easy to test navigation flows
- **📱 Maintainability**: Centralized route management
- **⚡ Performance**: Efficient navigation with proper state management

The navigation system provides a robust, scalable foundation for app navigation while maintaining clean architecture principles and ensuring consistency throughout the application! 🚀
