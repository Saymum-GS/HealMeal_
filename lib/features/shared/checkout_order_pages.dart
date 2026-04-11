import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/mock_data/mock_models.dart';
import '../../core/mock_data/mock_orders.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_image.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/info_banner.dart';
import '../../core/widgets/common/price_display.dart';
import '../../core/widgets/common/status_badge.dart';
import '../../core/widgets/dialogs/confirm_dialog.dart';
import '../cart/cubit/cart_cubit.dart';
import '../cart/cubit/cart_state.dart';
import '../checkout/cubit/checkout_cubit.dart';
import '../checkout/cubit/checkout_state.dart';
import '../orders/cubit/orders_cubit.dart';
import '../orders/cubit/orders_state.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MockOrder? order = context.watch<OrdersCubit>().lastPlacedOrder;
    final String? routeId = order == null ? null : _routeId(order.id);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * .46,
            color: AppColors.primary,
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 28),
                Container(
                  width: 108,
                  height: 108,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 68,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.strings.orderPlaced,
                  style: AppTextStyles.displayHero.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  order?.id ?? 'Your order has been saved on this device.',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        _ConfirmationRow(
                          icon: Icons.schedule_rounded,
                          title: 'Estimated Delivery',
                          value: order == null
                              ? 'Today Evening 5-9'
                              : 'Within 12-24 hours',
                        ),
                        const SizedBox(height: 10),
                        _ConfirmationRow(
                          icon: Icons.payments_rounded,
                          title: context.strings.paymentMethod,
                          value:
                              order?.paymentMethod.label ??
                              context.strings.cashOnDelivery,
                        ),
                        const SizedBox(height: 10),
                        InfoBanner(
                          title: 'Cashback Earned',
                          body:
                              '+${AppFormatters.taka(order == null ? 15 : order.total * .05)} added to your wallet',
                          type: InfoBannerType.info,
                        ),
                        const Spacer(),
                        HealMealButton(
                          label: context.strings.trackOrder,
                          size: ButtonSize.large,
                          onPressed: () => context.go(
                            routeId == null ? '/orders' : '/orders/$routeId',
                          ),
                        ),
                        const SizedBox(height: 12),
                        HealMealButton(
                          label: context.strings.continueShopping,
                          type: ButtonType.outlined,
                          size: ButtonSize.large,
                          onPressed: () => context.go('/home'),
                        ),
                      ],
                    ),
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
  const _ConfirmationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.md,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
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

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.strings.myOrders),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (BuildContext context, OrdersState state) {
            final List<MockOrder> orders = state.orders;
            return TabBarView(
              children: <Widget>[
                _OrderList(orders: orders),
                _OrderList(
                  orders: orders.where((MockOrder order) {
                    return order.status == OrderStatus.placed ||
                        order.status == OrderStatus.confirmed ||
                        order.status == OrderStatus.processing ||
                        order.status == OrderStatus.dispatched ||
                        order.status == OrderStatus.outForDelivery;
                  }).toList(),
                ),
                _OrderList(
                  orders: orders
                      .where(
                        (MockOrder order) =>
                            order.status == OrderStatus.delivered,
                      )
                      .toList(),
                ),
                _OrderList(
                  orders: orders
                      .where(
                        (MockOrder order) =>
                            order.status == OrderStatus.cancelled,
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});

  final List<MockOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(type: EmptyStateType.orders);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        final MockOrder order = orders[index];
        return InkWell(
          onTap: () => context.push('/orders/${_routeId(order.id)}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.lg,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(order.id, style: AppTextStyles.labelLarge),
                    ),
                    StatusBadge(status: order.status.label),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.longDate(order.placedAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${order.items.length} items • ${AppFormatters.taka(order.total)}',
                  style: AppTextStyles.bodyMedium,
                ),
                const Divider(height: 20),
                Row(
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () {
                        final CartCubit cartCubit = context.read<CartCubit>();
                        for (final MockOrderItem item in order.items) {
                          cartCubit.addItem(item.product);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Items added back to cart'),
                          ),
                        );
                      },
                      child: const Text('Reorder'),
                    ),
                    const Spacer(),
                    Text(
                      'View Details →',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: orders.length,
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final MockOrder? order = context.watch<OrdersCubit>().findById(id);
    if (order == null) {
      return Scaffold(
        appBar: const HealMealAppBar(title: 'Order Tracking', showBack: true),
        body: EmptyStateWidget(
          type: EmptyStateType.orders,
          customTitle: 'Order not found',
          customBody:
              'This order is unavailable on this device. Please place a new order for the demo.',
          onAction: () => context.go('/orders'),
          actionLabel: 'Back to Orders',
        ),
      );
    }

    return Scaffold(
      appBar: HealMealAppBar(title: order.id, showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          _TrackingHeader(order: order),
          const SizedBox(height: 16),
          _TimelineCard(order: order),
          if (order.rider != null) ...<Widget>[
            const SizedBox(height: 16),
            _RiderCard(order: order),
          ],
          const SizedBox(height: 16),
          _OrderItemsCard(order: order),
          const SizedBox(height: 16),
          _PriceSummaryCard(
            subtotal: order.subtotal,
            discount: order.discount,
            deliveryCharge: order.deliveryCharge,
            cashbackUsed: order.cashbackUsed,
            total: order.total,
          ),
          const SizedBox(height: 16),
          _AddressCard(address: order.deliveryAddress),
          const SizedBox(height: 16),
          _OrderActions(order: order),
        ],
      ),
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader({required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final int completedCount = order.timeline
        .where((MockTimeline item) => item.completed)
        .length;
    final double progress = completedCount / order.timeline.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Track Your Order',
                      style: AppTextStyles.h1.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.compactDateTime(order.placedAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: order.status.label),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppColors.white.withOpacity(.18),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completedCount of ${order.timeline.length} updates completed',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.order});

  final MockOrder order;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Order Timeline', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          ...order.timeline.asMap().entries.map((
            MapEntry<int, MockTimeline> entry,
          ) {
            final MockTimeline step = entry.value;
            final bool isActive =
                !step.completed &&
                entry.key > 0 &&
                order.timeline[entry.key - 1].completed;
            final Color dotColor = step.completed
                ? AppColors.success
                : isActive
                ? AppColors.primary
                : AppColors.border;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                        child: step.completed
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      if (entry.key != order.timeline.length - 1)
                        Container(
                          width: 2,
                          height: 44,
                          color: step.completed
                              ? AppColors.success
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(step.status, style: AppTextStyles.labelLarge),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.compactDateTime(step.time),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final MockRider rider = order.rider!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.delivery_dining_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(rider.name, style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(
                  'Delivery Rider • ${rider.rating.toStringAsFixed(1)}★',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => launchUrl(Uri.parse('tel:${rider.phone}')),
            icon: const Icon(Icons.call_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});

  final MockOrder order;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Items', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          ...order.items.map(
            (MockOrderItem item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  HealMealImage(
                    imageUrl: item.product.imageUrl,
                    label: item.product.name,
                    width: 58,
                    height: 58,
                    borderRadius: AppRadius.md,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity} × ${AppFormatters.taka(item.product.salePrice)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.taka(item.subtotal),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final MockAddress address;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.strings.deliveryAddress, style: AppTextStyles.h2),
          const SizedBox(height: 10),
          Text(address.recipientName, style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Text(
            address.phoneNumber,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 4),
          Text(address.fullAddress, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (order.status == OrderStatus.delivered)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(.1),
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.accentGold),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.accentGold,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Enjoying HealMeal?', style: AppTextStyles.h3),
                      Text(
                        'Rate us on the Play Store — it helps us grow!',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 98,
                  child: HealMealButton(
                    label: 'Rate Us',
                    size: ButtonSize.small,
                    onPressed: () => launchUrl(
                      Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.healmeal.app',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: HealMealButton(
                label: 'Download Invoice',
                type: ButtonType.outlined,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice saved to downloads')),
                ),
              ),
            ),
            if (order.rider != null &&
                order.status != OrderStatus.delivered) ...<Widget>[
              const SizedBox(width: 12),
              Expanded(
                child: HealMealButton(
                  label: 'Call Rider',
                  onPressed: () =>
                      launchUrl(Uri.parse('tel:${order.rider!.phone}')),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

MockAddress _selectedAddressFrom(String? selectedAddressId) {
  for (final MockAddress address in mockAddresses) {
    if (address.id == selectedAddressId) {
      return address;
    }
  }
  return mockAddresses.first;
}

String _routeId(String id) => id.replaceAll('#', '');

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HealMealAppBar(
        title:
            '${context.strings.myCart} (${context.watch<CartCubit>().totalCount})',
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

          final bool hasRx = state.items.any(
            (CartEntry item) => item.product.isRxRequired,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            children: <Widget>[
              if (hasRx) ...<Widget>[
                InfoBanner(
                  title: context.strings.rxRequired,
                  body:
                      'Upload a prescription to continue checkout for Rx products.',
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
              ...state.items.map((CartEntry item) => _CartItemCard(item: item)),
              const SizedBox(height: 8),
              _CouponCard(cartState: state),
              const SizedBox(height: 16),
              _PriceSummaryCard(
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
            final bool hasRx = cartState.items.any(
              (CartEntry item) => item.product.isRxRequired,
            );
            if (hasRx && !cartState.hasApprovedPrescription) {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(context.strings.rxRequired),
                  content: const Text(
                    'Please upload and approve a prescription before checkout.',
                  ),
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
    final CartCubit cartCubit = context.read<CartCubit>();
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.accentRed,
          borderRadius: AppRadius.lg,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (BuildContext ctx) => ConfirmDialog(
                title: 'Remove item',
                body: 'Remove ${item.product.name} from your cart?',
                confirmLabel: 'Remove',
                isDangerous: true,
              ),
            ) ??
            false;
      },
      onDismissed: (_) => context.read<CartCubit>().removeItem(item.product.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.lg,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HealMealImage(
              imageUrl: item.product.imageUrl,
              label: item.product.name,
              width: 76,
              height: 76,
              borderRadius: AppRadius.md,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    item.product.brandName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PriceDisplay(
                    mrp: item.product.mrp,
                    salePrice: item.product.salePrice,
                    size: PriceDisplaySize.small,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.md,
              ),
              child: Column(
                children: <Widget>[
                  IconButton(
                    onPressed: () => cartCubit.updateQuantity(
                      item.product.id,
                      item.quantity + 1,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('${item.quantity}', style: AppTextStyles.h3),
                  ),
                  IconButton(
                    onPressed: () => cartCubit.updateQuantity(
                      item.product.id,
                      item.quantity - 1,
                    ),
                    icon: const Icon(Icons.remove_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
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
  const _CouponCard({required this.cartState});

  final CartState cartState;

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      cartState.couponCode == null
                          ? 'Add Coupon Code'
                          : 'Coupon Applied',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cartState.couponCode ??
                          'Use SAVE20, NEWUSER50, or REFILL10',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (cartState.couponCode != null)
                IconButton(
                  onPressed: () => context.read<CartCubit>().removeCoupon(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openCouponSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: context.read<CartCubit>().state.couponCode,
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Apply coupon', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              HealMealTextField(controller: controller, label: 'Coupon code'),
              const SizedBox(height: 16),
              HealMealButton(
                label: context.strings.applyCoupon,
                onPressed: () {
                  context.read<CartCubit>().applyCoupon(controller.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({
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
          _SummaryRow(
            label: context.strings.subtotal,
            value: AppFormatters.taka(subtotal),
          ),
          _SummaryRow(
            label: context.strings.discount,
            value: '-${AppFormatters.taka(discount)}',
            valueColor: AppColors.success,
          ),
          _SummaryRow(
            label: context.strings.deliveryCharge,
            value: deliveryCharge == 0
                ? 'FREE'
                : AppFormatters.taka(deliveryCharge),
            valueColor: deliveryCharge == 0 ? AppColors.success : null,
          ),
          if (cashbackEarned != null)
            _SummaryRow(
              label: 'Cashback Earn',
              value: '+${AppFormatters.taka(cashbackEarned!)}',
              valueColor: AppColors.primary,
            ),
          if (cashbackUsed > 0)
            _SummaryRow(
              label: 'Cashback Used',
              value: '-${AppFormatters.taka(cashbackUsed)}',
              valueColor: AppColors.warning,
            ),
          const Divider(height: 24),
          _SummaryRow(
            label: context.strings.totalPayable,
            value: AppFormatters.taka(total),
            emphasize: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

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
          Expanded(
            child: Text(
              label,
              style: emphasize ? AppTextStyles.h3 : AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            value,
            style: (emphasize ? AppTextStyles.h3 : AppTextStyles.bodyMedium)
                .copyWith(
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

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
    return Scaffold(
      appBar: HealMealAppBar(title: context.strings.checkout, showBack: true),
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
                        backgroundColor: active
                            ? AppColors.primary
                            : AppColors.border,
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: active
                                ? AppColors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        <String>[
                          'Address',
                          'Slot',
                          'Coupon',
                          'Payment',
                          'Review',
                        ][index],
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyXSmall.copyWith(
                          color: AppColors.secondary,
                        ),
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
                _CheckoutAddressStep(),
                _CheckoutSlotStep(),
                _CheckoutCouponStep(),
                _CheckoutPaymentStep(),
                _CheckoutReviewStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: HealMealButton(
          label: step == 4 ? context.strings.placeOrder : 'Next',
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
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    setState(() => submitting = true);
    final CheckoutState checkoutState = context.read<CheckoutCubit>().state;
    final CartCubit cartCubit = context.read<CartCubit>();

    await context.read<OrdersCubit>().placeOrder(
      cartState: cartCubit.state,
      checkoutState: checkoutState,
      deliveryAddress: _selectedAddressFrom(checkoutState.selectedAddressId),
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    cartCubit.clearCart();
    setState(() => submitting = false);
    context.go('/order-confirmed');
  }
}

class _CheckoutAddressStep extends StatelessWidget {
  const _CheckoutAddressStep();

  @override
  Widget build(BuildContext context) {
    final CheckoutCubit checkout = context.watch<CheckoutCubit>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ...mockAddresses.map((MockAddress address) {
          final bool selected = checkout.state.selectedAddressId == address.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryLight
                  : Theme.of(context).cardColor,
              borderRadius: AppRadius.lg,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: RadioListTile<String>(
              value: address.id,
              groupValue: checkout.state.selectedAddressId,
              onChanged: (String? value) {
                if (value != null) {
                  checkout.selectAddress(value);
                }
              },
              title: Text(address.label, style: AppTextStyles.h3),
              subtitle: Text(address.fullAddress),
            ),
          );
        }),
        HealMealButton(
          label: context.strings.addNewAddress,
          type: ButtonType.outlined,
          onPressed: () => context.push('/account/addresses/add'),
        ),
      ],
    );
  }
}

class _CheckoutSlotStep extends StatelessWidget {
  const _CheckoutSlotStep();

  @override
  Widget build(BuildContext context) {
    final CheckoutCubit cubit = context.watch<CheckoutCubit>();
    final List<DateTime> days = List<DateTime>.generate(
      3,
      (int index) => DateTime.now().add(Duration(days: index)),
    );
    const List<String> slots = <String>[
      'Morning 8-12',
      'Afternoon 12-5',
      'Evening 5-9',
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ChoiceChip(
              label: Text(context.strings.expressDelivery),
              selected: cubit.state.deliveryType == 'express',
              onSelected: (_) => cubit.selectDeliveryType('express'),
            ),
            ChoiceChip(
              label: Text(context.strings.standardDelivery),
              selected: cubit.state.deliveryType == 'standard',
              onSelected: (_) => cubit.selectDeliveryType('standard'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((DateTime day) {
            final DateTime? selected = cubit.state.selectedDate;
            final bool isSelected =
                selected != null &&
                selected.day == day.day &&
                selected.month == day.month;
            return ChoiceChip(
              label: Text('${day.day}/${day.month}'),
              selected: isSelected,
              onSelected: (_) => cubit.selectDate(day),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots
              .map(
                (String slot) => ChoiceChip(
                  label: Text(slot),
                  selected: cubit.state.selectedTimeSlot == slot,
                  onSelected: (_) => cubit.selectTimeSlot(slot),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          title: 'Free delivery unlocked',
          body: 'Orders above ৳500 get free standard delivery.',
          type: InfoBannerType.success,
        ),
      ],
    );
  }
}

class _CheckoutCouponStep extends StatelessWidget {
  const _CheckoutCouponStep();

  @override
  Widget build(BuildContext context) {
    final CartCubit cartCubit = context.read<CartCubit>();
    final TextEditingController controller = TextEditingController(
      text: cartCubit.state.couponCode,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: HealMealTextField(
                controller: controller,
                label: 'Coupon code',
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: HealMealButton(
                label: context.strings.applyCoupon,
                onPressed: () => cartCubit.applyCoupon(controller.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: cartCubit.state.cashbackEnabled,
          onChanged: cartCubit.toggleCashback,
          title: Text(context.strings.useCashback),
          subtitle: Text(
            'Available balance: ${AppFormatters.taka(125.5, decimals: 1)}',
          ),
        ),
      ],
    );
  }
}

class _CheckoutPaymentStep extends StatelessWidget {
  const _CheckoutPaymentStep();

  @override
  Widget build(BuildContext context) {
    final CheckoutCubit cubit = context.watch<CheckoutCubit>();
    const List<(PaymentMethod, String, String)> methods =
        <(PaymentMethod, String, String)>[
          (
            PaymentMethod.cod,
            'Cash on Delivery',
            'Pay after you receive the order',
          ),
          (PaymentMethod.bkash, 'bKash', 'You will be redirected to the app'),
          (PaymentMethod.nagad, 'Nagad', 'You will be redirected to the app'),
          (PaymentMethod.rocket, 'Rocket', 'You will be redirected to the app'),
          (PaymentMethod.card, 'Card', 'Pay securely using your card'),
        ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: methods.map(((PaymentMethod, String, String) item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.lg,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: RadioListTile<PaymentMethod>(
            value: item.$1,
            groupValue: cubit.state.selectedPaymentMethod,
            onChanged: (PaymentMethod? value) {
              if (value != null) {
                cubit.selectPayment(value);
              }
            },
            title: Text(item.$2),
            subtitle: Text(item.$3),
          ),
        );
      }).toList(),
    );
  }
}

class _CheckoutReviewStep extends StatelessWidget {
  const _CheckoutReviewStep();

  @override
  Widget build(BuildContext context) {
    final CartState cart = context.watch<CartCubit>().state;
    final CheckoutState checkout = context.watch<CheckoutCubit>().state;
    final MockAddress selectedAddress = _selectedAddressFrom(
      checkout.selectedAddressId,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ListTile(
          title: Text(context.strings.deliveryAddress),
          subtitle: Text(selectedAddress.fullAddress),
        ),
        ListTile(
          title: Text(context.strings.deliverySlot),
          subtitle: Text(checkout.selectedTimeSlot),
        ),
        const Divider(),
        ...cart.items.map(
          (CartEntry item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.product.name),
            subtitle: Text('Qty ${item.quantity}'),
            trailing: Text(AppFormatters.taka(item.subtotal)),
          ),
        ),
        const SizedBox(height: 16),
        _PriceSummaryCard(
          subtotal: context.read<CartCubit>().subtotal,
          discount: context.read<CartCubit>().discountAmount,
          deliveryCharge: context.read<CartCubit>().deliveryCharge,
          cashbackUsed: context.read<CartCubit>().cashbackUsed,
          total: context.read<CartCubit>().totalPrice,
        ),
      ],
    );
  }
}
