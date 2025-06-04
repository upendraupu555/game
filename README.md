# 🎮 Ultra 2048 - Flutter Application

A feature-rich **Ultra 2048 puzzle game** built with **Clean Architecture** principles and modern Flutter development practices. This application showcases advanced game development techniques, comprehensive state management, and a complete powerup system with interactive features.

## ✨ Core Features

### 🏗️ **Clean Architecture Foundation**
- **Domain Layer**: Business logic, entities, and use cases
- **Data Layer**: Local data sources and repository implementations
- **Presentation Layer**: UI components with Riverpod state management
- **Comprehensive testing** with unit and widget tests
- **SOLID principles** implementation throughout

### 🎮 **Advanced Ultra 2048 Game Engine**
- **5x5 game board** with smooth tile animations
- **Flame package integration** for enhanced animations and effects
- **Gesture-based controls** with swipe detection
- **Score tracking** with formatted display (10k+ format)
- **Game state persistence** with automatic save/load
- **Game over detection** and restart functionality

### 🎨 **Complete Theme System**
- **Light & Dark themes** with system preference support
- **7 customizable primary colors**: Red, Blue, Pink, Orange, Gray, Green, Yellow
- **User preference persistence** with SharedPreferences
- **Real-time theme switching** throughout the app
- **Consistent color scheme** across all UI components

### 🔤 **Font Management System**
- **3 font options**: BubblegumSans (primary), Chewy, Comic Neue
- **User font selection** with live preview in settings
- **Consistent typography** throughout the application
- **Font preference persistence** and real-time updates

### 🌍 **Asset-Based Localization**
- **English language support** with complete UI coverage
- **Flat key-value structure** for easy translation management
- **Asset-based storage** in `/assets/localization/`
- **Scalable architecture** ready for multi-language expansion
- **Riverpod integration** for reactive translations

### 🧭 **Advanced Navigation System**
- **Clean architecture navigation** with entities and use cases
- **Type-safe routing** with compile-time checking
- **Centralized NavigationService** with global key management
- **Navigation history tracking** and result handling
- **Modal and dialog support** with proper state management

### ⚡ **Comprehensive Powerup System**
- **Dynamic powerup acquisition** based on score milestones (1000, 3000, 5000, 7000+)
- **Randomized powerup selection** for balanced gameplay
- **Visual powerup inventory** with availability indicators
- **Powerup activation animations** and visual effects
- **Score-based unlocking** with progressive difficulty

#### **Interactive Powerups** 🎯
- **Tile Destroyer** 💥: Tap any tile to destroy it completely
- **Row Clear** ↔️: Tap any tile to clear its entire row
- **Column Clear** ↕️: Tap any tile to clear its entire column
- **Selection mode UI** with visual feedback and instructions
- **Cancel functionality** to exit selection mode

#### **Automatic Powerups** ⚡
- **Tile Freeze** 🧊: Prevents new tiles for 5 moves
- **Merge Boost** 🔄: Enhanced merging for 3 moves
- **Double Merge** ✖️: Next merge creates 4x value instead of 2x
- **Value Upgrade** ⬆️: Upgrade selected tile to next power of 2

### 🎲 **Advanced Tile System**
- **Blocker tiles** that appear after merging 256+ tiles
- **Blocker merging mechanics** - two blockers disappear when merged
- **Smooth tile animations** during moves and merges
- **New tile spawn logic** - only in empty positions
- **Visual tile effects** with scaling and color transitions

### 📊 **Game Analytics & Logging**
- **Comprehensive event tracking** with AppLogger
- **User action logging** for gameplay analysis
- **Performance monitoring** with animation tracking
- **Error handling** with detailed stack traces
- **Debug logging** for development and testing

### 🎨 **Visual Effects & Animations**
- **Smooth tile movement** with Flame engine integration
- **Merge animations** with elastic bounce effects
- **Powerup activation effects** with visual feedback
- **Score animations** and achievement notifications
- **Theme transition animations** for seamless UX

### 🔧 **Developer Tools & Testing**
- **Debug controls** for testing powerups and game states
- **Hot reload support** for rapid development
- **Comprehensive test coverage** for core functionality
- **Clean code architecture** following Flutter best practices
- **Modular component design** for easy maintenance

### 📱 **Multi-Platform Support**
- **iOS** - Native performance with platform-specific optimizations
- **Android** - Material Design compliance with adaptive UI
- **macOS** - Desktop-optimized interface and controls
- **Web** - Progressive Web App capabilities
- **Responsive design** adapting to different screen sizes

## 🎯 Game Features

### **Core Gameplay**
- Classic Ultra 2048 mechanics with modern enhancements
- 5x5 board for increased complexity and strategy
- Smooth gesture controls with swipe detection
- Progressive difficulty with blocker tiles
- Score-based progression system

### **Powerup Strategy**
- Strategic powerup usage for high scores
- Interactive powerups requiring player skill
- Balanced powerup distribution system
- Visual feedback for all powerup effects

### **Progression System**
- Score milestones unlock new powerups
- Randomized powerup rewards for variety
- Achievement-based progression
- Persistent game state across sessions

