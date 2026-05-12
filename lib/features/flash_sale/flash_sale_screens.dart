import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/product_card.dart';
import '../cart/cubit/cart_cubit.dart';
import '../products/cubit/product_cubit.dart';

class FlashSaleScreen extends StatelessWidget {
  const FlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productState = context.watch<ProductCubit>().state;
    final flashSaleItems = productState.allProducts.where((p) => p.isFlashSale).toList();
    
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Flash Sale',
        showBack: true,
        showSearch: true,
        showCart: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentRed, AppColors.accentOrange],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Flash Sale',
                    style: AppTextStyles.h1.copyWith(color: Colors.white),
                  ),
                ),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 304,
              ),
              itemCount: flashSaleItems.length,
              itemBuilder: (context, index) {
                final product = flashSaleItems[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push('/product/${product.id}'),
                  onAddToCart: () => context.read<CartCubit>().addItem(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

