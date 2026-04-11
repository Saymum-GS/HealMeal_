# HealMeal Flutter Project Audit and Production-Quality Refinement Blueprint

## Executive overview and current architecture snapshot

HealMeal is positioned as a Flutter-based healthcare + e-commerce style application (medicine purchase, lab tests, prescriptions, and multiple staff roles) as reflected in its repository documentation and feature claims. citeturn1view0 The codebase already contains major building blocks you’d expect in a “real app” (GoRouter, Bloc/Cubit, theme switching, localization handling, role dashboards), but it also shows strong symptoms of AI-generated scaffolding: oversized “pages” aggregator files, export-wrapper screens, state objects that do not match UI usage, and mock-first flows that sometimes simulate production behaviors without a clean boundary.

At a structural level, `lib/` is organized into `core/` and `features/`, plus `app.dart` and `main.dart`. citeturn2view0turn3view1 This is a good starting point. The main issues are *how* code is distributed inside those folders and how responsibilities are mixed:

- Routing is centralized in `lib/core/router/app_router.dart` and already includes auth gating and role-based redirection. citeturn15view0turn12view0
- Session persistence is handled via a static `AppSession` wrapper around `SharedPreferences` storing login status, role, and phone. citeturn14view0
- Global Cubits are created at app start via a large `MultiBlocProvider` (theme, locale, auth, cart, checkout, home, orders, product, search, wishlist). citeturn5view0
- UI “feature screens” are often not real screens at all, but one-line exports that re-export implementation from huge “shared/*_pages.dart” files. Example: `home_screen.dart` and `login_screen.dart` are just exports. citeturn26view0turn23view0

The largest maintainability risk is the “shared pages” pattern: multiple feature domains are implemented inside a handful of very large files (hundreds to over a thousand lines each), while the feature folders contain mostly export stubs. For example:
- `browse_pages.dart` ~875 lines citeturn27view0
- `product_pages.dart` ~830 lines citeturn35view0
- `role_pages.dart` ~1100 lines citeturn48view1turn50view1
- `checkout_order_pages.dart` ~1583 lines citeturn48view2turn49view10
- `auth_pages.dart` ~732 lines citeturn48view0turn49view1

This is the single biggest “AI-generated” smell: it compresses many app surfaces into a few monolith files, making the codebase hard to reason about, hard to test, and easy to break during edits.

## Full audit findings across structure, navigation, roles, state, UI, and mock data

### Folder structure and feature separation

The repository appears to *look* feature-based from the directory tree (`features/auth`, `features/home`, `features/cart`, `features/checkout`, `features/orders`, `features/products`, `features/roles`, etc.). citeturn18view0turn25view0turn39view0turn45view0turn33view0turn37view0

But this separation is largely superficial because core implementations live inside `features/shared/*.dart` mega-files, while many “feature screens” are one-line re-exports. Examples:
- `lib/features/home/home_screen.dart` exports `HomeScreen` and `MainShell` from `shared/browse_pages.dart`. citeturn26view0turn28view0  
- `lib/features/search/search_screen.dart` exports `SearchScreen` from `shared/product_pages.dart` (which is already a sign of cross-domain mixing). citeturn38view0turn36view2  
- `lib/features/cart/cart_screen.dart` exports `CartScreen` from `shared/checkout_order_pages.dart`. citeturn40view0turn49view10  
- `lib/features/auth/login_screen.dart` exports `LoginScreen` from `shared/auth_pages.dart`. citeturn23view0turn49view1  

This produces a “template-generated” feel because files exist primarily as routing/import adapters rather than coherent modules.

### Navigation and routing consistency

There is already a single `appRouter` (GoRouter) with:
- `initialLocation: '/splash'`
- a redirect guard that enforces auth and role restrictions
- a patient “main shell” using `StatefulShellRoute.indexedStack` for bottom navigation citeturn15view0turn12view0  

Role gating is prefix-based; staff areas are restricted to paths beginning with `/pharmacist`, `/rider`, `/admin`, `/lab-tech`, and `/account/business`, and access is granted only if the stored role matches. citeturn15view0turn15view2

Patient area access is also prefix based, defined by a list of “patient prefixes” such as `/home`, `/cart`, `/checkout`, `/orders`, `/prescriptions`, `/product`, `/search`, etc. citeturn15view1

This is *directionally correct*, but it is currently brittle for production-quality evaluation:
- The router file is large and mixes many unrelated routes in one place (it is a monolith similar to the “shared pages” pattern). citeturn15view0turn12view0
- Route protection relies on path prefix rules; that works, but becomes error-prone as routes grow (especially with nested routes and shared prefixes like `/account`). citeturn15view1turn15view2
- The patient shell navigation’s cart behavior is awkward: `MainShell` maps indices, treats cart as a special case, and pushes `/cart` instead of having cart as a normal bottom-nav branch. citeturn28view0 This is a typical artifact of “over-generated” navigation.

### Role-based system status

Roles are clearly present in the login UI and stored in session:
- `LoginScreen` defines the available roles: patient, pharmacist, rider, admin, lab_tech, business. citeturn49view1turn20view0
- The UI uses `ChoiceChip`s and calls `authCubit.setRole(roleId)` to select active role. citeturn49view0turn20view0
- Successful OTP verification persists login with the selected role. citeturn20view0turn14view0
- On login, the router redirects to a role-based home route using `AppSession.homeRouteForRole`. citeturn15view0turn14view0

However, the role dashboards appear partially “demo / placeholder driven”:
- Pharmacist dashboard uses `mockOrders.take(3)` rather than reading from a centralized order store. citeturn50view1turn50view7
- Admin dashboard explicitly displays text indicating full functionality requires backend integration. citeturn50view3
- Pharmacist dashboard’s “exit” behavior shows `context.go('/login')` without evidence of clearing the session. citeturn50view1turn14view0 (This is a logic gap: a route change isn’t a logout.)

This supports your “major issue” statement: roles exist, but the flows are not coherently connected.

### Cubit/state management quality and consistency

The app uses Cubit broadly, but inconsistently in how state maps to UI.

Global provisioning: `main.dart` provides many Cubits at the root (`AuthCubit`, `CartCubit`, `CheckoutCubit`, `HomeCubit`, `OrdersCubit`, `ProductCubit`, `SearchCubit`, etc.). citeturn5view0 This is acceptable for small apps, but in an evaluation-ready architecture it should be more intentional: feature Cubits should be scoped to the feature shell or route subtree to avoid long-lived state leaks and accidental coupling.

Clear mismatch example: Home
- `HomeCubit` maintains `loading` and `activeBanner`. citeturn30view0turn31view0  
- In the `HomeScreen` UI, the only confirmed usage is `state.activeBanner` for carousel indicators; there is no evidence of `state.loading` being used in the home view snippet, even though a `load()` method exists. citeturn32view1turn30view0  
This indicates unused state fields and “generated but not integrated” logic.

CartState bug (high priority, production correctness):
- `CartCubit.removeCoupon()` emits `state.copyWith(couponCode: null)`. citeturn43view1  
- But `CartState.copyWith` uses `couponCode: couponCode ?? this.couponCode`, which makes it impossible to set `couponCode` to null (passing null keeps the existing value). citeturn44view0  
This means “Remove coupon” cannot actually remove the coupon code—an objective correctness bug.

Mock-first state shaping:
- `CartCubit` constructs initial state with pre-filled cart entries from `mockMedicines`. citeturn42view0turn43view1  
For a production-ready UX, the cart should default to empty; demo items should be opt-in (“Load sample cart”).

### Mock data overuse and unclear “real-ready” boundary

Mock data is hardwired into UI in places where it should be abstracted:
- `HomeScreen` constructs product sections by filtering `mockMedicines` and `flashSaleProducts` directly inside the widget. citeturn28view1turn28view0  
- `ProductDetailScreen` directly loads a product from `mockMedicines.firstWhere(...)`. citeturn36view1  
- Role dashboards use `mockOrders`. citeturn50view1turn50view7  

There is nothing wrong with using mock data for an academic evaluation, but it must be isolated behind a repository interface so that:
1) screens present a consistent “production-shaped” contract, and  
2) switching to real APIs later doesn’t require rewriting UI logic.

### UI consistency, “template-generated” signals, responsiveness, accessibility

Good signals already exist:
- The app has reusable design tokens and widgets such as `AppColors`, `AppTextStyles`, and custom UI components (`HealMealAppBar`, `HealMealBottomNav`, `ProductCard`). citeturn28view0turn36view3  
- Some responsive decisions exist (e.g., dynamic `crossAxisCount` based on width, and `AppLayout.isCompactPhone`). citeturn32view1turn36view2  
- Search UI includes explicit status-based rendering including skeleton loading and empty states. citeturn36view2turn50view10  

But there are still high-impact polish gaps for an evaluator:
- Core UI flows are scattered across mega-files, which encourages inconsistent spacing, repeated patterns, and “random styling.” The file sizes alone demonstrate this risk. citeturn27view0turn48view2turn48view1  
- Current role dashboards contain placeholder interactions and copy implying incomplete system behavior (e.g., admin message about backend integration). citeturn50view3  
- Navigation to “logout” is not systematically implemented in role dashboards (no verified `logout()` usage; no clear clearing of session state). citeturn50view6turn14view0turn20view0  

## Target production-quality structure and refactor blueprint

This section is the concrete “polish pass” blueprint: what to change, where, and why—so the final project is coherent, explainable, and does not look AI-generated.

### Target folder structure

You requested a standardized structure. The repo is already close at the top level (`core/`, `features/`), but the main change is to eliminate the page-mega-files and move implementations back into their owning features.

Adopt this structure:

```text
lib/
  main.dart
  app.dart

  core/
    constants/
      app_colors.dart
      app_spacing.dart
      app_radius.dart
      app_text_styles.dart
    theme/
      app_theme.dart
      light_theme.dart
      dark_theme.dart
    router/
      app_router.dart
      route_names.dart
      route_guards.dart
    session/
      session_cubit.dart
      session_state.dart
      session_storage.dart
    utils/
      app_formatters.dart
      app_layout.dart
      app_validators.dart

  shared/
    widgets/
      (only truly reusable widgets)
    states/
      ui_status.dart (loading/empty/error modeling)

  features/
    auth/
      presentation/
        login_screen.dart
        otp_screen.dart
        registration_screen.dart
      cubit/
        auth_cubit.dart
        auth_state.dart

    home/
      presentation/
        home_screen.dart
        main_shell.dart
      cubit/
        home_cubit.dart
        home_state.dart

    products/
      presentation/
        product_list_screen.dart
        product_detail_screen.dart
        brand_screen.dart
        category_home_screen.dart
      cubit/
        product_cubit.dart
        product_state.dart

    search/
      presentation/
        search_screen.dart
      cubit/
        search_cubit.dart
        search_state.dart

    cart/
      presentation/
        cart_screen.dart
      cubit/
        cart_cubit.dart
        cart_state.dart

    checkout/
      presentation/
        checkout_screen.dart
        order_confirmation_screen.dart
      cubit/
        checkout_cubit.dart
        checkout_state.dart

    orders/
      presentation/
        order_history_screen.dart
        order_detail_screen.dart
      cubit/
        orders_cubit.dart
        orders_state.dart

    roles/
      admin/
        presentation/admin_dashboard_screen.dart
      pharmacist/
        presentation/pharmacist_dashboard_screen.dart
        presentation/prescription_review_screen.dart
      rider/
        presentation/rider_dashboard_screen.dart
        presentation/rider_order_detail_screen.dart
      lab_tech/
        presentation/lab_tech_dashboard_screen.dart
      business/
        presentation/business_dashboard_screen.dart
```

The “must-do” action here is to delete or dramatically shrink `features/shared/*.dart` page aggregators by migrating the classes they contain into the correct feature folders. The current “shared pages” files are far too large and multi-domain to keep as-is. citeturn48view2turn48view1turn35view0turn27view0

### Migration plan: replacing export-wrapper screens

Remove the pattern where feature screens are one-line exports (for example `search_screen.dart` exporting from product pages). citeturn38view0turn35view0  
After migration, each feature’s `presentation/` screen file should contain the actual widget implementation.

This makes the project immediately more credible to evaluators because:
- files match their names
- imports make sense
- features are explainable (“auth has auth screens”, “products has product screens”)

### Central principle: isolate mock data behind repositories

Keep mock data, but remove “UI reads global mock list directly”:
- move `mockMedicines` / `flashSaleProducts` access into a `MockProductRepository`
- move `mockOrders` usage into a `MockOrdersRepository` or—since you already have `OrdersCubit`—ensure dashboards read `OrdersCubit` state rather than global lists citeturn50view1turn50view7turn36view1turn28view1

This meets your “mock data only where needed” requirement without needing backend work.

## Mandatory fixes with concrete implementation guidance

### Role-based system

You required roles: User, Admin, Business, Pharmacist, Rider, Lab Tech. The current system uses `patient` as the end-user role and persists role via `AppSession`. citeturn14view0turn49view1

Refinement goals:
1) Make the user role naming consistent (“User” in UI, `patient` or `user` internally—pick one).
2) Ensure every role has:
   - login → OTP verification → role dashboard route
   - restricted routes enforced by the router
   - coherent dashboard tasks connected to the same order lifecycle store

Concrete changes:

- Introduce a strongly typed role model:

```dart
enum UserRole {
  user('user'),
  admin('admin'),
  business('business'),
  pharmacist('pharmacist'),
  rider('rider'),
  labTech('lab_tech');

  const UserRole(this.id);
  final String id;

  static UserRole fromId(String id) {
    return UserRole.values.firstWhere(
      (r) => r.id == id,
      orElse: () => UserRole.user,
    );
  }
}
```

- Update login roles list to use a single source of truth. Today, roles are hard-coded in `LoginScreen` as tuples. citeturn49view1turn49view0 Move this list to `core/session/user_role.dart` and render it consistently.
- Fix logout: dashboards should call `AuthCubit.logout()` which clears session in `AppSession.clear()`. citeturn20view0turn14view0 Right now, at least one dashboard simply navigates to `/login`. citeturn50view1 This must be changed to a real logout action.

- Connect staff dashboards to shared order state:
  - Pharmacist dashboard currently uses `mockOrders.take(3)`. citeturn50view1turn50view7 Change it to read from `OrdersCubit` (which already exists and is referenced from order detail screens). citeturn50view10turn53view0
  - Admin dashboard should also read centralized state and perform real state transitions rather than placeholder text. citeturn50view3turn53view0

### Navigation cleanup and AppRouter standardization

The router already enforces auth and role redirection. citeturn15view0turn15view2 The key improvements are:

- Break `app_router.dart` into smaller, feature-owned route lists (auth routes, patient routes, staff routes).
- Replace the special-cased cart tab behavior. The current `MainShell` maps bottom nav indices and pushes `/cart` as a special case. citeturn28view0 The clean fix is to make cart its own `StatefulShellBranch`, so indices are 1:1 and back stacks are predictable.

- Make auth reactive: `AppSession` is static and not inherently reactive. citeturn14view0turn15view0 A production pattern is:
  - `SessionCubit` reads/writes `AppSession`
  - `GoRouter` refreshes when `SessionCubit` changes (so redirects apply immediately)

Even if you keep `AppSession`, the router should refresh on auth state changes rather than relying on manual navigation.

### State management standardization

You requested “one Cubit per feature, clean state classes, no logic inside UI.” The codebase partially follows this, but also violates it heavily by embedding data selection in UI (home/product detail) and by keeping “unused state fields” (home loading). citeturn28view1turn36view1turn31view0turn32view1

Concrete fixes:

- Home feature:
  - If home loading is not used, remove it. The current `HomeState` contains `loading`, but UI evidence shows usage of `activeBanner`. citeturn31view0turn32view1
  - Move product section building (filtering mock lists) into `HomeCubit` or a repository.

- Product feature:
  - Stop reading `mockMedicines` directly in `ProductDetailScreen`. citeturn36view1 Use `ProductCubit` (already called in `ProductListScreen`) as the single entry point for “get product by id” and “get related products.” citeturn36view2turn53view4

- Orders feature:
  - Use `OrdersCubit` as the central lifecycle store for:
    - placing orders from checkout
    - exposing order history to the user
    - exposing queues to staff roles (pharmacist/rider/admin/lab).  
    You already have `OrdersCubit` shaping order data and emitting an updated list. citeturn53view0turn50view10

### Checkout and order lifecycle completeness

There is evidence of a cart → checkout transition and Rx gating:
- Cart shows an Rx warning banner and forces prescription upload before continuing if Rx products exist. citeturn51view0turn49view10
- Cart proceeds with `context.push('/checkout')`. citeturn51view0turn15view1

Order history and order details exist:
- `OrderHistoryScreen` and `OrderDetailScreen` are present. citeturn49view12turn50view10  
- `OrderDetailScreen` has an explicit empty state if order is missing (`EmptyStateWidget`). citeturn50view10  
- Orders include lifecycle status filtering via `OrderStatus.*`. citeturn50view11turn53view0  

To make this evaluation-ready:
- Ensure checkout places an order into `OrdersCubit`, stores `lastPlacedOrderId`, and navigates to confirmation screen in a consistent way (router-driven). The OrdersCubit snippet shows it sets `lastPlacedOrderId` and emits updated orders list. citeturn53view0turn53view1
- Ensure order confirmation reads `OrdersCubit.lastPlacedOrderId` and displays correct information. Order confirmation screen exists and imports OrdersCubit. citeturn50view9turn51view0
- Ensure “order lifecycle” actions exist and are coherent:
  - Admin: confirm / assign rider / cancel
  - Pharmacist: approve Rx (should unlock Rx within order)
  - Rider: mark out-for-delivery / delivered  
  You have UI shells for these roles, but they are currently mock-driven and partially placeholder. citeturn50view1turn50view3turn50view2

### Critical bug fixes you must apply

Cart coupon clearing bug (must fix immediately):
- Current situation: `CartCubit.removeCoupon()` attempts to clear coupon, but `CartState.copyWith` cannot set `couponCode` to null. citeturn43view1turn44view0

Fix pattern (sentinel approach):

```dart
class CartState extends Equatable {
  static const _unset = Object();

  CartState copyWith({
    List<CartEntry>? items,
    Object? couponCode = _unset, // allow explicit null
    bool? cashbackEnabled,
    PaymentMethod? selectedPaymentMethod,
    Set<String>? notifiedProductIds,
    bool? hasApprovedPrescription,
  }) {
    return CartState(
      items: items ?? this.items,
      couponCode: identical(couponCode, _unset)
          ? this.couponCode
          : couponCode as String?, // may be null
      cashbackEnabled: cashbackEnabled ?? this.cashbackEnabled,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      notifiedProductIds: notifiedProductIds ?? this.notifiedProductIds,
      hasApprovedPrescription:
          hasApprovedPrescription ?? this.hasApprovedPrescription,
    );
  }
}
```

Then `removeCoupon()` works as intended, because `couponCode: null` actually clears it. citeturn43view1turn44view0

Cart default contents (polish requirement):
- `CartCubit` currently seeds the cart with demo items from `mockMedicines`. citeturn42view0turn43view1  
Change to start empty and add a “Load demo cart” button in UI (or a debug toggle) so the default UX is realistic.

## Cleanup checklist and “premium feel” UI polish pass

### Remove AI-artifact patterns and dead weight

The following removals/refactors are mandatory to meet the “does not look AI-generated” standard:

- Remove `features/shared/*_pages.dart` mega-files by migrating code into feature folders. This is the primary cleanup. citeturn48view2turn48view1turn35view0turn27view0
- Remove feature “screen” files that are only exports (e.g., `search_screen.dart`, `cart_screen.dart`, `home_screen.dart`, `login_screen.dart`). citeturn38view0turn40view0turn26view0turn23view0
- Minimize placeholder copy that undermines credibility (e.g., admin “requires backend integration” message). Replace with “Demo Mode: Using local data store” and describe what’s simulated. citeturn50view3turn50view1

### UI/UX design system enforcement

You already have design tokens and custom UI components in use (colors, text styles, shared widgets). citeturn28view0turn36view3turn51view0 The polish pass is to enforce them consistently:

- Replace ad-hoc `EdgeInsets` with `AppSpacing` tokens across screens (4/8 scale, consistent vertical rhythm).
- Normalize radius usage via `AppRadius` (already referenced in cart item UI). citeturn51view0turn50view10
- Reduce visual clutter on Home: Home currently packs many categories and sections in one scroll view. citeturn28view1turn32view1 Make a single primary CTA per screen (e.g., search + featured categories + one curated section + “See all”).

### Accessibility and feedback states

Evidence shows some feedback and empty-state patterns exist (`SnackBar` in role actions, `EmptyStateWidget` in order detail, skeletons in search). citeturn50view0turn50view10turn36view2 Standardize these patterns:

- Every async action should have:
  - loading indicator (button disabled + spinner)
  - error state and retry
  - empty state where collections can be empty
- Add semantics labels for icon-only buttons (search/cart/favorite). Favorites exist via wishlist toggle. citeturn36view3turn28view1

## Mandatory documentation deliverables

Below are production-quality drafts you can commit as `README.md` and `BEGINNER_GUIDE.md`. They are written to align with the actual codebase realities discovered above (role-based routing, Cubit, offline mock data), while presenting it cleanly and credibly.

### README.md

```md
# HealMeal

HealMeal is a Flutter demo application that simulates a healthcare + pharmacy commerce experience:
users can browse products, add items to a cart, place an order, and track the order lifecycle.
The project also includes multiple staff dashboards (Admin, Pharmacist, Rider, Lab Tech, Business)
to demonstrate role-based navigation and authorization.

> Note: This project runs in **Demo Mode** using local mock data. The structure is designed to be
> backend-ready (replace mock repositories with API repositories later).

## Key Features

User (Customer)
- Splash → Onboarding → Login (OTP) → Home
- Browse products, product details, and search
- Wishlist (stored locally)
- Cart with coupon + pricing summary
- Checkout → Order confirmation
- Order history and order tracking

Staff Roles (Role-Based Dashboards)
- Admin: overview and basic order management actions (demo)
- Pharmacist: prescription review and approval (demo)
- Rider: delivery workflow and marking delivered (demo)
- Lab Tech: lab task workflow (demo)
- Business: partner dashboard (demo)

## Folder Structure

```text
lib/
  core/          # shared infrastructure: router, theme, session, utilities
  shared/        # reusable UI widgets and shared UI state helpers
  features/      # feature modules (auth, home, products, cart, checkout, orders, roles)
  main.dart
  app.dart
```

## How to Run

### Requirements
- Flutter SDK installed (stable channel)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code recommended

### Steps
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run on a device/emulator:
   ```bash
   flutter run
   ```

## Demo Login Notes (OTP)
- Enter a valid phone number format allowed by the app
- Use the demo OTP rule (as configured in the AuthCubit)
- Select a role on the login screen to enter the correct dashboard

## Tech Stack
- Flutter + Material
- go_router for routing
- flutter_bloc (Cubit) for state management
- SharedPreferences for lightweight local persistence (session, wishlist)
```

### BEGINNER_GUIDE.md

```md
# Beginner Guide: HealMeal

This guide explains what HealMeal does and how the code is organized, in simple terms.

## What the app does

HealMeal is a demo app that looks like a pharmacy/healthcare ordering app.

As a User (Customer), you can:
- Sign in (OTP demo)
- Browse products
- Add products to your cart
- Checkout and place an order
- Track your order status

As Staff, you can log in as:
- Admin
- Pharmacist
- Rider
- Lab Tech
- Business

Each staff role has its own dashboard to demonstrate role-based access.

## How roles work

During login you select a role. After OTP verification, the role is stored locally and the app
redirects you to the correct dashboard.

Examples:
- User → Home (shopping flow)
- Pharmacist → Pharmacist dashboard (prescription review)
- Rider → Rider dashboard (deliveries)
- Admin → Admin dashboard

The router restricts access so a User cannot open staff routes.

## How navigation works

Navigation is managed by go_router inside:
- `lib/core/router/app_router.dart`

The main flow is:
Splash → Onboarding → Auth → Main Area

The “User” area uses a bottom navigation shell.
Staff roles do not use the user bottom navigation; they go directly to their role dashboards.

## How state management works (Cubit)

The app uses Cubits (from flutter_bloc). A Cubit:
- holds a piece of state (example: cart items)
- exposes methods (example: addItem, removeItem)
- the UI listens to state changes and rebuilds

Main Cubits:
- AuthCubit: OTP and login state
- CartCubit: cart operations and totals
- OrdersCubit: stores orders and order status updates
- ProductCubit / SearchCubit: product listing and searching

## Mock data (Demo Mode)

This project runs without a backend.
Instead, it uses mock products and mock orders.

Important:
- UI should not directly read the mock lists
- mock data should be accessed through a repository or a Cubit
This makes it easy to replace mock data with real APIs later.

## Where to start reading code

If you are new, read in this order:
1) `lib/main.dart` (app startup and providers)
2) `lib/core/router/app_router.dart` (routes and role guard)
3) `lib/features/auth/...` (login + OTP)
4) `lib/features/home/...` (user home)
5) `lib/features/cart/...` (cart flow)
6) `lib/features/checkout/...` (place order)
7) `lib/features/orders/...` (order history & tracking)
8) `lib/features/roles/...` (staff dashboards)
```

---

### Why these docs are consistent with the current repo

- Role selection exists on login and is stored, enabling role dashboards. citeturn49view1turn20view0turn14view0  
- Role routes and guards exist in the router. citeturn15view0turn15view2  
- Core user flows exist: cart → checkout navigation, orders history/detail, and order confirmation screen. citeturn51view0turn49view12turn50view10turn50view9  

## Final “pre-evaluation polish pass” acceptance criteria

If you implement the blueprint above, the project will meet your stated objective:

- It will no longer look AI-generated because:
  - feature files contain real implementations, not export stubs citeturn23view0turn38view0turn40view0turn26view0
  - mega “shared pages” files are eliminated or reduced to true shared widgets citeturn48view2turn48view1turn35view0turn27view0
- Role-based structure will be coherent because:
  - roles are selected at login (already exists) citeturn49view1turn49view0
  - router enforces role gates (already exists) citeturn15view0turn15view2
  - dashboards read from the same order lifecycle store (new requirement; currently mock-driven) citeturn50view1turn53view0
- Navigation will be clean because:
  - AppRouter remains the single authority but is modularized
  - bottom-nav cart special-casing is removed citeturn28view0
- UX will feel premium because:
  - spacing/typography/token usage is consistent (you already have tokens to build on) citeturn28view0turn51view0turn36view3
  - loading/empty/error states are standardized (patterns already exist in search and orders) citeturn36view2turn50view10
- Critical correctness bugs are removed (coupon clearing bug) citeturn43view1turn44view0