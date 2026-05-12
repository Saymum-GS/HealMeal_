import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/status_badge.dart';
import '../common/role_widgets.dart';
import 'cubit/rider_cubit.dart';

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderCubit, RiderState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.strings.riderDashboard),
              actions: <Widget>[
                IconButton(
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: context.strings.logout,
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: <Tab>[
                  Tab(text: '${context.strings.assigned} (${state.assignedOrders.length})'),
                  Tab(text: '${context.strings.pickedUp} (${state.pickedUpOrders.length})'),
                  Tab(text: '${context.strings.delivered} (${state.deliveredOrders.length})'),
                ],
              ),
            ),
            body: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _EarningsHeader(state: state),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          _RiderOrderList(orders: state.assignedOrders, pickedUp: false),
                          _RiderOrderList(orders: state.pickedUpOrders, pickedUp: true),
                          _RiderOrderList(orders: state.deliveredOrders, delivered: true),
                        ],
                      ),
                    ),
                  ],
                ),
                _ActiveNavigationPanel(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EarningsHeader extends StatelessWidget {
  const _EarningsHeader({required this.state});
  final RiderState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(label: context.strings.totalDelivered, value: '${state.deliveredOrders.length}', color: AppColors.success),
          _Stat(label: context.strings.todaysEarnings, value: AppFormatters.taka(state.deliveredOrders.length * 50.0), color: AppColors.primary),
          _Stat(label: context.strings.rating, value: '4.9', color: Colors.amber),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: color)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary)),
      ],
    );
  }
}

class _ActiveNavigationPanel extends StatelessWidget {
  const _ActiveNavigationPanel({required this.state});
  final RiderState state;

  @override
  Widget build(BuildContext context) {
    if (state.pickedUpOrders.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: AppSpacing.lg,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
            borderRadius: AppRadius.lg,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.navigation_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.strings.activeDelivery, style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                        Text(state.pickedUpOrders.first.deliveryAddress.fullAddress, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  HealMealButton(
                    label: context.strings.maps,
                    size: ButtonSize.small,
                    onPressed: () => _openMaps(state.pickedUpOrders.first.deliveryAddress.fullAddress),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMaps(String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class RiderOrderDetailScreen extends StatelessWidget {
  const RiderOrderDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderCubit, RiderState>(
      builder: (context, state) {
        final allOrders = [
          ...state.assignedOrders,
          ...state.pickedUpOrders,
          ...state.deliveredOrders,
        ];
        
        final order = allOrders.firstWhere(
          (o) => findOrderByRouteId(o.id).id == findOrderByRouteId(id).id,
          orElse: () => findOrderByRouteId(id), // Fallback if not loaded
        );

        return Scaffold(
          appBar: HealMealAppBar(title: '#$id', showBack: true),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lg,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/rider_map_simulation.png'), // This will be linked to the generated artifact
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(context.strings.tapToStartNavigation, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              RoleCard(
                title: context.strings.customerInfo,
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
                                order.deliveryAddress.recipientName,
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                order.deliveryAddress.phoneNumber,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => launchUrl(Uri.parse('tel:${order.deliveryAddress.phoneNumber}')),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          icon: const Icon(Icons.phone_rounded, color: AppColors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      order.deliveryAddress.fullAddress,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RoleCard(
                title: context.strings.totalItems,
                child: Column(
                  children: order.items
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.product.name),
                          subtitle: Text('${context.strings.totalItems} ${item.quantity}'),
                          trailing: Text(AppFormatters.taka(item.subtotal)),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RoleCard(
                title: context.strings.deliveryInstructions,
                child: Text(
                  'Call before arrival and hand over at the main gate.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: HealMealButton(
              label: order.status == OrderStatus.dispatched 
                  ? context.strings.markPickedUp 
                  : (order.status == OrderStatus.outForDelivery 
                      ? context.strings.markDelivered 
                      : context.strings.delivered),
              backgroundColor: order.status == OrderStatus.delivered 
                  ? AppColors.secondary 
                  : AppColors.success,
              onPressed: order.status == OrderStatus.delivered 
                  ? null 
                  : () {
                      if (order.status == OrderStatus.dispatched) {
                        context.read<RiderCubit>().markPickedUp(order.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.strings.orderPickedUp)),
                        );
                      } else if (order.status == OrderStatus.outForDelivery) {
                        context.read<RiderCubit>().markDelivered(order.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.strings.orderDelivered)),
                        );
                      }
                      context.pop();
                    },
            ),
          ),
        );
      },
    );
  }
}

class _RiderOrderList extends StatelessWidget {
  const _RiderOrderList({
    required this.orders,
    this.pickedUp = false,
    this.delivered = false,
  });

  final List<AppOrder> orders;
  final bool pickedUp;
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 120),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final order = orders[index];
        return RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(order.id, style: AppTextStyles.labelLarge),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.pill,
                    ),
                    child: const Text('2.3 km'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                order.deliveryAddress.recipientName,
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.deliveryAddress.phoneNumber,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              Text(
                order.deliveryAddress.fullAddress,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Text(
                    '${order.items.length} ${context.strings.totalItems}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    AppFormatters.taka(order.total),
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (delivered)
                StatusBadge(status: OrderStatus.delivered.name)
              else
                HealMealButton(
                  label: pickedUp ? context.strings.markDelivered : context.strings.markPickedUp,
                  size: ButtonSize.small,
                  backgroundColor: pickedUp
                      ? AppColors.success
                      : AppColors.primary,
                  onPressed: () => context.push(
                    '/rider/order/${order.id.replaceAll('#', '')}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
