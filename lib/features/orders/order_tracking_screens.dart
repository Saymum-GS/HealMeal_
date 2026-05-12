import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_image.dart';
import '../../core/widgets/common/info_banner.dart';
import '../../core/widgets/common/status_badge.dart';
import '../checkout/checkout_screens.dart';
import 'cubit/orders_cubit.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersCubit>().lastPlacedAppOrder;
    return Scaffold(
      body: Stack(
        children: [
          // Celebratory Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * .55,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),
          
          // Decorative Circles
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(radius: 200, backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 50,
            left: -50,
            child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.03)),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Animated-like Success Icon
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.strings.orderPlaced,
                  style: AppTextStyles.displayHero.copyWith(color: AppColors.white, fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order?.id ?? 'Processing...',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
                  ),
                ),
                const Spacer(flex: 2),
                
                // Content Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ConfirmationRow(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Estimated Delivery',
                        value: 'Fast track delivery within 24 hours',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ConfirmationRow(
                        icon: Icons.account_balance_wallet_rounded,
                        title: context.strings.paymentMethod,
                        value: order?.paymentMethod.label ?? 'Cash on Delivery',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const InfoBanner(
                        title: 'Cashback Applied',
                        body: 'You earned ৳25 cashback from this order!',
                        type: InfoBannerType.success,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      HealMealButton(
                        label: context.strings.trackOrder,
                        size: ButtonSize.large,
                        onPressed: () => context.go(order == null ? '/orders' : '/orders/${order.id.replaceAll('#', '')}'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HealMealButton(
                        label: context.strings.continueShopping,
                        type: ButtonType.outlined,
                        size: ButtonSize.large,
                        onPressed: () => context.go('/home'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: AppRadius.md, border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(icon, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.labelLarge), Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary))])),
        ],
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersCubit>().findById(id);
    if (order == null) return const Scaffold(body: Center(child: Text('Order not found')));

    return Scaffold(
      appBar: HealMealAppBar(title: order.id, showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TrackingHeader(order: order),
          const SizedBox(height: 16),
          _TimelineCard(order: order),
          const SizedBox(height: 16),
          _OrderItemsCard(order: order),
          const SizedBox(height: 16),
          PriceSummaryCard(
            subtotal: order.subtotal,
            discount: order.discount,
            deliveryCharge: order.deliveryCharge,
            cashbackUsed: order.cashbackUsed,
            total: order.total,
          ),
          const SizedBox(height: 16),
          _OrderActions(order: order),
        ],
      ),
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader({required this.order});
  final AppOrder order;
  
  @override
  Widget build(BuildContext context) {
    double progress = 0.2;
    if (order.status == OrderStatus.confirmed) progress = 0.4;
    if (order.status == OrderStatus.dispatched) progress = 0.6;
    if (order.status == OrderStatus.outForDelivery) progress = 0.8;
    if (order.status == OrderStatus.delivered) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark.withOpacity(0.8)],
        ),
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Track Your Order', style: AppTextStyles.h1.copyWith(color: AppColors.white)),
                    const SizedBox(height: 4),
                    Text(order.id, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              StatusBadge(status: order.status.label),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 8,
                width: (MediaQuery.of(context).size.width - 64) * progress,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.white54, blurRadius: 4)],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Placed', style: AppTextStyles.labelSmall.copyWith(color: AppColors.white)),
              Text('Dispatched', style: AppTextStyles.labelSmall.copyWith(color: progress >= 0.6 ? AppColors.white : Colors.white38)),
              Text('Delivered', style: AppTextStyles.labelSmall.copyWith(color: progress == 1.0 ? AppColors.white : Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.order});
  final AppOrder order;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Updates', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(order.timeline.length, (index) {
            final step = order.timeline[index];
            final isLast = index == order.timeline.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.completed ? AppColors.success : Colors.transparent,
                        border: Border.all(
                          color: step.completed ? AppColors.success : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: step.completed
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: step.completed ? AppColors.success : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.status,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: step.completed ? null : AppColors.secondary,
                        ),
                      ),
                      Text(
                        AppFormatters.compactDateTime(step.time),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});
  final AppOrder order;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: AppRadius.lg, border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Items', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        ...order.items.map((item) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: HealMealImage(imageUrl: item.product.imageUrl, label: item.product.name, width: 48, height: 48),
          title: Text(item.product.name),
          subtitle: Text('${item.quantity} x ${item.product.salePrice}'),
          trailing: Text(AppFormatters.taka(item.subtotal)),
        )),
      ]),
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.order});
  final AppOrder order;
  @override
  Widget build(BuildContext context) {
    return HealMealButton(
      label: 'Download Invoice',
      type: ButtonType.outlined,
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice downloading...'))),
    );
  }
}
