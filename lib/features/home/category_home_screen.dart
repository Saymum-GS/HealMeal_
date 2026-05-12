import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/products.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/product_card.dart';
import '../../core/widgets/common/section_header.dart';
import '../cart/cubit/cart_cubit.dart';
import '../products/cubit/product_cubit.dart';

class CategoryHomeScreen extends StatelessWidget {
  const CategoryHomeScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HealMealAppBar(
        title: slug.replaceAll('-', ' ').toUpperCase(),
        showBack: true,
        showSearch: true,
        showCart: true,
      ),
      body: Builder(
        builder: (context) {
          final productState = context.watch<ProductCubit>().state;
          final products = productState.allProducts
              .where((item) => item.categorySlug == slug || (slug == 'medicines' && item.categorySlug == 'medicines'))
              .toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(slug.replaceAll('-', ' ').toUpperCase(), style: AppTextStyles.h1.copyWith(color: Colors.white)),
                            ),
                            const Icon(Icons.medication_rounded, size: 48, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Products', showSeeAll: false),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 304,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products.isNotEmpty ? products[index % products.length] : initialMedicines[index % initialMedicines.length];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                      onAddToCart: () => context.read<CartCubit>().addItem(product),
                    );
                  }, childCount: products.isNotEmpty ? products.length : 8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
