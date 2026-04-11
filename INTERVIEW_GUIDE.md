# HealMeal Interview Guide

## What Is HealMeal

HealMeal is a Flutter mobile app for healthcare commerce. It helps users:

- browse medicines and health products
- upload prescriptions
- book lab tests
- manage a cart and place an order
- track that order
- manage account settings, wallet, notifications, wishlist, and support pages

It also includes role-based dashboards for pharmacist, rider, admin, lab technician, and business users.

The current version is frontend-first. That means the UI, navigation, theme, and user flows are complete enough for presentation, while backend behavior is mocked locally so the app does not break during a demo.

## How To Explain The Project In One Minute

If you need a short answer in an interview, say this:

HealMeal is a Flutter healthcare commerce app built with a feature-based structure. I used `go_router` for navigation, `flutter_bloc` for state management, and `shared_preferences` for lightweight persistence like theme, locale, wishlist, session, and local order tracking. The project is organized into `core` for shared infrastructure and `features` for business flows like auth, products, checkout, orders, lab tests, and account management. The app is frontend-focused, so mock data is used to keep the user journey stable without depending on a backend.

## What Problem The App Solves

The app is built for healthcare-related ordering and service booking. A user can:

1. log in with OTP
2. browse products
3. add items to cart
4. place an order
5. track the order
6. upload prescriptions
7. book lab tests
8. manage account and support tasks

This makes the app easy to explain because it has clear, real-world user journeys.

## Core Architecture In Simple Words

The app is split into two big parts:

- `core/` for shared infrastructure
- `features/` for business-specific screens and logic

That keeps the structure easy to explain.

### `core/` Means

This is the reusable foundation of the app:

- colors
- text styles
- spacing
- routing
- theme
- localization
- shared widgets
- utilities
- mock data

### `features/` Means

This is where the actual app modules live:

- auth
- home
- products
- cart
- checkout
- orders
- prescriptions
- lab tests
- account
- staff/business dashboards

## Complete Folder Structure Walkthrough

### Root Level

- `android/` is Android-specific code and build config
- `ios/` is iOS-specific code and Xcode config
- `assets/` stores images, icons, and fonts
- `lib/` contains the actual Flutter app
- `src/` keeps the original protected logo asset
- `test/` contains tests
- `web/` allows browser-based demo runs
- `pubspec.yaml` manages packages, assets, and fonts
- `README.md` explains setup and running
- `PROJECT_GUIDE.md` explains the repository structure
- `INTERVIEW_GUIDE.md` helps you explain the app confidently

### Inside `lib/`

- `main.dart` starts the app and injects global Bloc state
- `app.dart` builds the root `MaterialApp.router`
- `core/` holds shared infrastructure
- `features/` holds route-facing features and screen flows

### Inside `core/`

- `constants/` holds colors, strings, spacing, and text styles
- `cubits/` holds global app cubits such as wishlist
- `localization/` handles English/Bangla switching
- `mock_data/` contains demo models and content
- `router/` handles navigation and route protection
- `theme/` handles light/dark mode
- `utils/` contains formatters, validators, session logic, and responsive helpers
- `widgets/` contains reusable components

### Inside `features/`

Each folder represents a business area.

Examples:

- `auth/` for login and OTP
- `products/` for product browsing
- `checkout/` for checkout and confirmation
- `orders/` for order history and order detail
- `lab_tests/` for lab booking
- `account/` for account tools
- `roles/` for pharmacist, rider, admin, lab-tech, and business dashboards

### Why `features/shared/` Exists

This project uses route wrapper files in each feature folder, but the heavy screen implementations are grouped in `features/shared/`.

This makes the router easy to read while still keeping related UI code together.

For example:

- route file: `features/orders/order_detail_screen.dart`
- implementation file: `features/shared/checkout_order_pages.dart`

That keeps imports clean and avoids one giant router file with huge inline screens.

## How The App Starts

Here is the startup flow:

1. Flutter launches `main.dart`
2. `main.dart` initializes Flutter bindings
3. It loads saved theme, locale, wishlist, and session data
4. It creates global Bloc providers
5. It runs `HealMealApp`
6. `app.dart` builds `MaterialApp.router`
7. `app_router.dart` decides which first screen to show

## How Navigation Works

Navigation is handled by `go_router`.

Main file:

- `lib/core/router/app_router.dart`

This file defines:

- all routes
- the bottom-tab shell
- role-based redirects
- protection for restricted pages

### Navigation Pattern

- public startup routes: splash, onboarding, login, OTP, register
- patient shell routes: home, categories, lab test, account
- stand-alone flow routes: cart, checkout, orders, prescriptions, product detail, etc.
- role routes: pharmacist, rider, admin, lab-tech, business

### Why This Is Good To Say In An Interview

You can say:

I used `go_router` because the app has multiple flows, role-based entry points, and nested tab navigation. I also added a central redirect guard so users cannot freely open restricted staff routes if they do not have the correct role.

## How State Management Works

State is managed using `flutter_bloc`.

Examples:

- `AuthCubit` handles login flow and selected role
- `CartCubit` handles cart items and totals
- `CheckoutCubit` handles checkout choices
- `OrdersCubit` persists placed orders locally so tracking remains stable
- `ThemeCubit` stores dark/light mode
- `LocaleCubit` stores language
- `WishlistCubit` stores saved products

### How To Explain This Simply

Say:

