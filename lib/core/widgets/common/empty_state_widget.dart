import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'healmeal_button.dart';

enum EmptyStateType {
  cart,
  orders,
  search,
  notifications,
  prescriptions,
  labTests,
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.type,
    this.customTitle,
    this.customBody,
    this.onAction,
    this.actionLabel,
  });

  final EmptyStateType type;
  final String? customTitle;
  final String? customBody;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = switch (type) {
      EmptyStateType.cart => (
        Icons.shopping_cart_outlined,
        'Your cart is empty',
        'Browse medicines and healthcare products',
      ),
      EmptyStateType.orders => (
        Icons.receipt_long_outlined,
        'No orders yet',
        'Your placed orders will appear here',
      ),
      EmptyStateType.search => (
        Icons.search_off_rounded,
        'No results found',
        'Try a different keyword',
      ),
      EmptyStateType.notifications => (
        Icons.notifications_none_rounded,
        'No notifications yet',
        'We will keep you posted here',
      ),
      EmptyStateType.prescriptions => (
        Icons.description_outlined,
        'No prescriptions yet',
        'Upload a prescription to get started',
      ),
      EmptyStateType.labTests => (
        Icons.science_outlined,
        'No reports yet',
        'Book a lab test to see results here',
      ),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(icon, size: 56, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                customTitle ?? title,
                style: AppTextStyles.h1.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  customBody ?? body,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.secondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(height: 40),
                SizedBox(
                  width: 220,
                  child: HealMealButton(
                    label: actionLabel ?? 'Continue',
                    onPressed: onAction,
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

