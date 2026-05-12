import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/cubits/wishlist_cubit.dart';
import '../../../core/data/products.dart';
import '../../../core/utils/app_layout.dart';
import '../../../core/utils/app_session.dart';
import '../../../core/widgets/common/empty_state_widget.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../../core/widgets/common/info_banner.dart';
import '../../../core/widgets/common/product_card.dart';
import '../../../core/repositories/suggestion_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, List<String>>(
      builder: (BuildContext context, List<String> ids) {
        final products = initialMedicines
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
        final fallback = initialMedicines
            .where((item) => !item.inStock)
            .take(2)
            .toList();
        final notified = state.notifiedProductIds.isEmpty
            ? fallback
            : initialMedicines
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
              if (_productController.text.isEmpty) return;
              
              setState(() => _loading = true);
              try {
                final authState = context.read<AuthCubit>().state;
                String userId = 'guest';
                if (authState is AuthAuthenticated) userId = AppSession.userId ?? 'guest';

                final repo = SuggestionRepository();
                final suggestion = ProductSuggestion(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productName: _productController.text,
                  brandName: _brandController.text,
                  reason: _reasonController.text,
                  createdAt: DateTime.now(),
                  userId: userId,
                );
                
                await repo.submitSuggestion(suggestion);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you! Suggestion received.')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
