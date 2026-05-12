# Setup Guide

Follow these steps to get your HealMeal development environment up and running.

## 🛠️ Prerequisites

- **Flutter SDK**: 3.38.9 or later.
- **Dart SDK**: 3.10.8 or later.
- **Java**: JDK 11 or 17 (for Android builds).
- **CocoaPods**: Latest version (for iOS builds on macOS).
- **IDE**: VS Code (recommended) or Android Studio with Flutter/Dart plugins.

## 📥 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd HealMeal
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   The project is pre-configured with a demo Firebase project. For custom setup:
   - Create a project in [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS/Web apps.
   - Replace `lib/firebase_options.dart` using `flutterfire configure`.

## 🏃 Running the App

### Debug Mode
```bash
# Run on the default connected device
flutter run

# Run on a specific platform
flutter run -d chrome
flutter run -d android
```

### Release Build
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

## ✅ Verification

After launching, verify the following:
1. **Splash Screen**: Should transition to Onboarding or Login.
2. **Demo Login**: Use `admin@healmeal.com.bd` / `password` to access admin tools.
3. **Mock Data**: Products should load via the `DatabaseInitializer` batch.
