# HealMeal

HealMeal is a Flutter mobile application for healthcare commerce in Bangladesh. It covers medicine browsing, cart and checkout, order tracking, prescription upload, lab test booking, account tools, and role-based dashboards for staff and business users.

This repository is frontend-first and demo-stable. Core user flows are designed to keep working without a live backend by using mock data plus lightweight local persistence.

## Included Handoff Docs

- [PROJECT_GUIDE.md](/D:/HealMeal/PROJECT_GUIDE.md) explains the repository structure and how the app is wired.
- [INTERVIEW_GUIDE.md](/D:/HealMeal/INTERVIEW_GUIDE.md) explains the project in beginner-friendly language for demo, interview, or evaluation use.

## Tech Stack

- Flutter 3.38.9
- Dart 3.10.8
- `flutter_bloc` for state management
- `go_router` for navigation and route guards
- `shared_preferences` for lightweight local persistence
- `cached_network_image` for resilient image loading
- `google_fonts` plus local bundled fonts

## What The App Does

- OTP-style mock login
- role-based landing for patient, pharmacist, rider, admin, lab tech, and business users
- product browsing with categories, flash sale, search, and detail pages
- cart, checkout, order confirmation, and order tracking
- prescription list and upload
- lab test browsing, detail, booking, orders, and reports
- account management, wallet, wishlist, notifications, referral, offers, and support pages
- static pages such as FAQ, privacy, terms, contact, blog, doctor consultation, and careers

## Project Structure

```text
HealMeal/
├── android/              Android project files
├── assets/               Fonts, icons, images
├── ios/                  iOS project files
├── lib/                  Main Flutter application code
├── src/                  Protected original logo source
├── test/                 Flutter tests
├── web/                  Flutter web hosting files
├── pubspec.yaml          Dependencies and asset registration
├── README.md             Setup and handoff guide
├── PROJECT_GUIDE.md      Full repository map
└── INTERVIEW_GUIDE.md    Beginner-friendly explanation guide
```

## Main App Code

Important locations inside `lib/`:

- `lib/main.dart`
  Bootstraps the app and global Bloc providers.
- `lib/app.dart`
  Builds `MaterialApp.router` and connects theme, locale, and router.
- `lib/core/`
  Shared infrastructure such as theme, router, mock data, localization, utilities, and reusable widgets.
- `lib/features/`
  Route-facing features like auth, home, products, checkout, orders, lab tests, account, and staff dashboards.
- `lib/features/shared/`
  Grouped screen implementations by domain so route wrappers stay small and easy to read.

## Prerequisites

### Required

- Flutter SDK 3.38.9 stable
- Dart SDK 3.10.8

### Android Development

- Android Studio
- Android SDK Platform 36
- Android build-tools 36.0.0
- Java 17 or newer

### iOS Development

iOS builds require macOS only. On a Mac you need:

- Xcode
- CocoaPods
- iOS simulator support

### Web Demo

- Microsoft Edge or Google Chrome

## Fresh Machine Setup

### 1. Install Flutter

Install Flutter stable and confirm it works:

```bash
flutter --version
flutter doctor -v
```

### 2. Clone or copy the repository

Then go into the project root:

```bash
cd HealMeal
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Validate the project

```bash
flutter analyze
flutter test
```

## Android Setup

### Android SDK

If Flutter does not detect Android SDK automatically:

```bash
flutter config --android-sdk <PATH_TO_ANDROID_SDK>
flutter doctor -v
```

### Android Emulator

1. Open Android Studio
2. Open Device Manager
3. Create an emulator
4. Start the emulator
5. Confirm it is visible:

```bash
flutter devices
```

### Run on Android

```bash
flutter run -d android
```

Or target a specific device ID:

```bash
flutter run -d <device-id>
```

### Build Android APK

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

Note:

- release signing is not configured for store submission
- `android/app/build.gradle.kts` currently uses debug signing for release-mode local builds
- replace that signing config before shipping to Play Store

## iOS Setup

iOS can only be built on macOS.

### First-time iOS setup on Mac

```bash
flutter pub get
cd ios
pod install
cd ..
flutter doctor -v
```

### Run on iOS Simulator

```bash
flutter run -d ios
```

### Build iOS

```bash
flutter build ios
```

For archive/release distribution, use Xcode for signing, certificates, and App Store or Ad Hoc export.

## Web Run

Edge:

```bash
flutter run -d edge
```

Chrome:

```bash
flutter run -d chrome
```

If Chrome is not detected on Windows, either install Chrome or use Edge.

## Configuration Notes

This project does not currently require a custom `.env` file.

Important config files:

- `pubspec.yaml` for packages, assets, and fonts
- `android/app/build.gradle.kts` for Android package and build settings
- `ios/Podfile` for CocoaPods integration
- `ios/Runner/Info.plist` for iOS app metadata
- `analysis_options.yaml` for linting

## Assets

- original protected logo source: `src/HealMeal_logo.png`
- app-ready logo copy: `assets/images/healmeal_logo.png`
- bundled fonts: `assets/fonts/`

## App Flow Summary

### Startup

1. Splash
2. Onboarding for first launch
3. Login
4. OTP verification

### Main patient flow

1. Home shell
2. Browse products or lab tests
3. Add to cart
4. Checkout
5. Order confirmation
6. Track order

### Additional flows

- upload prescription
- manage addresses
- check notifications and wallet
- manage wishlist and offers
- lab bookings and reports
- role-specific dashboards

## Auth and Role Behavior

Authentication is intentionally lightweight for demo stability:

- OTP is mocked
- session state is stored locally
- router guards restrict role-only dashboard areas

Roles supported:

- patient
- pharmacist
- rider
- admin
- lab_tech
- business

## Data and Backend Scope

This repository does not include a live production backend.

The app uses:

- mock data under `lib/core/mock_data/`
- local persistence for session, theme, locale, wishlist, and orders

That keeps demos stable and prevents broken flows during presentation.

## Common Commands

Install dependencies:

```bash
flutter pub get
```

Analyze:

```bash
flutter analyze
```

Test:

```bash
flutter test
```

Run on Android:

```bash
flutter run -d android
```

Run on Edge:

```bash
flutter run -d edge
```

Build debug APK:

```bash
flutter build apk --debug
```

Clean:

```bash
flutter clean
```

## Common Failure Cases And Fixes

### `flutter pub get` fails

- confirm Flutter version is compatible
- run `flutter clean`
- run `flutter pub get` again

### Android device not found

- open the emulator or connect a phone
- run `flutter devices`
- confirm Android SDK is configured

### iOS pods fail on Mac

- run `pod repo update`
- run `pod install` again inside `ios/`
- confirm Xcode command line tools are installed

### Web run fails in Chrome

- use Edge instead
- or set `CHROME_EXECUTABLE`

### Build artifacts make the repo look messy

Run:

```bash
flutter clean
```

This removes generated build output safely.

## Current Limitations

- backend APIs are not integrated
- OTP is mocked
- payment methods are demo-safe UI flows
- role dashboards use mock data and mock actions
- release signing is not set up for store publishing

## Handoff Notes

This repository has been cleaned for production-style handoff in terms of structure, documentation, routing stability, and UI consistency. It is ready to be run, explained, and extended without carrying internal prompt files, stale duplicate code, or setup ambiguity.
