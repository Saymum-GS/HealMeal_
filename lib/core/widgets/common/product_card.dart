import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../localization/app_localizations.dart';
import '../../data/models.dart';
import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/cart/cubit/cart_state.dart';
import '../../../core/cubits/wishlist_cubit.dart';
import 'healmeal_image.dart';
import 'price_display.dart';

enum ProductCardStyle { grid, list, horizontalScroll }

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.style = ProductCardStyle.grid,
    this.showWishlist = true,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final ProductCardStyle style;
  final bool showWishlist;

  bool get _isList => style == ProductCardStyle.list;
  bool get _isGrid => style == ProductCardStyle.grid;
  bool get _isHorizontalScroll => style == ProductCardStyle.horizontalScroll;

  double get _imageHeight {
    if (_isList) return 116;
    if (_isHorizontalScroll) return 76;
    return 92;
  }

  EdgeInsets get _cardPadding =>
      EdgeInsets.all(_isGrid ? AppSpacing.sm : AppSpacing.sm + 2);

  double get _contentTopGap => _isGrid ? 6 : 8;
  double get _buttonHeight => _isGrid ? 34 : 36;
  double get _stepButtonSize => _isGrid ? 34 : 36;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _isHorizontalScroll ? 176 : null,
        padding: _cardPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.lg,
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _isList
            ? Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _buildImage(context, height: _imageHeight),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildContent(context)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImage(context, height: _imageHeight),
                  SizedBox(height: _contentTopGap),
                  Expanded(child: _buildContent(context)),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, {required double height}) {
    return Stack(
      children: <Widget>[
        HealMealImage(
          imageUrl: product.imageUrl,
          label: product.name,
          height: height,
          width: double.infinity,
          borderRadius: AppRadius.md,
          icon: product.categorySlug == 'healthcare'
              ? Icons.health_and_safety_rounded
              : Icons.medication_rounded,
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isGrid ? 7 : 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentRed,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '${product.discountPercent}% OFF',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (product.isRxRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    '℞',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              if (showWishlist) ...<Widget>[
                if (product.isRxRequired) const SizedBox(width: 6),
                BlocBuilder<WishlistCubit, List<String>>(
                  builder: (BuildContext ctx, List<String> wishlist) {
                    final bool isWishlisted = wishlist.contains(product.id);
                    return InkWell(
                      onTap: () {
                        ctx.read<WishlistCubit>().toggle(product.id);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              isWishlisted
                                  ? ctx.strings.removedFromWishlist
                                  : ctx.strings.addedToWishlist,
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            ctx,
                          ).colorScheme.surface.withOpacity(.92),
                          shape: BoxShape.circle,
                          boxShadow: const <BoxShadow>[
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted
                              ? AppColors.accentRed
                              : AppColors.muted,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (!product.inStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: AppRadius.md,
              ),
              alignment: Alignment.center,
              child: Text(
                context.strings.outOfStock,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, CartState state) {
        CartEntry? item;
        for (final CartEntry entry in state.items) {
          if (entry.product.id == product.id) {
            item = entry;
            break;
          }
        }
        final int quantity = item?.quantity ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _isGrid ? 7 : 8,
                vertical: _isGrid ? 3 : 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                product.deliveryBadge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: _isGrid ? 4 : 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 2),
            Text(
              product.brandName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: <Widget>[
                Icon(
                  Icons.star_rounded,
                  size: _isGrid ? 14 : 15,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${product.rating} (${product.reviewCount})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            PriceDisplay(
              mrp: product.mrp,
              salePrice: product.salePrice,
              size: PriceDisplaySize.medium,
            ),
            SizedBox(height: _isGrid ? 6 : 8),
            SizedBox(
              height: _buttonHeight,
              width: double.infinity,
              child: !product.inStock
                  ? OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                        minimumSize: Size(double.infinity, _buttonHeight),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(context.strings.outOfStock),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) =>
                              ScaleTransition(scale: animation, child: child),
                      child: quantity > 0
                          ? Container(
                              key: const ValueKey<String>('stepper'),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.pill,
                              ),
                              child: Row(
                                children: <Widget>[
                                  _StepButton(
                                    icon: Icons.remove,
                                    size: _stepButtonSize,
                                    onTap: () => context
                                        .read<CartCubit>()
                                        .updateQuantity(
                                          product.id,
                                          quantity - 1,
                                        ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$quantity',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  _StepButton(
                                    icon: Icons.add,
                                    size: _stepButtonSize,
                                    onTap: () => context
                                        .read<CartCubit>()
                                        .updateQuantity(
                                          product.id,
                                          quantity + 1,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : OutlinedButton(
                              key: const ValueKey<String>('add'),
                              onPressed: onAddToCart,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: const StadiumBorder(),
                                padding: EdgeInsets.zero,
                                minimumSize: Size(
                                  double.infinity,
                                  _buttonHeight,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'ADD',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: AppColors.white, size: 18),
      ),
    );
  }
}

