import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/cubits/wishlist_cubit.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/info_banner.dart';
import '../../core/widgets/common/product_card.dart';
import '../cart/cubit/cart_cubit.dart';
import '../cart/cubit/cart_state.dart';
import '../../core/mock_data/mock_products.dart';

final List<_TransactionData> _transactions = <_TransactionData>[
  _TransactionData(
    'LabPayment',
    'Lab Test Payment',
    '#LAB-001',
    DateTime(2026, 4, 5, 9, 15),
    -1350,
    AppColors.error,
    Icons.science_outlined,
  ),
  _TransactionData(
    'Cashback',
    'Cashback Earned',
    '#ORD-001',
    DateTime(2026, 4, 5, 8, 0),
    11,
    AppColors.success,
    Icons.savings_outlined,
  ),
  _TransactionData(
    'Payment',
    'Order Payment',
    '#ORD-001',
    DateTime(2026, 4, 4, 18, 25),
    -220,
    AppColors.error,
    Icons.arrow_upward_rounded,
  ),
  _TransactionData(
    'Refund',
    'Refund',
    '#ORD-099',
    DateTime(2026, 4, 3, 14, 10),
    50,
    AppColors.success,
    Icons.arrow_downward_rounded,
  ),
  _TransactionData(
    'CashbackUse',
    'Cashback Used',
    '#ORD-100',
    DateTime(2026, 4, 2, 10, 40),
    -30,
    AppColors.warning,
    Icons.savings_rounded,
  ),
  _TransactionData(
    'Payment',
    'Order Payment',
    '#ORD-098',
    DateTime(2026, 4, 1, 15, 0),
    -890,
    AppColors.error,
    Icons.arrow_upward_rounded,
  ),
  _TransactionData(
    'Cashback',
    'Cashback Earned',
    '#ORD-098',
    DateTime(2026, 4, 1, 15, 5),
    45,
    AppColors.success,
    Icons.savings_outlined,
  ),
  _TransactionData(
    'Payment',
    'Order Payment',
    '#ORD-095',
    DateTime(2026, 3, 29, 19, 20),
    -150,
    AppColors.error,
    Icons.arrow_upward_rounded,
  ),
  _TransactionData(
    'Cashback',
    'Cashback Earned',
    '#ORD-095',
    DateTime(2026, 3, 29, 19, 35),
    7.5,
    AppColors.success,
    Icons.savings_outlined,
  ),
  _TransactionData(
    'Payment',
    'Order Payment',
    '#ORD-090',
    DateTime(2026, 3, 25, 13, 5),
    -2100,
    AppColors.error,
    Icons.arrow_upward_rounded,
  ),
];

const List<_OfferData> _offers = <_OfferData>[
  _OfferData(
    'New User Offer',
    'NEWUSER50',
    '50% off your first order with a smooth welcome discount.',
    <Color>[AppColors.primary, Color(0xFF1F8D62)],
  ),
  _OfferData(
    'Medicine Reorder Discount',
    'REFILL10',
    '10% off when you reorder the same medicine on time.',
    <Color>[AppColors.primaryDark, AppColors.primary],
  ),
  _OfferData(
    'Lab Test Special',
    'LAB25',
    '25% off all lab tests this week with home collection.',
    <Color>[AppColors.accentBlue, Color(0xFF5E60CE)],
  ),
];

