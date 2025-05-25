# Clean Architecture Theme System Documentation

## Overview

This Flutter application implements a comprehensive theme system following **Clean Architecture principles** and using **Riverpod** for state management. The system allows users to:

- Switch between light, dark, and system themes
- Customize primary colors from a curated palette of 7 specific colors
- Persist theme settings across app sessions
- Apply consistent theming throughout the entire application

## Clean Architecture Structure

### 🏗️ Architecture Layers

1. **Domain Layer** (`lib/domain/`) - Pure Business Logic
   - `entities/` - Core business objects (ThemeEntity, ColorEntity)
   - `repositories/` - Abstract contracts for data access
   - `usecases/` - Business use cases and rules

2. **Data Layer** (`lib/data/`) - External Data Sources
   - `models/` - Data models with JSON serialization
   - `datasources/` - Data sources (SharedPreferences)
   - `repositories/` - Repository implementations

3. **Presentation Layer** (`lib/presentation/`) - UI & State Management
   - `providers/` - Riverpod providers for state management
   - `screens/` - UI screens and widgets
   - `theme/` - Theme configuration and styling
   - `widgets/` - Reusable UI components

## Curated Color Palette

The theme system uses exactly **7 carefully selected colors**:

- **Crimson Red** (`#D00000`) - Default light theme
- **Ocean Blue** (`#084887`) - Default dark theme
- **Rose Pink** (`#F44174`)
- **Sunset Orange** (`#F58A07`)
- **Silver Gray** (`#D3D4D9`)
- **Forest Green** (`#0B5D1E`)
- **Golden Yellow** (`#FEC601`)

## Default Configuration

- **Light Theme**: Crimson Red (`#D00000`)
- **Dark Theme**: Ocean Blue (`#084887`)
- **Default Mode**: System (follows device setting)

## Usage

### Basic Setup

The app follows clean architecture with proper dependency injection:

```dart
// main.dart - Presentation Layer
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return themeState.when(
      loading: () => MaterialApp(/* loading UI */),
      error: (error, stack) => MaterialApp(/* error UI */),
      data: (themeEntity) => MaterialApp(
        theme: AppTheme.lightTheme(themeEntity.lightPrimaryColor.toFlutterColor()),
        darkTheme: AppTheme.darkTheme(themeEntity.darkPrimaryColor.toFlutterColor()),
        themeMode: _getThemeMode(themeEntity.themeMode),
        home: const HomeScreen(),
      ),
    );
  }
}
```

### Using Theme in Widgets

#### Method 1: Using Theme.of(context)
```dart
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Themed Text',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

#### Method 2: Using Clean Architecture Providers
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentTheme = ref.watch(currentThemeProvider);

    return Container(
      color: currentPrimaryColor,
      child: Text('Current theme: ${currentTheme?.themeMode.displayName ?? 'Loading...'}'),
    );
  }
}
```

### Changing Theme Settings (Clean Architecture)

```dart
class ThemeControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      children: [
        // Change theme mode
        ElevatedButton(
          onPressed: () => themeNotifier.updateThemeMode(ThemeModeEntity.dark),
          child: Text('Switch to Dark'),
        ),

        // Change light theme color
        ElevatedButton(
          onPressed: () {
            final greenColor = ColorEntity(
              value: AppColors.primaryGreen.value,
              name: AppColors.getColorName(AppColors.primaryGreen),
            );
            themeNotifier.updateLightPrimaryColor(greenColor);
          },
          child: Text('Forest Green Light Theme'),
        ),

        // Reset to defaults
        ElevatedButton(
          onPressed: () => themeNotifier.resetToDefaults(),
          child: Text('Reset Theme'),
        ),
      ],
    );
  }
}
```

## Available Providers (Clean Architecture)

### Core Providers

#### `themeProvider`
- **Type**: `StateNotifierProvider<ThemeNotifier, AsyncValue<ThemeEntity>>`
- **Purpose**: Main theme state with async loading/error handling
- **Usage**: `ref.watch(themeProvider)` or `ref.read(themeProvider.notifier)`

