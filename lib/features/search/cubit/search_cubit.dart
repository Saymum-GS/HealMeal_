import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models.dart';
import 'package:equatable/equatable.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  Future<void> search(String query, List<Product> allProducts) async {
    if (query.trim().isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final results = allProducts
        .where(
          (item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.brandName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    emit(
      state.copyWith(
        status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
        query: query,
        results: results,
      ),
    );
  }
}

