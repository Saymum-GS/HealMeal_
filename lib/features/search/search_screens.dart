import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/product_card.dart';
import '../../core/widgets/common/skeleton_loader.dart';
import '../products/cubit/product_cubit.dart';
import '../cart/cubit/cart_cubit.dart';
import '../search/cubit/search_cubit.dart';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = context.watch<ProductCubit>().state;
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
                  context.read<SearchCubit>().search('', productState.allProducts);
                },
              ),
              onChanged: (value) => context.read<SearchCubit>().search(value, productState.allProducts),
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
                                    context.read<SearchCubit>().search(e, productState.allProducts);
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
                                    context.read<SearchCubit>().search(e, productState.allProducts);
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

