import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/data/orders.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../common/account_widgets.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> reviewed = initialOrders
        .expand(
          (AppOrder order) =>
              order.items.map((AppOrderItem item) => item.product),
        )
        .toSet()
        .take(4)
        .toList();
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Product Reviews', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: reviewed.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final product = reviewed[index];
          return CardSection(
            title: product.name,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.star_rounded, color: AppColors.accentGold, size: 20),
                    Icon(Icons.star_rounded, color: AppColors.accentGold, size: 20),
                    Icon(Icons.star_rounded, color: AppColors.accentGold, size: 20),
                    Icon(Icons.star_rounded, color: AppColors.accentGold, size: 20),
                    Icon(Icons.star_half_rounded, color: AppColors.accentGold, size: 20),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Authentic product, clean packaging, and fast delivery support.',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RiderReviewsScreen extends StatelessWidget {
  const RiderReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const riders = <String>[
      'Rasel Mia|Friendly, on time, and careful with fragile items.|4.8',
      'Sharif Uddin|Called before arrival and was very polite.|4.7',
    ];
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Rider Reviews', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: riders.map((String row) {
          final parts = row.split('|');
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CardSection(
              title: parts[0],
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.delivery_dining_rounded, color: AppColors.primary),
                ),
                subtitle: Text(parts[1]),
                trailing: Text(parts[2], style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
