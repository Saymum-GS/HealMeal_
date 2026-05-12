import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models.dart';
import '../utils/app_session.dart';
import '../di/service_locator.dart';
import '../../features/account/account_screens.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_state.dart';
import '../../features/cart/cart_screens.dart';
import '../../features/checkout/checkout_screens.dart';
import '../../features/checkout/cubit/checkout_cubit.dart';
import '../../features/orders/order_tracking_screens.dart';
import '../../features/orders/cubit/orders_cubit.dart';
import '../../features/flash_sale/flash_sale_screens.dart';
import '../../features/home/home_screens.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/lab_tests/lab_screens.dart';
import '../../features/lab_tests/cubit/lab_test_cubit.dart';
import '../../features/offers/offers_screens.dart';
import '../../features/prescriptions/prescription_screens.dart';
import '../../features/prescriptions/cubit/prescription_cubit.dart';
import '../../features/products/product_screens.dart';
import '../../features/products/cubit/product_cubit.dart';
import '../../features/roles/role_screens.dart';
import '../../features/roles/admin/admin_products_screen.dart';
import '../../features/roles/admin/admin_offers_screen.dart';
import '../../features/roles/admin/admin_suggestion_screen.dart';
import '../../features/roles/admin/admin_lab_bookings_screen.dart';
import '../../features/roles/admin/admin_categories_screen.dart';
import '../../features/roles/admin/cubit/admin_cubit.dart';
import '../../features/roles/lab_tech/cubit/lab_tech_cubit.dart';
import '../../features/roles/pharmacist/cubit/pharmacist_cubit.dart';
import '../../features/roles/rider/cubit/rider_cubit.dart';
import '../../features/search/search_screens.dart';
import '../../features/search/cubit/search_cubit.dart';
import '../../features/static/static_screens.dart';
import '../repositories/product_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/lab_test_repository.dart';
import '../repositories/prescription_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/offer_repository.dart';
import '../repositories/suggestion_repository.dart';
import '../repositories/lab_repository.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._authCubit) {
    _authCubit.stream.listen((state) {
      notifyListeners();
    });
  }

  final AuthCubit _authCubit;
}

const Set<String> _authEntryRoutes = <String>{
  '/splash',
  '/onboarding',
  '/login',
  '/otp',
  '/register',
};

const Set<String> _publicRoutes = <String>{
  '/about',
  '/blog',
  '/contact',
  '/doctor-consultation',
  '/faq',
  '/jobs',
  '/privacy',
  '/return-policy',
  '/terms',
};

bool _matchesPath(String location, String route) {
  return location == route || location.startsWith('$route/');
}

bool _isPublicLocation(String location) {
  for (final String route in _authEntryRoutes) {
    if (_matchesPath(location, route)) return true;
  }
  for (final String route in _publicRoutes) {
    if (_matchesPath(location, route)) return true;
  }
  return false;
}

bool _isRolePrefix(String location, String prefix) =>
    _matchesPath(location, prefix);

bool _isRestrictedStaffArea(String location) {
  return _isRolePrefix(location, '/pharmacist') ||
      _isRolePrefix(location, '/rider') ||
      _isRolePrefix(location, '/admin') ||
      _isRolePrefix(location, '/lab-tech') ||
      _isRolePrefix(location, '/account/business');
}

bool _isPatientArea(String location) {
  const List<String> patientPrefixes = <String>[
    '/account',
    '/brand',
    '/cart',
    '/categories',
    '/category',
    '/checkout',
    '/flash-sale',
    '/home',
    '/lab-test',
    '/offers',
    '/order-confirmed',
    '/orders',
    '/prescriptions',
    '/product',
    '/products',
    '/search',
  ];

  for (final String prefix in patientPrefixes) {
    if (_matchesPath(location, prefix)) return true;
  }
  return false;
}

