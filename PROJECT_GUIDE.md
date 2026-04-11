# HealMeal Project Guide

## What This App Is

HealMeal is a Flutter mobile application for healthcare commerce in Bangladesh. It demonstrates the core user journeys of:

- browsing medicines and healthcare products
- adding items to cart
- completing checkout
- tracking orders
- uploading prescriptions
- booking lab tests
- managing an account and wallet
- showing role-based dashboards for pharmacist, rider, admin, lab technician, and business users

This repository is frontend-first. The flows are designed to remain stable without a live backend, so the app can still be presented, tested, and explained confidently.

## Top-Level Folder Guide

### `android/`

Android-specific project files. This folder contains Gradle build configuration, AndroidManifest, resources, and the Android entry point used by Flutter when building or running on Android.

### `assets/`

Static app assets.

- `assets/fonts/` contains bundled fonts used by the UI
- `assets/icons/` contains icon assets
- `assets/images/` contains the copied HealMeal logo and image assets
- `assets/lottie/` is reserved for animation assets

### `ios/`

iOS-specific project files. This folder contains the Xcode project, iOS app metadata, CocoaPods bootstrap file, and the iOS app entry point used by Flutter when building on macOS.

### `lib/`

This is the heart of the application. Almost all app logic, UI, routing, theme, mock data, and state management live here.

### `src/`

Contains the original protected logo source file:

- `src/HealMeal_logo.png`

This file is preserved and should not be modified directly.

### `test/`

Lightweight automated test coverage for Flutter widgets.

### `web/`

Flutter web hosting files used when running the app in a browser for quick demos or smoke testing.

### `.metadata`

Flutter-managed metadata about the project. Keep this file in version control.

### `analysis_options.yaml`

Dart and Flutter linting rules.

### `pubspec.yaml`

The main Flutter configuration file. It controls:

- package name and app description
- dependency versions
- asset registration
- font registration
- app version

### `pubspec.lock`

The resolved dependency lockfile. This makes setup more reproducible across machines.

### `README.md`

Main setup and handoff guide for running and building the project.

### `PROJECT_GUIDE.md`

This file. It explains what exists in the project and how the pieces connect.

### `INTERVIEW_GUIDE.md`

Beginner-friendly explanation of how to describe the project in an interview, demo, or evaluation.

## `lib/` Folder Structure

### `lib/main.dart`

The app entry point. It:

- initializes Flutter bindings
- loads local session state
- loads saved theme and locale preferences
- creates the global Bloc providers
- starts the app by rendering `HealMealApp`

### `lib/app.dart`

Builds `MaterialApp.router`. This file connects:

- routing
- theme
- localization
- dark mode

### `lib/core/`

Shared, app-wide infrastructure.

#### `lib/core/constants/`

Reusable design tokens and text resources:

- `app_colors.dart` for the main color system
- `app_text_styles.dart` for typography
- `app_spacing.dart` for consistent spacing and radii
- `app_assets.dart` for asset paths
- `app_strings_en.dart` and `app_strings_bn.dart` for English and Bangla strings

#### `lib/core/cubits/`

Global app-level cubits that are not tied to a single screen. Right now this mainly contains wishlist state.

#### `lib/core/localization/`

Locale handling and string helpers.

- `locale_cubit.dart` stores and changes the selected language
- `app_localizations.dart` exposes helpers like `context.tr(...)`

#### `lib/core/mock_data/`

The demo data layer. It contains:

- mock models
- mock products
- mock orders
- mock lab tests
- mock users
- mock notifications

This is where app content comes from during demo mode instead of from a real backend API.

#### `lib/core/router/`

Contains `app_router.dart`, which defines:

- all routes
- the shell navigation
- the login/role-based redirect guard
- protection for restricted role areas

#### `lib/core/theme/`

Theme configuration.

- `app_theme.dart` exposes the app themes
- `light_theme.dart` and `dark_theme.dart` define the visual theme data
- `theme_cubit.dart` persists light/dark mode locally

#### `lib/core/utils/`

Utility helpers used across the app.

- `app_formatters.dart` for currency and dates
- `app_layout.dart` for responsive layout helpers
- `app_validators.dart` for field validation
- `app_session.dart` for local session and role persistence

#### `lib/core/widgets/`

Shared widgets used across multiple screens.

Important files include:

- `healmeal_app_bar.dart`
- `healmeal_bottom_nav.dart`
- `healmeal_button.dart`
- `healmeal_image.dart`
- `healmeal_text_field.dart`
- `product_card.dart`
- dialogs in `widgets/dialogs/`

### `lib/features/`

This folder contains route-facing screens and related feature logic, grouped by domain.

Important feature groups:

- `account/`
- `auth/`
- `cart/`
- `checkout/`
- `home/`
- `lab_tests/`
- `orders/`
- `prescriptions/`
- `products/`
- `roles/`
- `search/`
- `splash/`
- `static/`

### Why `lib/features/shared/` Exists

The route files inside `lib/features/` are intentionally lightweight wrappers. The heavier screen implementations are grouped in `lib/features/shared/` by business flow so the code stays easier to scan and maintain.

