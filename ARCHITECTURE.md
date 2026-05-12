# System Architecture

HealMeal is built with a focus on maintainability, scalability, and professional organization. It utilizes a **Feature-First Architecture** which isolates business logic into domain-specific modules.

## 🏗️ Folder Structure

HealMeal uses a **Feature-First Architecture** with a strict "Standardized Splitting" pattern for screens:

```text
lib/
├── core/                 Cross-cutting infrastructure
│   ├── constants/        Design tokens (Colors, Text, Spacing, SSOT Base)
│   ├── localization/     Multi-language support (EN/BN)
│   ├── data/             SSOT Models (models.dart) & Seeding
│   ├── router/           Centralized navigation & RBAC Guards
│   └── widgets/          HealMeal Design System components
└── features/             Isolated domain modules
    └── [feature]/        (e.g., auth, home, products)
        ├── cubit/        Business logic
        ├── [feature]_screens.dart  # Barrel file (Exports all screens)
        ├── [screen]_screen.dart    # Individual screen
        └── ...
```

## 🧠 Core Standards (v3.0)

### 1. Single-Source-of-Truth (SSOT) Model
All data entering or leaving the application **must** pass through the centralized models in `lib/core/data/models.dart`.
- **Zero-Tolerance for Raw Maps:** No `Map<String, dynamic>` should exist in Cubits beyond the `fromMap` factory.
- **Symmetric Serialization:** Every model must implement `fromMap` and `toMap` for consistent Firestore/LocalStorage integration.
- **Factory Discipline:** Factories handle nulls with sensible defaults to prevent runtime null-pointer exceptions.

### 2. Localization-First UI
The app is 100% dual-language (English/Bangla).
- **Extension Usage:** Use `context.strings` exclusively. Hardcoded strings are forbidden.
- **Key Parity:** Any key added to the `AppStrings` interface must be implemented in both `AppStringsEn` and `AppStringsBn`.

### 3. Strict RBAC Enforcement
With 5 distinct roles (Patient, Pharmacist, Rider, Admin, Lab Tech), isolation is critical.
- **Route Guards:** `app_router.dart` uses `_redirectGuard` to validate sessions and role permissions before allowing navigation.
- **UI Branching:** Use the `UserRole` enum for conditional rendering and role-specific dashboards.

## 🧪 State Management

The application uses **BLoC (Business Logic Component)** via the `flutter_bloc` package. 

- **Cubit** is preferred for simpler state transitions (e.g., UI toggles, simple data fetching).
- **Bloc** is used for more complex event-driven logic (e.g., complex multi-step forms).

Each feature maintains its own `cubit/` directory for localized state. Global states like `AuthCubit`, `CartCubit`, and `ThemeCubit` are provided at the root of the app.

## 🧭 Navigation & Routing

**GoRouter** is used for declarative routing. 

- **Role-Based Guards**: The router implements a central redirect guard that validates the user's role against protected areas.
- **Deep Linking**: Routes are structured to support deep links and browser navigation (Flutter Web).
- **Nested Navigation**: The `StatefulShellRoute` is used for the main bottom navigation to preserve tab state.

## 💾 Data Layer

- **Firestore**: The primary real-time database for products, orders, and user profiles.
- **Firebase Storage**: Used for prescription images and user avatars.
- **Local Persistence**: `shared_preferences` is used for caching user sessions, themes, and locale preferences.
- **Seeding**: The `DatabaseInitializer` class ensures a robust and consistent data state.

## 🎨 Design System

HealMeal uses a centralized design system located in `lib/core/constants/`:

- **AppColors**: Tailored HSL color palette for medical branding.
- **AppTextStyles**: Typography based on Inter/Roboto for maximum readability.
- **AppSpacing**: Standardized padding, margin, and radius tokens.
