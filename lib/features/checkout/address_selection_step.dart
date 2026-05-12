import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/data/orders.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../checkout/cubit/checkout_cubit.dart';

class CheckoutAddressStep extends StatelessWidget {
  const CheckoutAddressStep({super.key});

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(context.strings.selectDeliveryAddress, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        ...initialAddresses.map((address) {
          final bool isSelected = checkout.state.selectedAddressId == address.id;
          return GestureDetector(
            onTap: () => checkout.selectAddress(address.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Theme.of(context).cardColor,
                borderRadius: AppRadius.lg,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary : AppColors.border,
                    child: Icon(
                      address.label == 'Home' ? Icons.home_rounded : Icons.work_rounded,
                      color: isSelected ? AppColors.white : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.label, style: AppTextStyles.h3),
                        Text(address.fullAddress, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        HealMealButton(
          label: context.strings.addNewAddress,
          type: ButtonType.outlined,
          onPressed: () {}, // TODO: Implement add address
        ),
      ],
    );
  }
}