I used Bloc because it keeps UI and state separate, especially for flows like auth, cart, checkout, and orders. It also makes the code easier to test and reason about than scattering `setState` everywhere.

## How Authentication And Role Logic Work

Authentication is intentionally lightweight for demo stability.

- OTP is mocked in `AuthCubit`
- session data is stored through `AppSession`
- local persistence uses `SharedPreferences`

Roles supported:

- patient
- pharmacist
- rider
- admin
- lab_tech
- business

After OTP verification, the app redirects the user to the correct route for that role.

### Important Interview Point

This is not secure backend authentication. It is frontend-safe demo logic. You should say that clearly if asked.

## How Theme And Styling Work

Styling is centralized.

Main style files:

- `app_colors.dart`
- `app_text_styles.dart`
- `app_spacing.dart`
- `light_theme.dart`
- `dark_theme.dart`

This helps the UI stay consistent across screens.

### Dark And Light Mode

- theme selection is stored locally using `ThemeCubit`
- the selected mode is loaded during app startup
- `MaterialApp.router` receives both light and dark themes

### Localization

- strings are defined in English and Bangla
- `LocaleCubit` stores the current language
- helper methods choose the correct text at runtime

## How Data Moves Through The App

Because this is a frontend-first app, data mostly flows like this:

1. mock content is defined under `core/mock_data/`
2. cubits or screens read the mock content
3. UI renders based on the current state
4. local actions update local state or local persistence

Example order flow:

1. user adds products to cart
2. checkout collects delivery and payment choices
3. `OrdersCubit` creates a local order snapshot
4. confirmation page reads the latest order
5. tracking page reads that stored order by ID

## Android And iOS Structure In Simple Terms

### Android

Inside `android/`:

- Gradle config defines build settings
- AndroidManifest defines app metadata and permissions
- app resources hold launcher images and Android-specific files

### iOS

Inside `ios/`:

- `Runner/` is the main iOS app target
- `Info.plist` holds app metadata
- `AppDelegate.swift` is the iOS entry point
- `Podfile` sets up CocoaPods for Flutter plugins

## How Screens Connect

The screen connection model is:

- route wrappers expose screens to the router
- shared implementation files build the actual pages
- shared widgets create visual consistency
- cubits provide state

Examples:

- login screen goes to OTP
- OTP goes to a role-specific home
- patient flow goes to home shell
- product detail can go to cart or checkout
- checkout goes to confirmation
- confirmation goes to order tracking

## Beginner-Friendly “How To Explain This In An Interview”

### Project Overview

This is a Flutter healthcare commerce app with product ordering, prescriptions, lab tests, and role-based dashboards.

### Architecture Overview

I used a feature-based structure with a shared `core` layer. `core` handles routing, theme, localization, shared widgets, utilities, and mock data. `features` handles business modules like auth, products, checkout, orders, lab tests, and account.

### Why These Libraries Were Used

- `go_router` for clean routing and role-based redirects
- `flutter_bloc` for predictable state management
- `shared_preferences` for simple local persistence
- `cached_network_image` for resilient image loading
- `google_fonts` plus local fonts for visual consistency

### How Navigation Was Implemented

Navigation is centralized in `app_router.dart`. The app uses a shell route for the main patient tabs and separate routes for focused flows like checkout, product details, and staff dashboards.

### How State Was Managed

State is split by responsibility using cubits. Each flow has its own cubit where needed, which keeps UI and logic separated and easier to maintain.

### How Authentication And Authorization Work

Authentication is local and mocked for demo stability. Session state and roles are stored locally. The router guard blocks users from opening restricted role dashboards that do not match their assigned role.

### How Dark/Light Mode Works

Theme mode is stored with `SharedPreferences`, loaded on app start, and applied through a global Bloc that updates the app theme dynamically.

### Challenges Found And Fixed

Examples you can mention:

- unstable order-tracking flow after checkout
- layout overflows in narrow mobile widths
- weak fallback image behavior
- inconsistent routing between roles
- stale internal docs and duplicate legacy code in the repository

### What Could Be Improved Next

- replace mock data with real APIs
- add backend authentication and real authorization
- add real payments
- add stronger automated tests
- replace fallback/demo media with final production assets

## Step-By-Step: How This App Was Built

If asked to explain the build process from start to finish, use this sequence:

1. Start with Flutter project setup and platform scaffolding
2. Define the app theme, spacing, typography, and reusable colors
3. Add localization support for English and Bangla
4. Create the router and screen structure
5. Add reusable widgets like buttons, app bars, image components, and cards
6. Build feature flows one by one:
   - splash and onboarding
   - auth
   - home and browse
   - product detail
   - cart and checkout
   - order tracking
   - prescriptions
   - lab tests
   - account
   - support/legal pages
   - role dashboards
7. Add mock data so every screen has stable content
8. Add state management for auth, cart, orders, wishlist, theme, and locale
9. Fix responsive layout issues and overflow problems
10. Clean the repository and rewrite documentation for handoff

## Final Advice For Your Evaluation

If the evaluator asks something difficult, keep returning to these key points:

- the app is feature-organized and easy to navigate in code
- shared logic is centralized in `core`
- business flows are isolated in `features`
- routing is centralized and role-aware
- state is handled with Bloc
- persistence is local for stable demos
- the project was cleaned for handoff and explainability

That gives you a clear and confident structure to talk through the project even if you are still learning Flutter.
