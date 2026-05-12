import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(const ProductState());

  StreamSubscription? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void load() {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      final products = snapshot.docs.map((doc) {
        try {
          return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          debugPrint('Error parsing product ${doc.id}: $e');
          return null;
        }
      }).whereType<Product>().toList();

      emit(
        state.copyWith(
          loading: false,
          allProducts: products,
          filteredProducts: products,
        ),
      );
    }, onError: (e) {
      emit(
        state.copyWith(
          loading: false,
          allProducts: [],
          filteredProducts: [],
        ),
      );
    });
  }

  void filter({String? category, String? query}) {
    emit(state.copyWith(loading: true));
    
    var products = List.of(state.allProducts);
    final activeCategory = category ?? state.activeCategory;

    if (activeCategory != null && activeCategory.isNotEmpty && activeCategory != 'all') {
      products = products
          .where((item) => item.categorySlug == activeCategory)
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

    _applySortAndEmit(products, activeCategory, state.sortBy);
  }

  void sort(ProductSort sortBy) {
    _applySortAndEmit(List.of(state.filteredProducts), state.activeCategory, sortBy);
  }

  void _applySortAndEmit(List<Product> products, String? category, ProductSort sortBy) {
    switch (sortBy) {
      case ProductSort.priceLowToHigh:
        products.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case ProductSort.priceHighToLow:
        products.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case ProductSort.rating:
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSort.newest:
        products.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA); // Newest first
        });
        break;
      case ProductSort.alphabetical:
        products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ProductSort.discount:
        products.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case ProductSort.relevance:
        // Default order
        break;
    }

    emit(state.copyWith(
      loading: false,
      filteredProducts: products,
      activeCategory: category,
      sortBy: sortBy,
    ));
  }
}

