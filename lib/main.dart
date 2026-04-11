import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/cubits/wishlist_cubit.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/app_session.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/checkout/cubit/checkout_cubit.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/orders/cubit/orders_cubit.dart';
import 'features/products/cubit/product_cubit.dart';
import 'features/search/cubit/search_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        BlocProvider(create: (_) => CheckoutCubit()),
        BlocProvider(create: (_) => HomeCubit()..load()),
        BlocProvider(create: (_) => OrdersCubit()..load()),
        BlocProvider(create: (_) => ProductCubit()..load()),
        BlocProvider(create: (_) => SearchCubit()),
      ],
      child: const HealMealApp(),
    ),
  );
}
