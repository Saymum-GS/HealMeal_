import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistCubit extends Cubit<List<String>> {
  WishlistCubit() : super(const []);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getStringList('wishlist') ?? const []);
  }

  Future<void> toggle(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(state);
    if (list.contains(productId)) {
      list.remove(productId);
    } else {
      list.add(productId);
    }
    await prefs.setStringList('wishlist', list);
    emit(list);
  }
}

