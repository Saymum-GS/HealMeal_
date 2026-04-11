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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryLight,
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              customTitle ?? title,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              customBody ?? body,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              HealMealButton(
                label: actionLabel ?? 'Continue',
                onPressed: onAction,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
