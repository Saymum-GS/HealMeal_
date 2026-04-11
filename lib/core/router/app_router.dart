import 'package:go_router/go_router.dart';

import '../utils/app_session.dart';
import '../../features/account/account_screen.dart';
import '../../features/account/account_settings_screen.dart';
import '../../features/account/add_edit_address_screen.dart';
import '../../features/account/address_book_screen.dart';
import '../../features/account/cashback_wallet_screen.dart';
import '../../features/account/edit_profile_screen.dart';
import '../../features/account/lab_bookings_screen.dart';
import '../../features/account/lab_reports_screen.dart';
import '../../features/account/lab_test_orders_screen.dart';
import '../../features/account/manage_patients_screen.dart';
import '../../features/account/notified_products_screen.dart';
import '../../features/account/notification_screen.dart';
import '../../features/account/product_reviews_screen.dart';
import '../../features/account/refer_and_earn_screen.dart';
import '../../features/account/rider_reviews_screen.dart';
import '../../features/account/special_offers_screen.dart';
import '../../features/account/suggest_product_screen.dart';
import '../../features/account/transaction_history_screen.dart';
import '../../features/account/wishlist_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/registration_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_confirmation_screen.dart';
import '../../features/flash_sale/flash_sale_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/lab_tests/lab_test_booking_screen.dart';
import '../../features/lab_tests/lab_test_detail_screen.dart';
import '../../features/lab_tests/lab_test_home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/offers/offers_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/order_history_screen.dart';
import '../../features/prescriptions/prescription_list_screen.dart';
import '../../features/prescriptions/prescription_upload_screen.dart';
import '../../features/products/brand_screen.dart';
import '../../features/products/category_home_screen.dart';
import '../../features/products/product_detail_screen.dart';
import '../../features/products/product_list_screen.dart';
import '../../features/roles/admin/admin_dashboard_screen.dart';
import '../../features/roles/business/business_dashboard_screen.dart';
import '../../features/roles/lab_tech/lab_tech_dashboard_screen.dart';
import '../../features/roles/pharmacist/pharmacist_dashboard_screen.dart';
import '../../features/roles/pharmacist/prescription_review_screen.dart';
import '../../features/roles/rider/rider_dashboard_screen.dart';
import '../../features/roles/rider/rider_order_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/static/about_us_screen.dart';
import '../../features/static/careers_screen.dart';
import '../../features/static/contact_screen.dart';
import '../../features/static/doctor_consultation_screen.dart';
import '../../features/static/faq_screen.dart';
import '../../features/static/health_tips_blog_screen.dart';
import '../../features/static/privacy_policy_screen.dart';
import '../../features/static/return_policy_screen.dart';
import '../../features/static/terms_screen.dart';

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

bool _canAccessRoleArea(String role, String location) {
  if (_isRolePrefix(location, '/pharmacist')) return role == 'pharmacist';
  if (_isRolePrefix(location, '/rider')) return role == 'rider';
  if (_isRolePrefix(location, '/admin')) return role == 'admin';
  if (_isRolePrefix(location, '/lab-tech')) return role == 'lab_tech';
  if (_isRolePrefix(location, '/account/business')) return role == 'business';
  return true;
}

bool _canAccessPatientArea(String role) {
  return role == 'patient' || role == 'business';
}

String? _redirectGuard(GoRouterState state) {
  final String location = state.uri.path;

  if (!_isPublicLocation(location) && !AppSession.isLoggedIn) {
    return '/login';
  }

  if (AppSession.isLoggedIn &&
      _authEntryRoutes.any((String route) => _matchesPath(location, route))) {
    return AppSession.homeRouteForRole(AppSession.role);
  }

  if (_isRestrictedStaffArea(location) &&
      !_canAccessRoleArea(AppSession.role, location)) {
    return AppSession.homeRouteForRole(AppSession.role);
  }

  if (_isPatientArea(location) && !_canAccessPatientArea(AppSession.role)) {
    return AppSession.homeRouteForRole(AppSession.role);
  }

  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (_, GoRouterState state) => _redirectGuard(state),
  routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, GoRouterState state) =>
          OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
    ),
    GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, __, StatefulNavigationShell navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
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
              builder: (_, __) => const LabTestHomeScreen(),
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
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(
      path: '/category/:slug',
      builder: (_, GoRouterState state) =>
          CategoryHomeScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/products',
      builder: (_, GoRouterState state) =>
          ProductListScreen(queryParams: state.uri.queryParameters),
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
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
    GoRoute(
      path: '/order-confirmed',
      builder: (_, __) => const OrderConfirmationScreen(),
    ),
    GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
    GoRoute(
      path: '/orders/:id',
      builder: (_, GoRouterState state) =>
          OrderDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/prescriptions',
      builder: (_, __) => const PrescriptionListScreen(),
    ),
    GoRoute(
      path: '/prescriptions/upload',
      builder: (_, __) => const PrescriptionUploadScreen(),
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
      path: '/account/addresses',
      builder: (_, __) => const AddressBookScreen(),
    ),
    GoRoute(
      path: '/account/addresses/add',
      builder: (_, __) => const AddEditAddressScreen(),
    ),
    GoRoute(
      path: '/account/cashback',
      builder: (_, __) => const CashbackWalletScreen(),
    ),
    GoRoute(
      path: '/account/notifications',
      builder: (_, __) => const NotificationScreen(),
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
      builder: (_, __) => const SpecialOffersScreen(),
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
      builder: (_, __) => const PharmacistDashboardScreen(),
    ),
    GoRoute(
      path: '/pharmacist/rx/:id',
      builder: (_, GoRouterState state) =>
          PrescriptionReviewScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/rider', builder: (_, __) => const RiderDashboardScreen()),
    GoRoute(
      path: '/rider/order/:id',
      builder: (_, GoRouterState state) =>
          RiderOrderDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(
      path: '/lab-tech',
      builder: (_, __) => const LabTechDashboardScreen(),
    ),
  ],
);
