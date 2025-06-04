# 🏷️ Whitelabel Application Guide

## Overview

This Flutter application is designed as a **whitelabel solution** that can be easily customized and rebranded for different clients or use cases. The entire application is configurable through a single configuration file, making it perfect as a base project template.

## 🎯 What is Whitelabel?

A whitelabel application is a generic product that can be rebranded and customized by different companies or developers. This app provides:

- **Complete customization** through configuration
- **Clean architecture** for easy maintenance
- **Modular features** that can be enabled/disabled
- **Multi-language support** out of the box
- **Theme customization** with brand colors
- **Font selection** for brand consistency

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd frontend/game
flutter pub get
```

### 2. Customize Your App
Edit `lib/core/config/app_config.dart` to customize your application:

```dart
class AppConfig {
  // Change these values for your brand
  static const String appName = 'Your Amazing App';
  static const String companyName = 'Your Company';
  static const String bundleId = 'com.yourcompany.yourapp';

  // Customize brand colors
  static const int primaryLightColor = 0x1976D2; // Your brand blue
  static const int primaryDarkColor = 0x0D47A1;  // Darker variant

  // Enable/disable features
  static const bool enableGameScreen = false;
  static const bool enableAboutScreen = true;
  static const bool enableHelpScreen = true;
  // ... more configuration options
}
```

### 3. Update Localization
Edit localization files in `assets/localization/`:
- `en.json` - English translations
- `es.json` - Spanish translations

### 4. Run Your App
```bash
flutter run
```

## 📋 Configuration Options

### App Identity
```dart
static const String appName = 'Ultra 2048';
static const String appVersion = '1.0.0';
static const String appDescription = 'A beautiful Ultra 2048 puzzle game built with Flutter and clean architecture';
static const String companyName = 'Your Company';
static const String bundleId = 'com.yourcompany.yourapp';
```

### Branding Colors
```dart
static const int primaryLightColor = 0x1976D2;
static const int primaryDarkColor = 0x0D47A1;
static const int accentColor = 0xFF5722;
static const int errorColor = 0xF44336;
```

### Available Features
```dart
static const bool enableThemeCustomization = true;
static const bool enableFontCustomization = true;
static const bool enableLanguageSelection = true;
static const bool enableDarkMode = true;
static const bool enableGameScreen = false;  // Disable game-specific features
static const bool enableAboutScreen = true;
static const bool enableHelpScreen = true;
static const bool enableFeedbackScreen = true;
```

### Typography
```dart
static const String defaultFontFamily = 'Roboto';
static const List<String> availableFonts = ['Roboto', 'OpenSans', 'Lato'];
```

### Localization
```dart
static const String defaultLanguage = 'en';
static const List<String> supportedLanguages = ['en', 'es', 'fr'];
```

## 🎨 Customization Guide

### 1. App Branding

#### Change App Name and Identity
1. Update `AppConfig.appName`
2. Update localization files (`app_title` key)
3. Update `android/app/build.gradle` for Android package name
4. Update `ios/Runner/Info.plist` for iOS bundle identifier

#### Change App Icon
1. Replace icon files in `android/app/src/main/res/` directories
2. Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/` files
3. Or use `flutter_launcher_icons` package for automated icon generation

#### Change App Colors
1. Update color values in `AppConfig`
2. Colors automatically apply throughout the app
3. Users can still customize colors if `enableThemeCustomization = true`

### 2. Feature Configuration

#### Enable/Disable Screens
```dart
// Disable game-specific features for business apps
static const bool enableGameScreen = false;

// Enable standard app features
static const bool enableAboutScreen = true;
static const bool enableHelpScreen = true;
static const bool enableFeedbackScreen = true;
```

#### Customize Available Options
```dart
// Limit color choices for brand consistency
static const List<int> availableColors = [
  0x1976D2, // Your primary brand color
  0x388E3C, // Your secondary brand color
];

// Limit font choices
static const List<String> availableFonts = [
  'YourBrandFont',
  'Roboto',
];
```

### 3. Content Customization

