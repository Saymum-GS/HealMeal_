import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/status_badge.dart';
import '../cart/cubit/cart_cubit.dart';
import 'cubit/orders_cubit.dart';
import 'cubit/orders_state.dart';

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
            final orders = state.orders;
            return TabBarView(
              children: <Widget>[
                _OrderList(orders: orders),
                _OrderList(orders: orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList()),
                _OrderList(orders: orders.where((o) => o.status == OrderStatus.delivered).toList()),
                _OrderList(orders: orders.where((o) => o.status == OrderStatus.cancelled).toList()),
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
  final List<AppOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const EmptyStateWidget(type: EmptyStateType.orders);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return InkWell(
          onTap: () => context.push('/orders/${order.id.replaceAll('#', '')}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: AppRadius.lg, border: Border.all(color: Theme.of(context).dividerColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Expanded(child: Text(order.id, style: AppTextStyles.labelLarge)), StatusBadge(status: order.status.label)]),
                const SizedBox(height: 8),
                Text(AppFormatters.longDate(order.placedAt), style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 10),
                Text('${order.items.length} items • ${AppFormatters.taka(order.total)}', style: AppTextStyles.bodyMedium),
                const Divider(height: 20),
                Row(children: [
                  OutlinedButton(onPressed: () {
                    for (var item in order.items) { context.read<CartCubit>().addItem(item.product); }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Items added to cart')));
                  }, child: const Text('Reorder')),
                  const Spacer(),
                  Text('View Details →', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