bool _canAccessRoleArea(UserRole role, String location) {
  if (_isRolePrefix(location, '/pharmacist')) return role == UserRole.pharmacist;
  if (_isRolePrefix(location, '/rider')) return role == UserRole.rider;
  if (_isRolePrefix(location, '/admin')) return role == UserRole.admin;
  if (_isRolePrefix(location, '/lab-tech')) return role == UserRole.labTech;
  if (_isRolePrefix(location, '/account/business')) {
    return role == UserRole.business;
  }
  return true;
}

bool _canAccessPatientArea(UserRole role) {
  return role == UserRole.patient;
}

String? _redirectGuard(GoRouterState state) {
  final String location = state.uri.path;
  final UserRole role = AppSession.currentUserRole;

  if (!_isPublicLocation(location) && !AppSession.isLoggedIn) {
    return '/login';
  }

  if (AppSession.isLoggedIn &&
      _authEntryRoutes.any((String route) => _matchesPath(location, route))) {
    return AppSession.homeRouteForRole(role);
  }

  if (_isRestrictedStaffArea(location) && !_canAccessRoleArea(role, location)) {
    return AppSession.homeRouteForRole(role);
  }

  if (_isPatientArea(location) && !_canAccessPatientArea(role)) {
    // Admins should be able to see patient areas for debugging, but let's stick to strict isolation for now
    return AppSession.homeRouteForRole(role);
  }

  return null;
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: RouterNotifier(authCubit),
    redirect: (_, GoRouterState state) => _redirectGuard(state),
    routes: <RouteBase>[
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, StatefulNavigationShell navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (context, state) => BlocProvider(
                  create: (context) => HomeCubit(
                    offerRepository: getIt<OfferRepository>(),
                  )..load(),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/categories',
                builder: (_, __) => const CategoryListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/lab-test',
                builder: (context, state) => BlocProvider(
                  create: (context) => LabTestCubit(
                    repository: getIt<LabTestRepository>(),
                  )..load(),
                  child: const LabTestHomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/account',
                builder: (_, __) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/flash-sale', builder: (_, __) => const FlashSaleScreen()),
      GoRoute(path: '/offers', builder: (_, __) => const OffersScreen()),
      GoRoute(
        path: '/search',
        builder: (context, __) => BlocProvider(
          create: (context) => SearchCubit(),
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/category/:slug',
        builder: (_, GoRouterState state) =>
            CategoryHomeScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/products',
        builder: (context, GoRouterState state) => BlocProvider(
          create: (context) => ProductCubit()..load(),
          child: ProductListScreen(queryParams: state.uri.queryParameters),
        ),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, GoRouterState state) =>
            ProductDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/brand/:id',
        builder: (_, GoRouterState state) =>
            BrandScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, __) => BlocProvider(
          create: (context) => CheckoutCubit(),
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/order-confirmed',
        builder: (_, __) => const OrderConfirmationScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, __) => BlocProvider(
          create: (context) => OrdersCubit()..load(),
          child: const OrderHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, GoRouterState state) =>
            OrderDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/prescriptions',
        builder: (context, __) => BlocProvider(
          create: (context) => PrescriptionCubit(
            repository: getIt<PrescriptionRepository>(),
          ),
          child: const PrescriptionListScreen(),
        ),
      ),
      GoRoute(
        path: '/prescriptions/upload',
        builder: (context, __) => BlocProvider(
          create: (context) => PrescriptionCubit(
            repository: getIt<PrescriptionRepository>(),
          ),
          child: const PrescriptionUploadScreen(),
        ),
      ),
      GoRoute(
        path: '/lab-test/:id',
        builder: (_, GoRouterState state) =>
            LabTestDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lab-test/book/:id',
        builder: (_, GoRouterState state) =>
            LabTestBookingScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/account/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/account/initialAddresses',
        builder: (_, __) => const AddressBookScreen(),
      ),
      GoRoute(
        path: '/account/initialAddresses/add',
        builder: (_, __) => const AddEditAddressScreen(),
      ),
      GoRoute(
        path: '/account/cashback',
        builder: (_, __) => const CashbackWalletScreen(),
      ),
      GoRoute(
        path: '/account/notifications',
        builder: (_, __) => const NotificationListScreen(),
      ),
      GoRoute(
        path: '/account/product-reviews',
        builder: (_, __) => const ProductReviewsScreen(),
      ),
      GoRoute(
        path: '/account/rider-reviews',
        builder: (_, __) => const RiderReviewsScreen(),
      ),
      GoRoute(
        path: '/account/settings',
        builder: (_, __) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/account/lab-orders',
        builder: (_, __) => const LabTestOrdersScreen(),
      ),
      GoRoute(
        path: '/account/lab-bookings',
        builder: (_, __) => const LabBookingsScreen(),
      ),
      GoRoute(
        path: '/account/lab-reports',
        builder: (_, __) => const LabReportsScreen(),
      ),
      GoRoute(
        path: '/account/manage-patients',
        builder: (_, __) => const ManagePatientsScreen(),
      ),
      GoRoute(
        path: '/account/wishlist',
        builder: (_, __) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/account/notified-products',
        builder: (_, __) => const NotifiedProductsScreen(),
      ),
      GoRoute(
        path: '/account/suggest-product',
        builder: (_, __) => const SuggestProductScreen(),
      ),
      GoRoute(
        path: '/account/transactions',
        builder: (_, __) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/account/offers',
        builder: (_, __) => const OffersScreen(),
      ),
      GoRoute(
        path: '/account/referral',
        builder: (_, __) => const ReferAndEarnScreen(),
      ),
      GoRoute(
        path: '/account/business',
        builder: (_, __) => const BusinessDashboardScreen(),
      ),
      GoRoute(path: '/about', builder: (_, __) => const AboutUsScreen()),
      GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
      GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
      GoRoute(
        path: '/return-policy',
        builder: (_, __) => const ReturnPolicyScreen(),
      ),
      GoRoute(path: '/blog', builder: (_, __) => const HealthTipsBlogScreen()),
      GoRoute(
        path: '/doctor-consultation',
        builder: (_, __) => const DoctorConsultationScreen(),
      ),
      GoRoute(path: '/jobs', builder: (_, __) => const CareersScreen()),
      GoRoute(
        path: '/pharmacist',
        builder: (context, __) => BlocProvider(
          create: (context) => PharmacistCubit(),
          child: const PharmacistDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/pharmacist/rx/:id',
        builder: (context, GoRouterState state) => BlocProvider(
          create: (context) => PharmacistCubit(),
          child: PrescriptionReviewScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/pharmacist/prescription/:id',
        builder: (context, GoRouterState state) => BlocProvider(
          create: (context) => PharmacistCubit(),
          child: PrescriptionReviewScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/rider',
        builder: (context, __) => BlocProvider(
          create: (context) => RiderCubit(
            orderRepository: getIt<OrderRepository>(),
          ),
          child: const RiderDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/rider/order/:id',
        builder: (context, GoRouterState state) => BlocProvider(
          create: (context) => RiderCubit(
            orderRepository: getIt<OrderRepository>(),
          ),
          child: RiderOrderDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const UserManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/products/add',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const ProductFormScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const AdminProductListScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/offers',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const AdminOfferManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/suggestions',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const AdminSuggestionScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/lab-bookings',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const AdminLabBookingScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, __) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: const AdminCategoryScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/products/edit/:id',
        builder: (context, GoRouterState state) => BlocProvider(
          create: (context) => AdminCubit(
            orderRepository: getIt<OrderRepository>(),
            userRepository: getIt<UserRepository>(),
            offerRepository: getIt<OfferRepository>(),
            suggestionRepository: getIt<SuggestionRepository>(),
            labRepository: getIt<LabRepository>(),
          ),
          child: ProductFormScreen(productId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/admin/lab-tech',
        builder: (context, __) => BlocProvider(
          create: (context) => LabTechCubit(
            labRepository: getIt<LabRepository>(),
          ),
          child: const LabTechDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/lab-tech',
        builder: (context, __) => BlocProvider(
          create: (context) => LabTechCubit(
            labRepository: getIt<LabRepository>(),
          ),
          child: const LabTechDashboardScreen(),
        ),
      ),
    ],
  );
}
