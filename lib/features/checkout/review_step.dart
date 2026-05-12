import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/data/orders.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/common/info_banner.dart';
import '../cart/cubit/cart_cubit.dart';
import '../checkout/cubit/checkout_cubit.dart';

class CheckoutReviewStep extends StatelessWidget {
  const CheckoutReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartCubit>();
    final checkout = context.watch<CheckoutCubit>().state;
    final address = initialAddresses.firstWhere((a) => a.id == checkout.selectedAddressId, orElse: () => initialAddresses.first);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Text(context.strings.orderReview, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        
        // Address & Payment Summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.lg,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: <Widget>[
              ReviewDetailRow(
                icon: Icons.location_on_rounded,
                title: context.strings.deliveryAddress,
                value: address.fullAddress,
              ),
              const Divider(height: 32),
              ReviewDetailRow(
                icon: Icons.payment_rounded,
                title: context.strings.paymentMethod,
                value: checkout.selectedPaymentMethod.label,
              ),
              const Divider(height: 32),
              ReviewDetailRow(
                icon: Icons.local_shipping_rounded,
                title: context.strings.deliverySpeed,
                value: checkout.deliveryType.toUpperCase(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        Text(context.strings.billDetails, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        PriceSummaryCard(
          subtotal: cart.subtotal,
          discount: cart.discountAmount,
          deliveryCharge: cart.deliveryCharge,
          cashbackUsed: cart.cashbackUsed,
          total: cart.totalPrice,
          cashbackEarned: cart.state.cashbackEnabled ? 15.0 : null, // Mock value
        ),
        const SizedBox(height: AppSpacing.xl),
        InfoBanner(
          title: context.strings.securePayment,
          body: context.strings.securePaymentDescription,
          type: InfoBannerType.info,
        ),
      ],
    );
  }
}

class PriceSummaryCard extends StatelessWidget {
  const PriceSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.cashbackUsed,
    required this.total,
    this.cashbackEarned,
  });

  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double cashbackUsed;
  final double total;
  final double? cashbackEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: <Widget>[
          SummaryRow(label: context.strings.subtotal, value: AppFormatters.taka(subtotal)),
          SummaryRow(label: context.strings.discount, value: '-${AppFormatters.taka(discount)}', valueColor: AppColors.success),
          SummaryRow(label: context.strings.deliveryCharge, value: deliveryCharge == 0 ? context.strings.free : AppFormatters.taka(deliveryCharge), valueColor: deliveryCharge == 0 ? AppColors.success : null),
          if (cashbackEarned != null) SummaryRow(label: context.strings.cashbackEarned, value: '+${AppFormatters.taka(cashbackEarned!)}', valueColor: AppColors.primary),
          if (cashbackUsed > 0) SummaryRow(label: context.strings.cashbackUsedLabel, value: '-${AppFormatters.taka(cashbackUsed)}', valueColor: AppColors.warning),
          const Divider(height: 24),
          SummaryRow(label: context.strings.totalPayable, value: AppFormatters.taka(total), emphasize: true, valueColor: AppColors.primary),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value, this.emphasize = false, this.valueColor});
  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: emphasize ? AppTextStyles.h3 : AppTextStyles.bodyMedium)),
          Text(value, style: (emphasize ? AppTextStyles.h3 : AppTextStyles.bodyMedium).copyWith(color: valueColor ?? Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class ReviewDetailRow extends StatelessWidget {
  const ReviewDetailRow({super.key, required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
