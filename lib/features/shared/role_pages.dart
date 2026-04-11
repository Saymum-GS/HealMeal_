import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/mock_data/mock_models.dart';
import '../../core/mock_data/mock_orders.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/status_badge.dart';

MockOrder _findOrderByRouteId(String id) {
  final String normalized = id
      .replaceAll('#', '')
      .replaceAll('ORD-', '')
      .trim();
  return mockOrders.firstWhere(
    (MockOrder order) =>
        order.id.replaceAll('#', '').replaceAll('ORD-', '').trim() ==
        normalized,
    orElse: () => mockOrders.first,
  );
}

class PharmacistDashboardScreen extends StatelessWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = mockOrders.take(3).toList();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HealMeal - Pharmacist'),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Pending (3)'),
              Tab(text: 'Reviewed Today'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: const <Widget>[
                  Expanded(
                    child: _StatCard(title: '3 Pending', value: 'Pending'),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(title: '12 Reviewed', value: 'Today'),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(title: '45 This Week', value: 'Total'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _PrescriptionQueue(orders: pending),
                  _PrescriptionQueue(orders: pending.reversed.toList()),
                  _PrescriptionQueue(orders: mockOrders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrescriptionReviewScreen extends StatefulWidget {
  const PrescriptionReviewScreen({super.key, required this.id});

  final String id;

  @override
  State<PrescriptionReviewScreen> createState() =>
      _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState extends State<PrescriptionReviewScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = _findOrderByRouteId(widget.id);
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Review Prescription',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.lg,
            ),
            child: const Center(
              child: Icon(
                Icons.description_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _RoleCard(
            title: 'Patient Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Name: ${order.deliveryAddress.recipientName}',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  'Phone: ${order.deliveryAddress.phoneNumber}',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  'Uploaded: ${AppFormatters.compactDateTime(order.placedAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Notes: Please confirm brand availability.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            title: 'Medicines',
            child: Column(
              children: order.items
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.medication_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(item.product.name),
                      subtitle: Text('${item.quantity} strips'),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          HealMealTextField(
            controller: _noteController,
            label: 'Add pharmacist note',
            maxLines: 3,
            minLines: 3,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Expanded(
              child: HealMealButton(
                label: 'Reject',
                type: ButtonType.outlined,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prescription rejected')),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: HealMealButton(
                label: 'Approve & Call Patient',
                backgroundColor: AppColors.success,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Call patient?'),
                        content: const Text(
                          'Approve prescription and contact the patient now?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'tel:${order.deliveryAddress.phoneNumber}',
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('Call'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HealMeal - Rider'),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Assigned (2)'),
              Tab(text: 'Picked Up (1)'),
              Tab(text: 'Delivered Today (5)'),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: const <Widget>[
                      Expanded(
                        child: _StatCard(title: 'Delivered', value: '5 today'),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(title: 'Earnings', value: '250'),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(title: 'Rating', value: '4.8'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _RiderOrderList(
                        orders: mockOrders.take(2).toList(),
                        pickedUp: false,
                      ),
                      _RiderOrderList(
                        orders: mockOrders.skip(1).take(1).toList(),
                        pickedUp: true,
                      ),
                      _RiderOrderList(
                        orders: mockOrders
                            .where((o) => o.status == OrderStatus.delivered)
                            .toList(),
                        delivered: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.accentBlue, AppColors.primary],
                  ),
                  borderRadius: AppRadius.lg,
                ),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Mock map preview',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.white),
                      ),
                      child: const Text('Open in Maps'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiderOrderDetailScreen extends StatelessWidget {
  const RiderOrderDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final order = _findOrderByRouteId(id);
    return Scaffold(
      appBar: HealMealAppBar(title: '#$id', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          _RoleCard(
            title: 'Customer Information',
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
          _RoleCard(
            title: 'Items',
            child: Column(
              children: order.items
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.product.name),
                      subtitle: Text('Qty ${item.quantity}'),
                      trailing: Text(AppFormatters.taka(item.subtotal)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            title: 'Delivery Instructions',
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
          label: 'Mark Delivered',
          backgroundColor: AppColors.success,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked as delivered')),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HealMeal - Admin')),
      drawer: Drawer(
        child: ListView(
          children: const <Widget>[
            DrawerHeader(child: Text('HealMeal Admin')),
            ListTile(title: Text('Dashboard')),
            ListTile(title: Text('Orders')),
            ListTile(title: Text('Products')),
            ListTile(title: Text('Prescriptions')),
            ListTile(title: Text('Lab Tests')),
            ListTile(title: Text('Users')),
            ListTile(title: Text('Reports')),
            ListTile(title: Text('Settings')),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount = AppLayout.width(context) < 380 ? 1 : 2;
              const metrics = <({String title, String value, Color color})>[
                (
                  title: 'Total Orders Today',
                  value: '48',
                  color: AppColors.accentBlue,
                ),
                (
                  title: 'Pending Prescriptions',
                  value: '12',
                  color: AppColors.accentOrange,
                ),
                (title: 'Active Riders', value: '8', color: AppColors.success),
                (
                  title: 'Revenue Today',
                  value: '24,500',
                  color: Color(0xFF7E57C2),
                ),
                (
                  title: 'New Users Today',
                  value: '15',
                  color: AppColors.primary,
                ),
                (title: 'Lab Bookings', value: '7', color: Color(0xFF3949AB)),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 108,
                ),
                itemCount: metrics.length,
                itemBuilder: (BuildContext context, int index) {
                  final metric = metrics[index];
                  return _MetricCard(
                    title: metric.title,
                    value: metric.value,
                    color: metric.color,
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Recent Orders', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          ...mockOrders.take(5).map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.lg,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(order.id, style: AppTextStyles.labelLarge),
                  ),
                  StatusBadge(status: order.status.label),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: const <Widget>[
              _QuickAdminAction(label: 'Assign Rider'),
              _QuickAdminAction(label: 'Approve Rx'),
              _QuickAdminAction(label: 'Add Product'),
              _QuickAdminAction(label: 'Generate Report'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Admin panel - full functionality requires backend integration',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LabTechDashboardScreen extends StatelessWidget {
  const LabTechDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = mockOrders.take(4).toList();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HealMeal - Lab Tech'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Tab>[
              Tab(text: 'Today (7)'),
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.lg,
                ),
                child: const Text(
                  'Bookings: 7 today | Collected: 4 | Completed: 3',
                  style: AppTextStyles.labelLarge,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List<Widget>.generate(
                  4,
                  (_) => ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    children: bookings.map((order) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: AppRadius.lg,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('CBC Package', style: AppTextStyles.h3),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${order.deliveryAddress.recipientName} • 35 • Female',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Booking time: Morning 8-10',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              order.deliveryAddress.fullAddress,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealMealButton(
                              label: 'Mark Sample Collected',
                              size: ButtonSize.small,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HealMeal Business')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Row(
            children: const <Widget>[
              Expanded(
                child: _StatCard(title: 'This Month Orders', value: '12'),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(title: 'Total Spent', value: '45,200'),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(title: 'Saved via Bulk', value: '8,300'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _RoleCard(
            title: 'Bulk Order via CSV',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Upload a CSV with product names and quantities.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Column(
                    children: <Widget>[
                      Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.primary,
                        size: 36,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text('Upload CSV'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                HealMealButton(
                  label: 'Create Manual Order',
                  type: ButtonType.outlined,
                  onPressed: () => context.push('/products'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Recent Business Orders', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          ...mockOrders.take(3).map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.lg,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(order.id, style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bulk Order • Priority Delivery',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          _RoleCard(
            title: 'Your Account Manager',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Md Arifur Rahman', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                const Text('01325188042', style: AppTextStyles.bodyMedium),
                const Text(
                  'arifahsan690@gmail.com',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: HealMealButton(
                        label: 'Call',
                        size: ButtonSize.small,
                        onPressed: () =>
                            launchUrl(Uri.parse('tel:01325188042')),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: HealMealButton(
                        label: 'WhatsApp',
                        type: ButtonType.outlined,
                        size: ButtonSize.small,
                        onPressed: () =>
                            launchUrl(Uri.parse('https://wa.me/8801325188042')),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: HealMealButton(
                        label: 'Email',
                        type: ButtonType.outlined,
                        size: ButtonSize.small,
                        onPressed: () => launchUrl(
                          Uri.parse('mailto:arifahsan690@gmail.com'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionQueue extends StatelessWidget {
  const _PrescriptionQueue({required this.orders});

  final List<MockOrder> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final MockOrder order = orders[index];
        return _RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          order.deliveryAddress.recipientName,
                          style: AppTextStyles.h3,
                        ),
                        Text(
                          order.deliveryAddress.phoneNumber,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          'Submitted recently',
                          style: AppTextStyles.bodyXSmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(
                        '/pharmacist/rx/${order.id.replaceAll('#', '')}',
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: HealMealButton(
                      label: 'Approve',
                      size: ButtonSize.small,
                      backgroundColor: AppColors.success,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: HealMealButton(
                      label: 'Reject',
                      size: ButtonSize.small,
                      backgroundColor: AppColors.error,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
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

  final List<MockOrder> orders;
  final bool pickedUp;
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 120),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final MockOrder order = orders[index];
        return _RoleCard(
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
                    '${order.items.length} items',
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
                const StatusBadge(status: 'delivered')
              else
                HealMealButton(
                  label: pickedUp ? 'Mark Delivered' : 'Mark Picked Up',
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({this.title, required this.child});

  final String? title;
  final Widget child;

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
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.labelLarge.copyWith(color: color)),
          const Spacer(),
          Text(value, style: AppTextStyles.h1.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _QuickAdminAction extends StatelessWidget {
  const _QuickAdminAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: () {}, child: Text(label));
  }
}
