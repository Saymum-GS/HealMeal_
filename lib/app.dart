import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/localization/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

import 'features/auth/cubit/auth_cubit.dart';

class HealMealApp extends StatefulWidget {
  const HealMealApp({super.key});

  @override
  State<HealMealApp> createState() => _HealMealAppState();
}

class _HealMealAppState extends State<HealMealApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: 'HealMeal',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('bn')],
              localizationsDelegates: AppTheme.localizationsDelegates,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}