## 🏗️ Architecture Highlights

### **State Management**
- **Riverpod** for reactive state management
- **Provider pattern** for dependency injection
- **Immutable state** with proper state transitions
- **Error handling** with AsyncValue patterns

### **Game Engine**
- **Flame package** for game-specific features
- **Custom animation controllers** for smooth effects
- **Gesture detection** with proper event handling
- **Performance optimization** for 60fps gameplay

### **Data Persistence**
- **SharedPreferences** for user settings
- **JSON serialization** for game state
- **Automatic save/load** functionality
- **Migration support** for app updates

This application demonstrates modern Flutter development practices while delivering an engaging and feature-rich gaming experience. The clean architecture ensures maintainability and extensibility for future enhancements.

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- IDE: VS Code, Android Studio, or IntelliJ IDEA
- Platform-specific requirements:
  - **iOS**: Xcode 14+ and iOS 11+
  - **Android**: Android Studio and API level 21+
  - **macOS**: macOS 10.14+ and Xcode 12+
  - **Web**: Chrome, Firefox, Safari, or Edge

### **Installation**

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd game/frontend/game
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For mobile (iOS/Android)
   flutter run

   # For macOS
   flutter run -d macos

   # For web
   flutter run -d chrome
   ```

### **Development Setup**

1. **Enable developer tools**
   - Debug buttons are available in development mode
   - Hot reload is enabled for rapid development
   - Flutter DevTools for performance monitoring

2. **Testing**
   ```bash
   # Run all tests
   flutter test

   # Run tests with coverage
   flutter test --coverage
   ```

## 📁 Project Structure

```
lib/
├── core/                          # Core utilities and constants
│   ├── constants/                 # App-wide constants
│   ├── logging/                   # Logging system
│   └── utils/                     # Utility functions
├── data/                          # Data layer
│   ├── datasources/              # Local and remote data sources
│   ├── models/                   # Data models
│   └── repositories/             # Repository implementations
├── domain/                        # Domain layer
│   ├── entities/                 # Business entities
│   ├── repositories/             # Repository interfaces
│   └── usecases/                 # Business use cases
├── presentation/                  # Presentation layer
│   ├── providers/                # Riverpod providers
│   ├── screens/                  # App screens
│   ├── widgets/                  # Reusable widgets
│   └── theme/                    # Theme configuration
└── main.dart                     # App entry point

assets/
├── fonts/                        # Custom fonts
├── localization/                 # Translation files
└── images/                       # App images and icons

test/                             # Test files
├── unit/                         # Unit tests
├── widget/                       # Widget tests
└── integration/                  # Integration tests
```

## 🎮 How to Play

### **Basic Controls**
- **Swipe** in any direction (up, down, left, right) to move tiles
- **Merge tiles** with the same number to create higher values
- **Reach 2048** or higher to win (but you can continue playing!)

### **Powerup System**
1. **Earn powerups** by reaching score milestones (1000, 3000, 5000, etc.)
2. **Activate powerups** by tapping them in the powerup tray
3. **Interactive powerups** require you to select a target tile
4. **Strategic usage** - save powerful powerups for difficult situations

### **Advanced Mechanics**
- **Blocker tiles** appear after merging 256+ tiles for added challenge
- **Score formatting** shows values like "15k" for better readability
- **Game state** is automatically saved and restored

## 🔧 Configuration

### **Theme Customization**
- Navigate to **Settings → Theme** to customize colors
- Choose from 7 predefined color options
- Switch between light and dark modes
- Changes apply instantly across the app

### **Font Selection**
- Navigate to **Settings → Font** to change typography
- Choose from BubblegumSans, Chewy, or Comic Neue
- Preview changes in real-time

### **Game Settings**
- All game preferences are automatically saved
- Game state persists across app restarts
- Reset functionality available in settings

## 🧪 Testing Features

### **Debug Controls** (Development Mode)
- **Test powerup buttons** for quick powerup testing
- **Game state manipulation** for testing edge cases
- **Performance monitoring** with Flutter DevTools

### **Automated Testing**
- **Unit tests** for business logic
- **Widget tests** for UI components
- **Integration tests** for complete user flows
- **Test coverage** reporting available

## 🔮 Future Enhancements

### **Planned Features**
- **Multiplayer mode** with real-time competition
- **Daily challenges** with special rewards
- **Achievement system** with unlockable content
- **Sound effects** and background music
- **Additional languages** for global reach
- **Cloud save** for cross-device synchronization

### **Technical Improvements**
- **Performance optimizations** for larger boards
- **Advanced animations** with particle effects
- **AI opponent** for single-player challenges
- **Analytics dashboard** for gameplay insights

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### **Development Guidelines**
- Follow clean architecture principles
- Maintain test coverage above 80%
- Use conventional commit messages
- Update documentation for new features

## 📞 Support

For support, questions, or feature requests:
- Open an issue on GitHub
- Check the documentation
- Review existing issues and discussions

---

**Built with ❤️ using Flutter and Clean Architecture principles**
