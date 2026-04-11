import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/mock_data/mock_products.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(const ProductState());

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    emit(
      state.copyWith(
        loading: false,
        allProducts: mockMedicines,
        filteredProducts: mockMedicines,
      ),
    );
  }

  void filter({String? category, String? query}) {
    var products = List.of(state.allProducts);
    if (category != null && category.isNotEmpty && category != 'all') {
      products = products
          .where((item) => item.categorySlug == category)
          .toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final needle = query.toLowerCase();
      products = products
          .where(
            (item) =>
                item.name.toLowerCase().contains(needle) ||
                item.brandName.toLowerCase().contains(needle),
          )
          .toList();
    }
    emit(state.copyWith(filteredProducts: products, activeCategory: category));
  }
}
