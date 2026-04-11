import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/mock_data/mock_models.dart';
import '../../core/mock_data/mock_products.dart';
import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_bottom_nav.dart';
import '../../core/widgets/common/brand_lockup.dart';
import '../../core/widgets/common/product_card.dart';
import '../../core/widgets/common/section_header.dart';
import '../cart/cubit/cart_cubit.dart';
import '../home/cubit/home_cubit.dart';
import '../home/cubit/home_state.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartCubit>().totalCount;
    final currentIndex = switch (navigationShell.currentIndex) {
      0 => 0,
      1 => 1,
      2 => 3,
      3 => 4,
      _ => 0,
    };
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: HealMealBottomNav(
        currentIndex: currentIndex,
        cartCount: cartCount,
        onTap: (index) {
          if (index == 2) {
            context.push('/cart');
            return;
          }
          final branch = switch (index) {
            0 => 0,
            1 => 1,
            3 => 2,
            4 => 3,
            _ => 0,
          };
          navigationShell.goBranch(branch);
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flash = flashSaleProducts.take(6).toList();
    final devices = mockMedicines
        .where((p) => p.categorySlug == 'healthcare')
        .take(6)
        .toList();
    final supplements = mockMedicines
        .where((p) => p.categorySlug == 'supplement')
        .take(6)
        .toList();
    final medicines = mockMedicines
        .where((p) => p.categorySlug == 'medicines')
        .take(6)
        .toList();
    const categories = [
      ('flash-sale', 'Flash Sale', Icons.local_fire_department_rounded),
      ('medicines', 'Medicine', Icons.medication_rounded),
      ('lab', 'Lab Test', Icons.science_rounded),
      ('healthcare', 'Healthcare', Icons.favorite_rounded),
      ('supplement', 'Supplement', Icons.health_and_safety_rounded),
      ('diabetic-care', 'Diabetic Care', Icons.monitor_heart_rounded),
      ('cardiac-care', 'Cardiac Care', Icons.heart_broken_rounded),
      ('baby-mom-care', 'Baby & Mom', Icons.child_care_rounded),
      ('herbal', 'Herbal', Icons.spa_rounded),
      ('homeopathy', 'Homeopathy', Icons.local_florist_rounded),
      ('sexual-wellness', 'Sexual Wellness', Icons.favorite_border_rounded),
      ('pet-care', 'Pet Care', Icons.pets_rounded),
      ('veterinary', 'Veterinary', Icons.medication_liquid_rounded),
    ];

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.primary,
                title: const BrandLockup(onDark: true),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/cart'),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(74),
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search medicines, healthcare...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        viewportFraction: .92,
                        onPageChanged: (index, _) =>
                            context.read<HomeCubit>().setBanner(index),
                      ),
                      items: const [
                        _HeroBanner(
                          colors: [AppColors.primary, Color(0xFF1A9E73)],
                          title: 'Seasonal Campaign',
                          subtitle: 'Up to 60% OFF',
                          icon: Icons.local_offer_rounded,
                        ),
                        _HeroBanner(
                          colors: [Color(0xFF084F38), Color(0xFF0B6E4F)],
                          title: '#1 Platform',
                          subtitle: 'Trusted medicine & care',
                          icon: Icons.medication_rounded,
                        ),
                        _HeroBanner(
                          colors: [Color(0xFFE63946), Color(0xFFF4A261)],
                          title: 'Flash Sale',
                          subtitle: 'Up to 83% OFF',
                          icon: Icons.local_fire_department_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: index == state.activeBanner ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == state.activeBanner
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isFlash = index == 0;
                          return InkWell(
                            onTap: () {
                              if (cat.$1 == 'flash-sale') {
                                context.push('/flash-sale');
                              } else if (cat.$1 == 'lab') {
                                context.go('/lab-test');
                              } else {
                                context.push('/category/${cat.$1}');
                              }
                            },
                            child: Container(
                              width: 96,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isFlash
                                    ? AppColors.warningBg
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isFlash
                                      ? AppColors.warning
                                      : Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cat.$3,
                                    color: isFlash
                                        ? AppColors.warning
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.$2,
                                    style: AppTextStyles.labelSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: categories.length,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final int crossAxisCount =
                                  constraints.maxWidth < 360 ? 2 : 3;
                              final double mainAxisExtent = crossAxisCount == 2
                                  ? 124
                                  : 112;
                              const actions =
                                  <
                                    ({
                                      String title,
                                      String subtitle,
                                      IconData icon,
                                      Color color,
                                    })
                                  >[
                                    (
                                      title: 'WhatsApp Order',
                                      subtitle: 'Fast support',
                                      icon: Icons.chat_rounded,
                                      color: Color(0xFF25D366),
                                    ),
                                    (
                                      title: 'Upload Prescription',
                                      subtitle: '10% off',
                                      icon: Icons.upload_file_rounded,
                                      color: AppColors.accentOrange,
                                    ),
                                    (
                                      title: 'Healthcare Deals',
                                      subtitle: 'Save more',
                                      icon: Icons.favorite_rounded,
                                      color: AppColors.primary,
                                    ),
                                    (
                                      title: 'Call to Order',
                                      subtitle: '01325188042',
                                      icon: Icons.call_rounded,
                                      color: AppColors.accentBlue,
                                    ),
                                    (
                                      title: 'Lab Test',
                                      subtitle: 'Book now',
                                      icon: Icons.science_rounded,
                                      color: Color(0xFF1E88E5),
                                    ),
                                    (
                                      title: 'Doctor Consult',
                                      subtitle: 'Coming Soon',
                                      icon: Icons.medical_services_outlined,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ];

                              return GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisExtent: mainAxisExtent,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                    ),
                                itemCount: actions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final action = actions[index];
                                  final VoidCallback onTap = switch (index) {
                                    0 => () => context.push('/contact'),
                                    1 => () => context.push(
                                      '/prescriptions/upload',
                                    ),
                                    2 => () => context.push(
                                      '/products?category=healthcare',
                                    ),
                                    3 => () => context.push('/contact'),
                                    4 => () => context.go('/lab-test'),
                                    _ => () => context.push(
                                      '/doctor-consultation',
                                    ),
                                  };
                                  return _QuickAction(
                                    title: action.title,
                                    subtitle: action.subtitle,
                                    icon: action.icon,
                                    color: action.color,
                                    onTap: onTap,
                                  );
                                },
                              );
                            },
                      ),
                    ),
                    _HorizontalSection(
                      title: 'Flash Sale',
                      onSeeAll: () => context.push('/flash-sale'),
                      products: flash,
                      trailing: const _TimerPill(),
                    ),
                    _HorizontalSection(
                      title: 'Medicine Deals',
                      onSeeAll: () =>
                          context.push('/products?category=medicines'),
                      products: medicines,
                    ),
                    _HorizontalSection(
                      title: 'Healthcare Devices',
                      onSeeAll: () =>
                          context.push('/products?category=healthcare'),
                      products: devices,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () => context.go('/lab-test'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentBlue, AppColors.primary],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Book Lab Tests',
                                style: AppTextStyles.h1.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Up to 25% OFF with home sample collection',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _HorizontalSection(
                      title: 'Supplement Deals',
                      onSeeAll: () =>
                          context.push('/products?category=supplement'),
                      products: supplements,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('medicines', 'Medicine'),
      ('healthcare', 'Healthcare'),
      ('supplement', 'Supplement'),
      ('diabetic-care', 'Diabetic Care'),
      ('cardiac-care', 'Cardiac Care'),
      ('baby-mom-care', 'Baby & Mom'),
      ('herbal', 'Herbal'),
      ('homeopathy', 'Homeopathy'),
      ('pet-care', 'Pet Care'),
    ];
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Categories',
        showSearch: true,
        showCart: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: AppLayout.cardGrid(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 112,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => context.push('/category/${category.$1}'),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Center(
                child: Text(
                  category.$2,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryHomeScreen extends StatelessWidget {
  const CategoryHomeScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final products = mockMedicines
        .where(
          (item) =>
              item.categorySlug == slug ||
              (slug == 'medicines' && item.categorySlug == 'medicines'),
        )
        .toList();
    const subCategories = [
      'Tablet',
      'Capsule',
      'Syrup',
      'Injection',
      'Cream',
      'Eye Drops',
      'Inhaler',
      'Diabetic',
      'Cardiac',
      'Antibiotic',
      'Pediatric',
      'Pain Relief',
    ];
    const brands = [
      'Square',
      'Beximco',
      'Incepta',
      'ACI',
      'Renata',
      'Aristopharma',
    ];
    return Scaffold(
      appBar: HealMealAppBar(
        title: slug.replaceAll('-', ' ').toUpperCase(),
        showBack: true,
        showSearch: true,
        showCart: true,
      ),
      body: CustomScrollView(
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
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            slug.replaceAll('-', ' ').toUpperCase(),
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.medication_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final int columns = constraints.maxWidth < 360
                              ? 2
                              : 3;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisExtent: 38,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: subCategories.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  subCategories[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          );
                        },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 76,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Container(
                        width: 88,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            brands[index],
                            style: AppTextStyles.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: brands.length,
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
                final product = products.isNotEmpty
                    ? products[index % products.length]
                    : mockMedicines[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push('/product/${product.id}'),
                  onAddToCart: () => context.read<CartCubit>().addItem(product),
                );
              }, childCount: products.isNotEmpty ? products.length : 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final List<Color> colors;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 56, color: Colors.white),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(.14),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyXSmall.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.title,
    required this.products,
    this.onSeeAll,
    this.trailing,
  });

  final String title;
  final List<MockProduct> products;
  final VoidCallback? onSeeAll;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: title,
              onSeeAll: onSeeAll,
              trailing: trailing,
            ),
          ),
          SizedBox(
            height: 318,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  style: ProductCardStyle.horizontalScroll,
                  onTap: () => context.push('/product/${product.id}'),
                  onAddToCart: () => context.read<CartCubit>().addItem(product),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: products.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPill extends StatefulWidget {
  const _TimerPill();

  @override
  State<_TimerPill> createState() => _TimerPillState();
}

class _TimerPillState extends State<_TimerPill> {
  late DateTime end;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    end = DateTime.now().add(
      const Duration(hours: 23, minutes: 45, seconds: 12),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = end.difference(DateTime.now());
    final text =
        '${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
      ),
    );
  }
}
