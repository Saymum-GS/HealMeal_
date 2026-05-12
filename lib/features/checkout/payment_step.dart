import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/localization/app_localizations.dart';
import '../checkout/cubit/checkout_cubit.dart';

class CheckoutPaymentStep extends StatelessWidget {
  const CheckoutPaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CheckoutCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Text(context.strings.selectPaymentMethod, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        ...PaymentMethod.values.map((method) {
          final bool isSelected = cubit.state.selectedPaymentMethod == method;
          return GestureDetector(
            onTap: () => cubit.selectPayment(method),
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
                children: <Widget>[
                  Icon(
                    method == PaymentMethod.cod 
                        ? Icons.payments_rounded 
                        : (method == PaymentMethod.bkash ? Icons.account_balance_wallet_rounded : Icons.credit_card_rounded),
                    color: isSelected ? AppColors.primary : AppColors.secondary,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(method.label, style: AppTextStyles.h3),
                        Text(
                          method == PaymentMethod.cod 
                              ? context.strings.codDescription 
                              : context.strings.digitalPaymentDescription,
                          style: AppTextStyles.bodySmall,
                        ),
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
      ],
    );
  }
}
