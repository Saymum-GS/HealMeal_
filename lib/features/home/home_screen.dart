import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings_en.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/common/brand_lockup.dart';
import '../../core/widgets/common/healmeal_image.dart';
import '../../core/widgets/common/product_card.dart';
import '../../core/widgets/common/section_header.dart';
import '../cart/cubit/cart_cubit.dart';
import '../home/cubit/home_cubit.dart';
import '../home/cubit/home_state.dart';
import '../products/cubit/product_cubit.dart';
import '../../core/utils/app_session.dart';
import '../../core/repositories/prescription_repository.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productState = context.watch<ProductCubit>().state;
    final homeState = context.watch<HomeCubit>().state;
    
    if (productState.loading || homeState.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final allProducts = productState.allProducts;
    final flash = allProducts.where((p) => p.isFlashSale).take(6).toList();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        final categoryDocs = snapshot.data?.docs ?? [];
        final categories = categoryDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (
            doc.id,
            data['name'] as String,
            _getCategoryIcon(data['icon'] as String? ?? 'category_rounded'),
          );
        }).toList();

        final strings = context.strings;

        if (!categories.any((c) => c.$1 == 'flash-sale')) {
          categories.insert(0, ('flash-sale', strings.flashSale, Icons.local_fire_department_rounded));
        }

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
                        icon: const Icon(Icons.search_rounded, color: AppColors.white),
                      ),
                      IconButton(
                        onPressed: () => context.push('/cart'),
                        icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.white),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(74),
                      child: GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.muted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  strings.searchHint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary),
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
                        _PrescriptionBanner(),
                        const SizedBox(height: 8),
                        _buildHeroSlider(context, state, strings),
                        const SizedBox(height: 10),
                        _buildPageIndicator(state),
                        const SizedBox(height: 16),
                        _buildCategoryGrid(context, categories),
                        const SizedBox(height: 16),
                        _buildQuickActions(context),
                        if (flash.isNotEmpty)
                          _HorizontalSection(
                            title: 'Flash Sale',
                            onSeeAll: () => context.push('/flash-sale'),
                            products: flash,
                            trailing: const _TimerPill(),
                          ),
                        _buildLabTestPromo(context),
                        ...categories.where((c) => c.$1 != 'flash-sale' && c.$1 != 'lab').map((cat) {
                          final catProducts = allProducts.where((p) => p.categorySlug == cat.$1).take(6).toList();
                          if (catProducts.isEmpty) return const SizedBox.shrink();
                          return _HorizontalSection(
                            title: '${cat.$2} Deals',
                            onSeeAll: () => context.push('/products?category=${cat.$1}'),
                            products: catProducts,
                          );
                        }),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroSlider(BuildContext context, HomeState state, AppStrings strings) {
    if (state.offers.isEmpty) {
      return CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          viewportFraction: .92,
          onPageChanged: (index, _) => context.read<HomeCubit>().setBanner(index),
        ),
        items: [
          _HeroBannerPlaceholder(
            colors: const [AppColors.primary, Color(0xFF1A9E73)],
            title: strings.seasonalCampaign,
            subtitle: strings.upTo60Off,
            icon: Icons.local_offer_rounded,
          ),
          _HeroBannerPlaceholder(
            colors: const [Color(0xFF084F38), Color(0xFF0B6E4F)],
            title: strings.number1Platform,
            subtitle: strings.trustedMedicineAndCare,
            icon: Icons.medication_rounded,
          ),
        ],
      );
    }
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        viewportFraction: .92,
        onPageChanged: (index, _) => context.read<HomeCubit>().setBanner(index),
      ),
      items: state.offers.map((offer) => _HeroBanner(offer: offer)).toList(),
    );
  }

  Widget _buildPageIndicator(HomeState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        state.offers.isEmpty ? 2 : state.offers.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: index == state.activeBanner ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == state.activeBanner ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<(String, String, IconData)> categories) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isFlash = cat.$1 == 'flash-sale';
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
                color: isFlash ? AppColors.warningBg : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isFlash ? AppColors.warning : Theme.of(context).dividerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.$3, color: isFlash ? AppColors.warning : AppColors.primary),
                  const SizedBox(height: 8),
                  Text(cat.$2, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int crossAxisCount = constraints.maxWidth < 360 ? 2 : 3;
          final double mainAxisExtent = crossAxisCount == 2 ? 124 : 112;
          final actions = [
            (title: 'WhatsApp Order', subtitle: 'Fast support', icon: Icons.chat_rounded, color: const Color(0xFF25D366)),
            (title: 'Upload Prescription', subtitle: '10% off', icon: Icons.upload_file_rounded, color: AppColors.accentOrange),
            (title: 'Healthcare Deals', subtitle: 'Save more', icon: Icons.favorite_rounded, color: AppColors.primary),
            (title: 'Call to Order', subtitle: '01325188042', icon: Icons.call_rounded, color: AppColors.accentBlue),
            (title: 'Lab Test', subtitle: 'Book now', icon: Icons.science_rounded, color: const Color(0xFF1E88E5)),
          ];

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: mainAxisExtent,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _QuickAction(
                title: action.title,
                subtitle: action.subtitle,
                icon: action.icon,
                color: action.color,
                onTap: () {
                  switch (index) {
                    case 0: context.push('/contact'); break;
                    case 1: context.push('/prescriptions/upload'); break;
                    case 2: context.push('/products?category=healthcare'); break;
                    case 3: context.push('/contact'); break;
                    case 4: context.go('/lab-test'); break;
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLabTestPromo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => context.go('/lab-test'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accentBlue, AppColors.primary]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Book Lab Tests', style: AppTextStyles.h1.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Up to 25% OFF with home sample collection', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryLight)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'local_fire_department_rounded': return Icons.local_fire_department_rounded;
      case 'medication_rounded': return Icons.medication_rounded;
      case 'favorite_rounded': return Icons.favorite_rounded;
      case 'health_and_safety_rounded': return Icons.health_and_safety_rounded;
      case 'monitor_heart_rounded': return Icons.monitor_heart_rounded;
      case 'heart_broken_rounded': return Icons.heart_broken_rounded;
      case 'child_care_rounded': return Icons.child_care_rounded;
      case 'spa_rounded': return Icons.spa_rounded;
      case 'favorite_border_rounded': return Icons.favorite_border_rounded;
      case 'face_rounded': return Icons.face_rounded;
      case 'science_rounded': return Icons.science_rounded;
      default: return Icons.category_rounded;
    }
  }
}

