import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/common/healmeal_bottom_nav.dart';
import '../cart/cubit/cart_cubit.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartCubit>().totalCount;
    final currentIndex = switch (navigationShell.currentIndex) {
      0 => 0,
      1 => 1,
      2 => 3,
      3 => 4,
      _ => 0,
    };
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: HealMealBottomNav(
        currentIndex: currentIndex,
        cartCount: cartCount,
        onTap: (index) {
          if (index == 2) {
            context.push('/cart');
            return;
          }
          final branch = switch (index) {
            0 => 0,
            1 => 1,
            3 => 2,
            4 => 3,
            _ => 0,
          };
          navigationShell.goBranch(branch);
        },
      ),
    );
  }
}