const List<_ReferralData> _referrals = <_ReferralData>[
  _ReferralData('Arif Hasan.', 'Apr 1', 50),
  _ReferralData('Md Karim', 'Mar 15', 50),
  _ReferralData('Nasrin A.', 'Mar 1', 50),
];

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, List<String>>(
      builder: (BuildContext context, List<String> ids) {
        final products = mockMedicines
            .where((item) => ids.contains(item.id))
            .toList();
        return Scaffold(
          appBar: HealMealAppBar(
            title: 'My Wishlist (${products.length})',
            showBack: true,
          ),
          body: products.isEmpty
              ? EmptyStateWidget(
                  type: EmptyStateType.search,
                  customTitle: 'Your wishlist is empty',
                  customBody: 'Tap the heart on any product to save it here.',
                  actionLabel: 'Browse Products',
                  onAction: () => context.go('/home'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: AppLayout.cardGrid(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 350,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = products[index];
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: ProductCard(
                            product: product,
                            onTap: () => context.push('/product/${product.id}'),
                            onAddToCart: () =>
                                context.read<CartCubit>().addItem(product),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.subtle,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            'Added: 2 days ago',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyXSmall.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

class NotifiedProductsScreen extends StatelessWidget {
  const NotifiedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, CartState state) {
        final fallback = mockMedicines
            .where((item) => !item.inStock)
            .take(2)
            .toList();
        final notified = state.notifiedProductIds.isEmpty
            ? fallback
            : mockMedicines
                  .where((item) => state.notifiedProductIds.contains(item.id))
                  .toList();
        return Scaffold(
          appBar: const HealMealAppBar(
            title: 'Notify Me - Products',
            showBack: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              const InfoBanner(
                title: 'Back in stock alerts',
                body:
                    'We will notify you when these out-of-stock products are available again.',
                type: InfoBannerType.info,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...notified.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(product.name, style: AppTextStyles.h3),
                            Text(
                              product.brandName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Out of Stock',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from notify list'),
                            ),
                          );
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class SuggestProductScreen extends StatefulWidget {
  const SuggestProductScreen({super.key});

  @override
  State<SuggestProductScreen> createState() => _SuggestProductScreenState();
}

class _SuggestProductScreenState extends State<SuggestProductScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _productController.dispose();
    _brandController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Suggest a Product', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 52,
            color: AppColors.accentGold,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Help us stock what you need',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Can\'t find a medicine or healthcare product? Tell us and we\'ll try to add it.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          HealMealTextField(
            controller: _productController,
            label: 'Product / Medicine Name',
          ),
          const SizedBox(height: AppSpacing.lg),
          HealMealTextField(
            controller: _brandController,
            label: 'Brand Name (optional)',
          ),
          const SizedBox(height: AppSpacing.lg),
          HealMealTextField(
            controller: _reasonController,
            label: 'Why do you need it? (optional)',
            maxLines: 3,
            minLines: 3,
          ),
          const SizedBox(height: AppSpacing.xl),
          HealMealButton(
            label: 'Submit Suggestion',
            size: ButtonSize.large,
            isLoading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              await Future<void>.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              setState(() => _loading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! We have received your suggestion.'),
                ),
              );
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _transactions.where((item) {
      switch (_filter) {
        case 'Payments':
          return item.type == 'Payment';
        case 'Refunds':
          return item.type == 'Refund';
        case 'Cashback':
          return item.type == 'Cashback' || item.type == 'CashbackUse';
        case 'Lab Tests':
          return item.type == 'LabPayment';
        default:
          return true;
      }
    }).toList();
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Transaction History',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          _InfoCard(
            child: Row(
              children: <Widget>[
                _SummaryMetric(
                  label: 'Total Spent',
                  value: AppFormatters.taka(4710),
                ),
                _SummaryMetric(label: 'Refunds', value: AppFormatters.taka(50)),
                _SummaryMetric(
                  label: 'Cashback',
                  value: AppFormatters.taka(63.5, decimals: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children:
                <String>['All', 'Payments', 'Refunds', 'Cashback', 'Lab Tests']
                    .map(
                      (String item) => ChoiceChip(
                        label: Text(item),
                        selected: _filter == item,
                        onSelected: (_) => setState(() => _filter = item),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...filtered.map((tx) {
            final bool positive = tx.amount >= 0;
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
                  CircleAvatar(
                    backgroundColor: tx.color.withOpacity(.12),
                    child: Icon(tx.icon, color: tx.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(tx.title, style: AppTextStyles.h3),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          tx.refId,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          AppFormatters.compactDateTime(tx.date),
                          style: AppTextStyles.bodyXSmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${positive ? '+' : '-'}${AppFormatters.taka(tx.amount.abs(), decimals: tx.amount.abs() == 7.5 ? 1 : 0)}',
                    style: AppTextStyles.h3.copyWith(color: tx.color),
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

class SpecialOffersScreen extends StatelessWidget {
  const SpecialOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Special Offers', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(
            context.tr('Special Offers for You', 'আপনার জন্য বিশেষ অফার'),
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Personalized deals based on your order history.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._offers.map((offer) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.lg,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: offer.colors),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(.2),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            offer.code,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          offer.title,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          offer.description,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Valid until 30 Apr 2026',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: AppRadius.md,
                                ),
                                child: Text(
                                  offer.code,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            OutlinedButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: offer.code),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Code ${offer.code} copied!',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Copy Code'),
                            ),
                          ],
                        ),
                      ],
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

class OffersScreen extends SpecialOffersScreen {
  const OffersScreen({super.key});
}

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String referralCode = 'HEAL-A7F3K2';
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Refer and Earn', showBack: true),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.card_giftcard_rounded,
                  size: 64,
                  color: AppColors.white,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Refer a Friend, Earn ${AppFormatters.taka(50)}!',
                  style: AppTextStyles.displayHero.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your friend gets ${AppFormatters.taka(30)} off their first order.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  children: <Widget>[
                    Text(
                      'Your Referral Code',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.lg,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        referralCode,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.priceLarge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 6,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: HealMealButton(
                            label: 'Copy Code',
                            type: ButtonType.outlined,
                            size: ButtonSize.medium,
                            prefixIcon: Icons.copy_rounded,
                            onPressed: () async {
                              await Clipboard.setData(
                                const ClipboardData(text: referralCode),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied!')),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: HealMealButton(
                            label: 'Share',
                            size: ButtonSize.medium,
                            prefixIcon: Icons.share_rounded,
                            onPressed: () {
                              Share.share(
                                'Join HealMeal with code $referralCode and save on your first healthcare order.',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    Text('How it works', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: const <Widget>[
                        Expanded(
                          child: _ReferStepCard(
                            step: '1',
                            icon: Icons.share_outlined,
                            text: 'Share your code with a friend',
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ReferStepCard(
                            step: '2',
                            icon: Icons.person_add_alt_rounded,
                            text: 'Friend signs up and places first order',
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ReferStepCard(
                            step: '3',
                            icon: Icons.savings_outlined,
                            text: 'You earn 50, friend saves 30',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        Text('Your Referrals', style: AppTextStyles.h2),
                        const Spacer(),
                        Text(
                          '3 friends • ${AppFormatters.taka(150)}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._referrals.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(item.name[0]),
                        ),
                        title: Text(item.name),
                        subtitle: Text('Friend joined ${item.joined}'),
                        trailing: Text(
                          '+${AppFormatters.taka(item.amount)}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

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
      child: child,
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyXSmall.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferStepCard extends StatelessWidget {
  const _ReferStepCard({
    required this.step,
    required this.icon,
    required this.text,
  });

  final String step;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text(
              step,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyXSmall,
          ),
        ],
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData(
    this.type,
    this.title,
    this.refId,
    this.date,
    this.amount,
    this.color,
    this.icon,
  );

  final String type;
  final String title;
  final String refId;
  final DateTime date;
  final double amount;
  final Color color;
  final IconData icon;
}

class _OfferData {
  const _OfferData(this.title, this.code, this.description, this.colors);

  final String title;
  final String code;
  final String description;
  final List<Color> colors;
}

class _ReferralData {
  const _ReferralData(this.name, this.joined, this.amount);

  final String name;
  final String joined;
  final double amount;
}
