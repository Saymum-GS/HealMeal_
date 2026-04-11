import 'package:equatable/equatable.dart';

import '../../../core/mock_data/mock_models.dart';

class ProductState extends Equatable {
  const ProductState({
    this.loading = true,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.activeCategory,
  });

  final bool loading;
  final List<MockProduct> allProducts;
  final List<MockProduct> filteredProducts;
  final String? activeCategory;

  ProductState copyWith({
    bool? loading,
    List<MockProduct>? allProducts,
    List<MockProduct>? filteredProducts,
    String? activeCategory,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    allProducts,
    filteredProducts,
    activeCategory,
  ];
}