#### `currentThemeProvider`
- **Type**: `Provider<ThemeEntity?>`
- **Purpose**: Current theme entity (null while loading)
- **Usage**: `ref.watch(currentThemeProvider)`

#### `currentBrightnessProvider`
- **Type**: `Provider<Brightness>`
- **Purpose**: Current brightness considering system theme
- **Usage**: `ref.watch(currentBrightnessProvider)`

#### `currentPrimaryColorProvider`
- **Type**: `Provider<Color>`
- **Purpose**: Current primary color based on active theme
- **Usage**: `ref.watch(currentPrimaryColorProvider)`

#### `availableColorsProvider`
- **Type**: `Provider<List<ColorEntity>>`
- **Purpose**: List of available colors from the curated palette
- **Usage**: `ref.watch(availableColorsProvider)`

### Repository & Use Case Providers

All use cases and repositories are provided through dependency injection:
- `themeRepositoryProvider`
- `updateThemeModeUseCaseProvider`
- `updateLightPrimaryColorUseCaseProvider`
- `updateDarkPrimaryColorUseCaseProvider`
- `resetThemeUseCaseProvider`

## Theme Settings Screen

Navigate to the theme settings screen to allow users to customize their theme:

```dart
// From presentation/screens/theme_settings_screen.dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const ThemeSettingsScreen(),
  ),
);
```

The theme settings screen provides:
- **Theme mode selection** (Light/Dark/System)
- **Color picker** with the 7 curated colors
- **Live preview** of theme changes
- **Reset to defaults** functionality
- **Async state handling** (loading, error states)

## Persistence

Theme settings are automatically persisted using `SharedPreferences` and will be restored when the app restarts.

## Testing

The clean architecture theme system includes comprehensive tests in `test/clean_theme_test.dart` covering:
- **Domain entities** and use cases
- **Data models** serialization/deserialization
- **Repository implementations**
- **Provider state management**
- **Async state handling**
- **Theme data generation**
- **Color palette validation**

Run tests with:
```bash
flutter test
```

The tests validate the entire clean architecture flow from domain entities to UI state management.

## Extending the Theme System

### Adding New Color Options

Add colors to `AppColors.primaryColorOptions` in `lib/presentation/theme/colors.dart`:

```dart
static const List<Color> primaryColorOptions = [
  Colors.red,
  Colors.blue,
  // Add your custom colors here
  Color(0xFF123456),
];
```

### Custom Theme Properties

Extend `ThemeSettings` to include additional theme properties:

```dart
class ThemeSettings {
  final AppThemeMode themeMode;
  final Color lightPrimaryColor;
  final Color darkPrimaryColor;
  final bool useCustomFonts; // New property

  // Update constructor, copyWith, toJson, fromJson accordingly
}
```

### Custom Widgets

Create theme-aware widgets using the provided patterns in `lib/presentation/widgets/themed_button.dart`.

## Best Practices

1. **Use ConsumerWidget**: Always extend `ConsumerWidget` when you need theme access
2. **Watch vs Read**: Use `ref.watch()` for reactive updates, `ref.read()` for one-time actions
3. **Theme Consistency**: Use the provided theme colors rather than hardcoded colors
4. **Performance**: Use specific providers (`currentPrimaryColorProvider`) rather than watching the entire theme settings when you only need specific values
5. **Testing**: Test theme-dependent widgets with different theme configurations

## Troubleshooting

### Theme Not Updating
- Ensure your widget extends `ConsumerWidget`
- Check that you're using `ref.watch()` not `ref.read()`
- Verify `ProviderScope` wraps your app

### Colors Not Persisting
- Check SharedPreferences permissions
- Verify JSON serialization in `ThemeSettings.toJson()`
- Check for errors in debug console

### Performance Issues
- Use specific providers instead of watching entire theme settings
- Consider using `select` for specific properties:
  ```dart
  final themeMode = ref.watch(themeProvider.select((settings) => settings.themeMode));
  ```
