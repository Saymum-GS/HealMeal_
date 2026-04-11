import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class HealMealBottomNav extends StatelessWidget {
  const HealMealBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    const items = [
      (label: 'Home', icon: Icons.home_rounded),
      (label: 'Categories', icon: Icons.grid_view_rounded),
      (label: 'Cart', icon: Icons.shopping_cart_rounded),
      (label: 'Lab Test', icon: Icons.science_rounded),
      (label: 'Account', icon: Icons.person_rounded),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 22,
          onTap: onTap,
          items: List.generate(items.length, (index) {
            final item = items[index];
            final icon = index == 2
                ? badges.Badge(
                    showBadge: cartCount > 0,
                    badgeContent: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: Icon(item.icon),
                  )
                : Icon(item.icon);
            return BottomNavigationBarItem(
              icon: icon,
              activeIcon: Icon(
                item.icon,
                color: index == 2 ? AppColors.primary : null,
              ),
              label: item.label,
            );
          }),
        ),
      ),
    );
  }
}
