import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healmeal_app/app.dart';
import 'package:healmeal_app/core/cubits/wishlist_cubit.dart';
import 'package:healmeal_app/core/localization/locale_cubit.dart';
import 'package:healmeal_app/core/theme/theme_cubit.dart';
import 'package:healmeal_app/features/auth/cubit/auth_cubit.dart';
import 'package:healmeal_app/features/cart/cubit/cart_cubit.dart';
import 'package:healmeal_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:healmeal_app/features/home/cubit/home_cubit.dart';
import 'package:healmeal_app/features/orders/cubit/orders_cubit.dart';
import 'package:healmeal_app/features/products/cubit/product_cubit.dart';
import 'package:healmeal_app/features/search/cubit/search_cubit.dart';
import 'package:healmeal_app/core/repositories/offer_repository.dart';

void main() {
  testWidgets('app boots into the auth flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final ThemeCubit themeCubit = ThemeCubit();
    final LocaleCubit localeCubit = LocaleCubit();
    final WishlistCubit wishlistCubit = WishlistCubit();

    await Future.wait<void>(<Future<void>>[
      themeCubit.loadSavedTheme(),
      localeCubit.loadSavedLocale(),
      wishlistCubit.load(),
    ]);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<LocaleCubit>.value(value: localeCubit),
          BlocProvider<WishlistCubit>.value(value: wishlistCubit),
          BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
          BlocProvider<CartCubit>(create: (_) => CartCubit()),
          BlocProvider<CheckoutCubit>(create: (_) => CheckoutCubit()),
          BlocProvider<HomeCubit>(create: (_) => HomeCubit(offerRepository: OfferRepository())..load()),
          BlocProvider<OrdersCubit>(create: (_) => OrdersCubit()..load()),
          BlocProvider<ProductCubit>(create: (_) => ProductCubit()..load()),
          BlocProvider<SearchCubit>(create: (_) => SearchCubit()),
        ],
        child: const HealMealApp(),
      ),
    );

    expect(find.text('HealMeal'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
  });
}
