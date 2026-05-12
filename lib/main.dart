import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/cubits/wishlist_cubit.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/app_session.dart';
import 'core/utils/database_initializer.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/checkout/cubit/checkout_cubit.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/orders/cubit/orders_cubit.dart';
import 'features/products/cubit/product_cubit.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/lab_test_repository.dart';
import 'core/repositories/prescription_repository.dart';
import 'features/lab_tests/cubit/lab_test_cubit.dart';
import 'features/prescriptions/cubit/prescription_cubit.dart';
import 'core/repositories/user_repository.dart';
import 'core/repositories/offer_repository.dart';
import 'core/repositories/suggestion_repository.dart';
import 'core/repositories/lab_repository.dart';
import 'features/roles/admin/cubit/admin_cubit.dart';
import 'features/roles/lab_tech/cubit/lab_tech_cubit.dart';
import 'features/roles/pharmacist/cubit/pharmacist_cubit.dart';
import 'features/roles/rider/cubit/rider_cubit.dart';
import 'features/search/cubit/search_cubit.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize services in background
    NotificationService.init();
    await setupServiceLocator();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  await AppSession.init();

  final themeCubit = ThemeCubit();
  final localeCubit = LocaleCubit();
  final wishlistCubit = WishlistCubit();

  await Future.wait<void>([
    themeCubit.loadSavedTheme(),
    localeCubit.loadSavedLocale(),
    wishlistCubit.load(),
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: wishlistCubit),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => CartCubit()),
      ],
      child: const HealMealApp(),
    ),
  );
}

