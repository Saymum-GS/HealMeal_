# Deployment Guide

HealMeal is designed to be deployed to the Apple App Store, Google Play Store, and the Web.

## 📱 Mobile Deployment (Fastlane)

We recommend using **Fastlane** to automate the release process.

### Android
1. Configure `android/key.properties` with your signing keys.
2. Run `fastlane android deploy` to push to the Play Console.

### iOS
1. Ensure `Runner.xcworkspace` is configured with the correct Provisioning Profiles.
2. Run `fastlane ios deploy` to push to TestFlight.

## 🌐 Web Deployment

The web version is optimized for Firebase Hosting.

```bash
# Build the project
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

## 🔐 Security Considerations

- **API Keys**: Ensure `firebase_options.dart` is not exposed in public repositories unless intended.
- **Obfuscation**: For production builds, always use the `--obfuscate` flag:
  ```bash
  flutter build apk --release --obfuscate --split-debug-info=/<path>
  ```
