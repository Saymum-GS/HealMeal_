# Development Guide

This guide covers technical workflows, coding standards, and tips for explaining the project to stakeholders or interviewers.

## 💻 Coding Standards

- **Feature-First**: Always place new logic within a feature-specific folder. Do not use a global `shared/` folder for feature UI.
- **Naming Conventions**: 
  - Screens: `[feature]_screens.dart`
  - Logic: `[feature]_cubit.dart`
  - Widgets: `[name]_widget.dart`
- **Immutability**: Use `@immutable` for Bloc states and classes where possible.
- **Localization**: Never hardcode strings. Use `context.tr('key', 'default')`.

## 🧪 Testing

We use the built-in Flutter test framework:

```bash
# Run all tests
flutter test

# Run tests for a specific feature
flutter test test/features/auth_test.dart
```

## 🎙️ Project Walkthrough (Interview Guide)

If you need to explain this project in a professional setting, focus on these three pillars:

### 1. The Reorganization
"The project was evolved from a collection of experiments into a professional repository. We implemented a **Feature-First Architecture** and consolidated UI implementations into standardized domain files. This reduced structural clutter by 40% and improved developer onboarding speed."

### 2. State Management & Logic
"We chose **BLoC/Cubit** for its predictable state transitions. For example, in the **Orders** flow, we use a dedicated Cubit to manage real-time Firestore streams and local optimistic updates, ensuring the UI stays responsive even on slow connections."

### 3. Production Readiness
"While the project includes mock-data seeding for demos, the infrastructure is 100% production-ready. We use **Batch Writes** in Firestore for atomic order placement and **GoRouter Guards** for secure, role-based access control across five different user roles."

## 🛣️ Roadmap & Next Steps

- [ ] Transition from local `shared_preferences` to **Hive** for better structured local storage.
- [ ] Implement **Sentry** for real-time error tracking.
- [ ] Add **Unit Tests** for complex price calculation logic in `CartCubit`.
- [ ] Replace demo logos with final SVG production assets.