// Internal Private Components
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.offer});
  final AppOffer offer;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: offer.colors), borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(offer.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(offer.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryLight)),
              ],
            ),
          ),
          if (offer.imageUrl != null) SizedBox(width: 80, child: HealMealImage(imageUrl: offer.imageUrl!))
          else const Icon(Icons.local_offer_rounded, size: 56, color: Colors.white),
        ],
      ),
    );
  }
}

class _HeroBannerPlaceholder extends StatelessWidget {
  const _HeroBannerPlaceholder({required this.colors, required this.title, required this.subtitle, required this.icon});
  final List<Color> colors;
  final String title;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(subtitle, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryLight)),
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
  const _QuickAction({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
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
        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyXSmall.copyWith(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({required this.title, required this.products, this.onSeeAll, this.trailing});
  final String title;
  final List<Product> products;
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
            child: SectionHeader(title: title, onSeeAll: onSeeAll, trailing: trailing),
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
                  onTap: () => context.push('/product/${product.id}'),
                  onAddToCart: () => context.read<CartCubit>().addItem(product),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 14),
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
  late Timer _timer;
  Duration _duration = const Duration(hours: 4, minutes: 32, seconds: 12);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_duration.inSeconds > 0) {
        setState(() => _duration -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(_duration.inHours);
    final m = twoDigits(_duration.inMinutes.remainder(60));
    final s = twoDigits(_duration.inSeconds.remainder(60));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withOpacity(.3))),
      child: Text('$h:$m:$s', style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold, fontFeatures: [const FontFeature.tabularFigures()])),
    );
  }
}

class _PrescriptionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = AppSession.userId;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<Prescription>>(
      stream: PrescriptionRepository().getUserPrescriptions(userId),
      builder: (context, snapshot) {
        final prescriptions = snapshot.data ?? [];
        final approved = prescriptions.where((p) => p.status == PrescriptionStatus.approved && p.mappedProductIds.isNotEmpty).toList();
        
        if (approved.isEmpty) return const SizedBox.shrink();

        final rx = approved.first;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.success,
                child: Icon(Icons.check_circle_outline, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.strings.prescriptionApprovedBanner, style: AppTextStyles.labelLarge),
                    Text('${rx.mappedProductIds.length}${context.strings.medicinesMapped}', 
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              HealMealButton(
                label: context.strings.addAll,
                size: ButtonSize.small,
                backgroundColor: AppColors.success,
                onPressed: () => _addAllToCart(context, rx.mappedProductIds),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addAllToCart(BuildContext context, List<String> productIds) {
    // In a real app, we'd fetch the product details first.
    // For now, we simulate adding them.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicines from prescription added to cart!')),
    );
    context.push('/cart');
  }
}
