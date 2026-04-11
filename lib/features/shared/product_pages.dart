import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../core/cubits/wishlist_cubit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/mock_data/mock_products.dart';
import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_image.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/product_card.dart';
import '../../core/widgets/common/section_header.dart';
import '../../core/widgets/common/skeleton_loader.dart';
import '../../core/widgets/common/price_display.dart';
import '../../core/widgets/common/info_banner.dart';
import '../cart/cubit/cart_cubit.dart';
import '../products/cubit/product_cubit.dart';
import '../products/cubit/product_state.dart';
import '../search/cubit/search_cubit.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, required this.queryParams});

  final Map<String, String> queryParams;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? activeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().filter(
        category: widget.queryParams['category'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const filters = [
      'Sort',
      'Category',
      'Brand',
      'Price',
      'Discount',
      'Availability',
    ];
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Products',
        showBack: true,
        showSearch: true,
        showCart: true,
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          final products = state.filteredProducts;
          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeader(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters.map((filter) {
                          final selected = filter == activeFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => activeFilter = filter);
                                _openFilterSheet(context, filter);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('${products.length} results found'),
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
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                      onAddToCart: () =>
                          context.read<CartCubit>().addItem(product),
                    );
                  }, childCount: products.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openFilterSheet(BuildContext context, String filter) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(filter, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              const Text('Category'),
              Wrap(
                spacing: 8,
                children: ['medicines', 'healthcare', 'supplement'].map((item) {
                  return FilterChip(
                    label: Text(item),
                    selected: false,
                    onSelected: (_) =>
                        context.read<ProductCubit>().filter(category: item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
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

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final product = mockMedicines.firstWhere(
      (item) => item.id == widget.id,
      orElse: () => mockMedicines.first,
    );
    final related = mockMedicines
        .where(
          (item) =>
              item.categorySlug == product.categorySlug &&
              item.id != product.id,
        )
        .take(4)
        .toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: 1,
                    itemBuilder: (context, index) => InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: HealMealImage(
                        imageUrl: product.imageUrl,
                        label: product.name,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 56,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 56,
                    right: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.deliveryBadge,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<WishlistCubit, List<String>>(
                          builder: (ctx, wishlist) {
                            final isWishlisted = wishlist.contains(product.id);
                            return CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isWishlisted
                                      ? AppColors.accentRed
                                      : null,
                                ),
                                onPressed: () => ctx
                                    .read<WishlistCubit>()
                                    .toggle(product.id),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.share_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => context.push(
                      '/brand/${product.brandName.toLowerCase()}',
                    ),
                    child: Text(
                      product.brandName,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: AppColors.accentGold),
                        itemSize: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating} (${product.reviewCount}) • See Reviews →',
                      ),
                    ],
                  ),
                  if (product.isRxRequired) ...[
                    const SizedBox(height: 12),
                    InfoBanner(
                      title: context.strings.rxRequired,
                      body:
                          'Upload a valid prescription before checkout for this medicine.',
                      type: InfoBannerType.warning,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PriceDisplay(
                          mrp: product.mrp,
                          salePrice: product.salePrice,
                          size: PriceDisplaySize.large,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+৳${product.cashback.toStringAsFixed(0)} Cashback',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['10s', '20s', '30s'].map((dose) {
                        final selected = dose == '10s';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(dose),
                            selected: selected,
                            onSelected: (_) {},
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Quantity:'),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => setState(
                          () => quantity = quantity > 1 ? quantity - 1 : 1,
                        ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$quantity', style: AppTextStyles.h3),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  Text(
                    product.stockLeft <= 5
                        ? 'Only ${product.stockLeft} left!'
                        : 'In Stock',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: product.stockLeft <= 5
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        const TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Description'),
                            Tab(text: 'How to Use'),
                            Tab(text: 'Side Effects'),
                            Tab(text: 'Storage'),
                          ],
                        ),
                        SizedBox(
                          height: 180,
                          child: TabBarView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(product.description),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(product.howToUse),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(product.sideEffects),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(product.storage),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: 'Related Products',
                    showSeeAll: false,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final item = related[index];
                        return ProductCard(
                          product: item,
                          style: ProductCardStyle.horizontalScroll,
                          onTap: () => context.push('/product/${item.id}'),
                          onAddToCart: () =>
                              context.read<CartCubit>().addItem(item),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: related.length,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Reviews', showSeeAll: false),
                  const SizedBox(height: 12),
                  ...[
                    (
                      'Tania Akter',
                      'Very fast delivery and authentic product.',
                    ),
                    ('Mahin Islam', 'Packaging was clean and secure.'),
                    (
                      'Rafiul Hasan',
                      'Good price compared to nearby pharmacies.',
                    ),
                  ].map(
                    (review) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(review.$1[0])),
                      title: Text(review.$1),
                      subtitle: Text(review.$2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '৳${product.salePrice.toStringAsFixed(0)}',
                style: AppTextStyles.priceLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: HealMealButton(
                label: !product.inStock
                    ? 'Notify Me'
                    : product.isRxRequired
                    ? 'Upload Prescription'
                    : 'Add to Cart',
                onPressed: () {
                  if (!product.inStock) {
                    context.read<CartCubit>().notifyWhenAvailable(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You will be notified when this product is back in stock',
                        ),
                      ),
                    );
                    return;
                  }
                  if (product.isRxRequired) {
                    context.push('/prescriptions/upload');
                    return;
                  }
                  context.read<CartCubit>().addItem(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandScreen extends StatelessWidget {
  const BrandScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final products = mockMedicines
        .where(
          (item) => item.brandName.toLowerCase().contains(id.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: HealMealAppBar(
        title: id.toUpperCase(),
        showBack: true,
        showSearch: true,
        showCart: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 304,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => context.push('/product/${product.id}'),
            onAddToCart: () => context.read<CartCubit>().addItem(product),
          );
        },
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _recent = ['Napa', 'Insulin', 'CBC', 'Glucometer'];
  final _popular = ['Vitamin C', 'Pulse Oximeter', 'Dengue Package', 'Masks'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Search',
        showBack: true,
        showCart: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HealMealTextField(
              controller: _controller,
              hint: 'Search products or tests',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _controller.clear();
                  context.read<SearchCubit>().search('');
                },
              ),
              onChanged: (value) => context.read<SearchCubit>().search(value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.initial) {
                    return ListView(
                      children: [
                        const Text('Recent Searches'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _recent
                              .map(
                                (e) => ActionChip(
                                  label: Text(e),
                                  onPressed: () {
                                    _controller.text = e;
                                    context.read<SearchCubit>().search(e);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text('Popular Searches'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _popular
                              .map(
                                (e) => ActionChip(
                                  label: Text(e),
                                  onPressed: () {
                                    _controller.text = e;
                                    context.read<SearchCubit>().search(e);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  }
                  if (state.status == SearchStatus.loading) {
                    return GridView.count(
                      crossAxisCount: AppLayout.isCompactPhone(context) ? 1 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: AppLayout.isCompactPhone(context)
                          ? 1.18
                          : .82,
                      children: List.generate(
                        6,
                        (_) => const SkeletonProductCard(),
                      ),
                    );
                  }
                  if (state.status == SearchStatus.empty) {
                    return const EmptyStateWidget(
                      type: EmptyStateType.search,
                      customBody: 'Try: Napa, Insulin, CBC...',
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 304,
                        ),
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final product = state.results[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                        onAddToCart: () =>
                            context.read<CartCubit>().addItem(product),
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

class FlashSaleScreen extends StatelessWidget {
  const FlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              itemCount: flashSaleProducts.length,
              itemBuilder: (context, index) {
                final product = flashSaleProducts[index];
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

class _FilterHeader extends SliverPersistentHeaderDelegate {
  const _FilterHeader({required this.child});

  final Widget child;

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _FilterHeader oldDelegate) {
    return child != oldDelegate.child;
  }
}
