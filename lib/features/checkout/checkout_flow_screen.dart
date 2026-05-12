import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/orders.dart';
import '../../core/data/models.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../cart/cubit/cart_cubit.dart';
import '../checkout/cubit/checkout_cubit.dart';
import '../orders/cubit/orders_cubit.dart';
import 'address_selection_step.dart';
import 'delivery_step.dart';
import 'coupon_step.dart';
import 'payment_step.dart';
import 'review_step.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final PageController _pageController;
  int step = 0;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final stepLabels = [
      strings.address,
      strings.slot,
      strings.coupon,
      strings.payment,
      strings.review,
    ];

    return Scaffold(
      appBar: HealMealAppBar(title: strings.checkout, showBack: true),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List<Widget>.generate(5, (int index) {
                final bool active = index <= step;
                return Expanded(
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: active ? AppColors.primary : AppColors.border,
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: active ? AppColors.white : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stepLabels[index],
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyXSmall.copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const <Widget>[
                CheckoutAddressStep(),
                CheckoutSlotStep(),
                CheckoutCouponStep(),
                CheckoutPaymentStep(),
                CheckoutReviewStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: HealMealButton(
          label: submitting 
            ? (context.read<CheckoutCubit>().state.selectedPaymentMethod == PaymentMethod.cod 
                ? strings.placingOrder 
                : strings.processingPayment)
            : (step == 4 ? strings.placeOrder : strings.next),
          size: ButtonSize.large,
          isLoading: submitting,
          onPressed: submitting ? null : () => _handleContinue(context),
        ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (step < 4) {
      setState(() => step++);
      await _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      return;
    }

    setState(() => submitting = true);
    final checkoutState = context.read<CheckoutCubit>().state;
    final cartCubit = context.read<CartCubit>();

    await context.read<OrdersCubit>().placeOrder(
      cartState: cartCubit.state,
      checkoutState: checkoutState,
      deliveryAddress: initialAddresses.firstWhere(
        (a) => a.id == checkoutState.selectedAddressId,
        orElse: () => initialAddresses.first,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    cartCubit.clearCart();
    setState(() => submitting = false);
    context.go('/order-confirmed');
  }
}