For example:

- auth UI lives in `auth_pages.dart`
- browse and category UI lives in `browse_pages.dart`
- cart, checkout, confirmation, and order detail live in `checkout_order_pages.dart`
- prescriptions live in `prescription_pages.dart`
- account UI is split into account core, extra, and lab pages
- static marketing/legal/support pages live in `static_core_pages.dart` and `static_feature_pages.dart`

This approach keeps route entry files small without scattering every screen into dozens of tiny files.

## Where Main App Logic Lives

The most important app logic lives in:

- `lib/main.dart`
- `lib/app.dart`
- `lib/core/router/app_router.dart`
- `lib/core/utils/app_session.dart`
- feature cubits under `lib/features/**/cubit/`
- shared screen implementations under `lib/features/shared/`

## Navigation Structure and Screen Flow

### Startup Flow

1. `main.dart` initializes the app
2. `SplashScreen` checks local session state and first-launch state
3. The user is routed to onboarding, login, or a role home screen

### Main Patient Flow

1. Splash
2. Onboarding
3. Login
4. OTP verification
5. Home shell with bottom navigation
6. Product browsing or lab browsing
7. Cart
8. Checkout
9. Order confirmation
10. Order tracking and account/support flows

### Bottom Navigation Flow

The main patient-facing shell uses `StatefulShellRoute.indexedStack`, which helps preserve tab state while switching between:

- Home
- Categories
- Lab Test
- Account

Cart is intentionally outside the shell so it can be opened directly as a focused flow.

## Auth and Role Flow

Authentication is demo-safe and local.

- OTP verification is mocked in `AuthCubit`
- session state is stored locally in `AppSession`
- role and phone number are persisted using `SharedPreferences`

Supported roles:

- patient
- pharmacist
- rider
- admin
- lab_tech
- business

After login, the router redirects the user to the correct home route based on their role.

## Admin Access and Limitations

Admin and staff dashboards are presentation-oriented. The access control is now enforced through the router guard so users cannot casually enter the wrong restricted role area by typing the URL.

Important limitations:

- actions are still mock/demo actions
- there is no real server authorization layer
- dashboards are safe for evaluation, not production backend control

In other words, the UI is protected logically in the app, but real production-grade server authorization would still be needed in a backend-backed system.

## Config and Environment Files

This project does not rely on a custom `.env` file right now.

Key config files are:

- `pubspec.yaml` for dependencies and assets
- `.metadata` for Flutter project metadata
- `analysis_options.yaml` for lint rules
- `android/app/build.gradle.kts` for Android app ID and build settings
- `ios/Podfile` for CocoaPods integration
- `ios/Runner/Info.plist` for iOS app metadata

## API, Service, and Data Flow

There is no live backend in this repository.

The current data flow is:

1. mock data is defined under `lib/core/mock_data/`
2. feature cubits read that mock data
3. screens render the state from those cubits
4. lightweight local persistence is handled with `SharedPreferences`

Examples:

- theme and locale are persisted locally
- login session is persisted locally
- wishlist is persisted locally
- orders are stored locally for stable checkout and order tracking demos

## Build and Run Flow

### General Flutter Flow

1. install Flutter and platform tools
2. run `flutter pub get`
3. run `flutter analyze`
4. run `flutter test`
5. run the app on Android, iOS, or web

### Android Flow

- Flutter calls the Gradle build inside `android/`
- Android package ID is `com.healmeal.app`
- debug builds work out of the box once Android SDK is configured

### iOS Flow

- Flutter uses the Xcode project inside `ios/`
- CocoaPods is bootstrapped through `ios/Podfile`
- iOS builds require macOS, Xcode, and CocoaPods

## Android and iOS Platform Structure

### Android

Important Android locations:

- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/` or `java/` entry files
- `android/gradle/` wrapper files

### iOS

Important iOS locations:

- `ios/Runner/Info.plist`
- `ios/Runner/AppDelegate.swift`
- `ios/Runner.xcodeproj/`
- `ios/Runner.xcworkspace/`
- `ios/Podfile`

## How the Different Parts Connect

The connection path is:

1. `main.dart` initializes local session, theme, locale, and feature state
2. `app.dart` builds the app with router and theme
3. `app_router.dart` decides what screen tree to render
4. route wrapper files under `lib/features/` expose screens to the router
5. shared UI implementations under `lib/features/shared/` build the actual experience
6. reusable UI comes from `lib/core/widgets/`
7. reusable colors, strings, typography, and spacing come from `lib/core/constants/`
8. feature and global cubits manage the app state

## Practical Maintenance Notes

- If you add a new screen, register its route in `lib/core/router/app_router.dart`
- If you add a new reusable design pattern, place it under `lib/core/widgets/`
- If you add new demo content, place it under `lib/core/mock_data/`
- If you add new text visible to users, prefer the localization string files
- If you add a new role-specific page, make sure the router guard allows only the correct role

## Current Scope

This project is ready for handoff as a stable frontend demo application. It is organized to be easy to run, explain, and extend. Real production backend services, real OTP, real payments, and real admin authorization are outside the current scope.
