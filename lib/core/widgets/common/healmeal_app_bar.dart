import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'brand_lockup.dart';
import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/cart/cubit/cart_state.dart';

class HealMealAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HealMealAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.showSearch = false,
    this.showCart = false,
    this.transparent = false,
    this.actions,
  });

  final String? title;
  final bool showBack;
  final bool showSearch;
  final bool showCart;
  final bool transparent;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final fg = transparent
        ? AppColors.white
        : Theme.of(context).colorScheme.onSurface;
    return AppBar(
      backgroundColor: transparent ? Colors.transparent : null,
      leadingWidth: showBack ? null : 60,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: fg),
              onPressed: () => context.pop(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Image.asset(
                  AppAssets.logo,
                  height: 34,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_hospital_rounded),
                ),
              ),
            ),
      title: title == null
          ? BrandLockup(onDark: transparent)
          : Text(title!, style: AppTextStyles.h2.copyWith(color: fg)),
      centerTitle: showBack,
      actions: [
        if (showSearch)
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Icons.search_rounded, color: fg),
          ),
        if (showCart)
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final count = context.read<CartCubit>().totalCount;
              return IconButton(
                onPressed: () => context.push('/cart'),
                icon: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -8, end: -10),
                  showBadge: count > 0,
                  badgeContent: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Icon(Icons.shopping_cart_outlined, color: fg),
                ),
              );
            },
          ),
        ...?actions,
      ],
    );
  }
}