#### Update Welcome Message
Edit `assets/localization/en.json`:
```json
{
  "welcome_message": "Welcome to Your Amazing App!",
  "start_app": "Get Started",
  "about_description": "Your custom app description here..."
}
```

#### Customize Help Content
Edit `lib/presentation/screens/help_screen.dart` to add your specific help content.

#### Customize About Screen
The about screen automatically uses your `AppConfig` values, but you can customize the layout in `lib/presentation/screens/about_screen.dart`.

## 🌍 Multi-Language Support

### Adding New Languages

1. **Create localization file**: `assets/localization/fr.json`
2. **Add to supported languages**:
   ```dart
   static const List<String> supportedLanguages = ['en', 'es', 'fr'];
   ```
3. **Add display name**:
   ```dart
   static const Map<String, String> languageDisplayNames = {
     'en': 'English',
     'es': 'Español',
     'fr': 'Français',
   };
   ```

### Localization File Structure
```json
{
  "locale": "en",
  "language": "English",
  "app_title": "Your App Name",
  "welcome_message": "Welcome message",
  "about_description": "About your app",
  // ... all other keys
}
```

## 🏗️ Architecture Benefits

### Clean Architecture
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources and repositories
- **Presentation Layer**: UI components and state management

### Modular Design
- Features can be enabled/disabled
- Easy to add new features
- Consistent patterns throughout

### State Management
- Riverpod for reactive state management
- Proper dependency injection
- Testable architecture

## 📱 Platform Configuration

### Android
Update `android/app/build.gradle`:
```gradle
android {
    namespace = "com.yourcompany.yourapp"

    defaultConfig {
        applicationId = "com.yourcompany.yourapp"
        versionName = "1.0.0"
    }
}
```

### iOS
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>
<key>CFBundleName</key>
<string>Your App Name</string>
```

### macOS
Update `macos/Runner/Configs/AppInfo.xcconfig`:
```
PRODUCT_NAME = your_app_name
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.yourapp
```

## 🧪 Testing Your Configuration

### Validation
The app includes configuration validation:
```dart
// Check if your configuration is valid
bool isValid = AppConfig.validateConfig();
```

### Testing Checklist
- [ ] App name displays correctly
- [ ] Brand colors are applied
- [ ] Disabled features don't appear
- [ ] Localization works for all languages
- [ ] About screen shows correct information
- [ ] Help content is relevant
- [ ] All navigation works properly

## 🚀 Deployment

### Build for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### App Store Configuration
1. Update app metadata in store consoles
2. Use your custom app icon and screenshots
3. Write your custom app description
4. Set your pricing and availability

## 🔧 Advanced Customization

### Custom Themes
Extend the theme system in `lib/presentation/theme/app_theme.dart`

### Custom Fonts
1. Add font files to `assets/fonts/`
2. Update `pubspec.yaml`
3. Add to `AppConfig.availableFonts`

### Custom Screens
1. Create new screen in `lib/presentation/screens/`
2. Add route in `AppRoutes`
3. Update `NavigationService.generateRoute()`
4. Add feature flag in `AppConfig`

### API Integration
Configure API settings in `AppConfig`:
```dart
static const String baseApiUrl = 'https://api.yourcompany.com';
static const bool enableNetworking = true;
```

## 📚 Examples

### Business App Configuration
```dart
class AppConfig {
  static const String appName = 'Business Pro';
  static const bool enableGameScreen = false;
  static const bool enableAboutScreen = true;
  static const bool enableHelpScreen = true;
  static const bool enableFeedbackScreen = true;
  static const int primaryLightColor = 0x1565C0;
  static const int primaryDarkColor = 0x0D47A1;
}
```

### Educational App Configuration
```dart
class AppConfig {
  static const String appName = 'Learn & Grow';
  static const bool enableGameScreen = true;
  static const List<String> availableFonts = ['ComicNeue', 'BubblegumSans'];
  static const int primaryLightColor = 0x4CAF50;
  static const int primaryDarkColor = 0x2E7D32;
}
```

This whitelabel system provides a solid foundation for creating customized Flutter applications while maintaining clean architecture and professional code quality! 🎯✨
