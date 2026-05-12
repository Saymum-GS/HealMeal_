import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_image.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/info_banner.dart';
import '../../core/widgets/common/price_display.dart';
import '../../core/widgets/dialogs/confirm_dialog.dart';
import '../checkout/checkout_screens.dart';
import 'cubit/cart_cubit.dart';
import 'cubit/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HealMealAppBar(
        title: '${context.strings.myCart} (${context.watch<CartCubit>().totalCount})',
        showBack: true,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (BuildContext context, CartState state) {
          if (state.items.isEmpty) {
            return EmptyStateWidget(
              type: EmptyStateType.cart,
              onAction: () => context.go('/home'),
              actionLabel: context.strings.startShopping,
            );
          }

          final bool hasRx = state.items.any((item) => item.product.isRxRequired);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            children: <Widget>[
              if (hasRx) ...<Widget>[
                InfoBanner(
                  title: context.strings.rxRequired,
                  body: 'Upload a prescription to continue checkout for Rx products.',
                  type: InfoBannerType.warning,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/prescriptions/upload'),
                    child: Text(context.strings.uploadPrescription),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              ...state.items.map((item) => _CartItemCard(item: item)),
              const SizedBox(height: 8),
              const _CouponCard(),
              const SizedBox(height: 16),
              PriceSummaryCard(
                subtotal: context.read<CartCubit>().subtotal,
                discount: context.read<CartCubit>().discountAmount,
                deliveryCharge: context.read<CartCubit>().deliveryCharge,
                cashbackUsed: context.read<CartCubit>().cashbackUsed,
                total: context.read<CartCubit>().totalPrice,
                cashbackEarned: context.read<CartCubit>().cashbackEarned,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: HealMealButton(
          label: context.strings.proceedToCheckout,
          size: ButtonSize.large,
          onPressed: () {
            final CartState cartState = context.read<CartCubit>().state;
            final bool hasRx = cartState.items.any((item) => item.product.isRxRequired);
            if (hasRx && !cartState.hasApprovedPrescription) {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(context.strings.rxRequired),
                  content: const Text('Please upload and approve a prescription before checkout.'),
                ),
              );
              return;
            }
            context.push('/checkout');
          },
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});
  final CartEntry item;

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.accentRed, borderRadius: AppRadius.lg),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => ConfirmDialog(
            title: 'Remove item',
            body: 'Remove ${item.product.name} from your cart?',
            confirmLabel: 'Remove',
            isDangerous: true,
          ),
        ) ?? false;
      },
      onDismissed: (_) => cartCubit.removeItem(item.product.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.lg,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: <Widget>[
            HealMealImage(imageUrl: item.product.imageUrl, label: item.product.name, width: 76, height: 76, borderRadius: AppRadius.md),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.h3),
                  Text(item.product.brandName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                  const SizedBox(height: 8),
                  PriceDisplay(mrp: item.product.mrp, salePrice: item.product.salePrice, size: PriceDisplaySize.small),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.md),
              child: Column(
                children: <Widget>[
                  IconButton(onPressed: () => cartCubit.updateQuantity(item.product.id, item.quantity + 1), icon: const Icon(Icons.add_rounded), visualDensity: VisualDensity.compact),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('${item.quantity}', style: AppTextStyles.h3)),
                  IconButton(onPressed: () => cartCubit.updateQuantity(item.product.id, item.quantity - 1), icon: const Icon(Icons.remove_rounded), visualDensity: VisualDensity.compact),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard();

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartCubit>().state;
    return InkWell(
      onTap: () => _openCouponSheet(context),
      child: DottedBorder(
        color: AppColors.primary,
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sell_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(cartState.couponCode == null ? 'Add Coupon Code' : 'Coupon Applied', style: AppTextStyles.labelLarge),
                    Text(cartState.couponCode ?? 'Use SAVE20, NEWUSER50, or REFILL10', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                  ],
                ),
              ),
              if (cartState.couponCode != null)
                IconButton(onPressed: () => context.read<CartCubit>().removeCoupon(), icon: const Icon(Icons.close_rounded, size: 18))
              else
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openCouponSheet(BuildContext context) {
    final controller = TextEditingController(text: context.read<CartCubit>().state.couponCode);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Apply coupon', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            HealMealTextField(controller: controller, label: 'Coupon code'),
            const SizedBox(height: 16),
            HealMealButton(label: context.strings.applyCoupon, onPressed: () {
              context.read<CartCubit>().applyCoupon(controller.text);
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
  }
}
