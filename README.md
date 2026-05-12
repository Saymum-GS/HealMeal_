# HealMeal

HealMeal is a production-grade Flutter healthcare commerce application designed for the Bangladeshi market. It provides a complete end-to-end experience for medicine browsing, prescription management, lab test booking, and role-based logistics.

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Quick Start

1. **Prerequisites**: Ensure Flutter 3.38.9+ is installed.
2. **Setup**: Run `flutter pub get` to install dependencies.
3. **Run**: Use `flutter run` to launch on your preferred device.

For detailed setup instructions, see [SETUP.md](./SETUP.md).

## ✨ Key Features

- **Authentication**: Firebase-backed email/password login with role-based routing.
- **Product Catalog**: Categorized medicine browsing with real-time Firestore synchronization.
- **Prescription Management**: Secure upload to Firebase Storage with pharmacist review workflows.
- **Lab Test Booking**: Comprehensive diagnostic service booking with home collection options.
- **Order Tracking**: Real-time order status updates and history management.
- **Role-Based Access**: Specialized dashboards for Patients, Pharmacists, Riders, Admins, and Lab Technicians.
- **Local Persistence**: Resilient state management for offline-first capabilities using `shared_preferences`.

## 🏗️ Architecture

HealMeal follows a **Feature-First Architecture** combined with the **BLoC** (Business Logic Component) pattern. This ensures a strict separation of concerns and high scalability.

- **Core**: Shared infrastructure, design tokens, and global utilities.
- **Features**: Isolated business domains containing their own UI, logic, and models.
- **Data Layer**: Live Firestore integration with authentic medical data seeding for production readiness.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for a deep dive into the system design.

## 🛠️ Development & Contribution

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for our coding standards and pull request process.

For interview preparation and technical walkthroughs, refer to [DEVELOPMENT.md](./DEVELOPMENT.md).

## 📄 Documentation Hierarchy

- [**README.md**](./README.md): Project overview and quick start.
- [**ARCHITECTURE.md**](./ARCHITECTURE.md): Structural overview and design patterns.
- [**SETUP.md**](./SETUP.md): Environment configuration and build instructions.
- [**DEVELOPMENT.md**](./DEVELOPMENT.md): Technical walkthroughs and interview guides.
- [**DEPLOYMENT.md**](./DEPLOYMENT.md): CI/CD and release processes.
- [**CONTRIBUTING.md**](./CONTRIBUTING.md): Guidelines for contributors.

---

© 2026 HealMeal. Built for a healthier Bangladesh.
