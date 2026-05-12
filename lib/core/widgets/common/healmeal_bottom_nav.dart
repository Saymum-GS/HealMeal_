import 'dart:ui';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

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
      (label: 'Home', icon: Icons.home_rounded, activeIcon: Icons.home_rounded),
      (label: 'Categories', icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded),
      (label: 'Cart', icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded),
      (label: 'Lab Test', icon: Icons.science_outlined, activeIcon: Icons.science_rounded),
      (label: 'Account', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : AppColors.white;
    final selectedColor = isDark ? AppColors.accentTeal : AppColors.primary;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: navBg.withOpacity(0.92),
            border: Border(
              top: BorderSide(
                color: (isDark ? AppColors.darkBorder : AppColors.border).withOpacity(0.5),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = currentIndex == index;
                  final isCart = index == 2;

                  Widget iconWidget = Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: isCart ? 26 : 22,
                    color: isSelected ? selectedColor : AppColors.muted,
                  );

                  if (isCart && cartCount > 0) {
                    iconWidget = badges.Badge(
                      badgeContent: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: AppColors.accentRed,
                        padding: const EdgeInsets.all(4),
                        elevation: 0,
                      ),
                      position: badges.BadgePosition.topEnd(top: -6, end: -8),
                      child: iconWidget,
                    );
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          vertical: isCart ? 4 : 6,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCart) ...[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: isSelected ? AppColors.primaryGradient : null,
                                  color: isSelected ? null : (isDark ? AppColors.darkCard : AppColors.subtle),
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ] : null,
                                ),
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 22,
                                  color: isSelected ? AppColors.white : AppColors.muted,
                                ),
                              ),
                            ] else ...[
                              iconWidget,
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: (isSelected
                                    ? AppTextStyles.labelSmall.copyWith(
                                        color: selectedColor,
                                        fontWeight: FontWeight.w700,
                                      )
                                    : AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.muted,
                                      )),
                                child: Text(item.label),
                              ),
                              // Active indicator dot
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.only(top: 4),
                                width: isSelected ? 4 : 0,
                                height: isSelected ? 4 : 0,
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

