import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/app_session.dart';
import '../../../core/widgets/common/status_badge.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../admin/cubit/admin_cubit.dart';
import '../common/role_widgets.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealMeal Business'),
        actions: <Widget>[
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, adminState) {
          final currentUserId = AppSession.userId;

          final businessOrders = adminState.allOrders.where((o) => o.userId == currentUserId).toList();
          final totalSpent = businessOrders.fold(0.0, (sum, o) => sum + o.total);
          final monthlyOrders = businessOrders.where((o) => o.placedAt.month == DateTime.now().month).length;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatCard(title: 'Monthly Orders', value: '$monthlyOrders'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(title: 'Total Spent', value: AppFormatters.taka(totalSpent)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: StatCard(title: 'Saved via Bulk', value: '৳0'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Recent Business Orders', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              if (businessOrders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Center(child: Text('No orders found.')),
                )
              else
                ...businessOrders.take(5).map((order) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(order.id, style: AppTextStyles.labelLarge),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppFormatters.taka(order.total),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: order.status.label),
                      ],
                    ),
                  );
                }),
          const SizedBox(height: AppSpacing.xl),
          RoleCard(
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
      );
        },
      ),
    );
  }
}
