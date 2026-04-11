import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    emit(state.copyWith(loading: false));
  }

  void setBanner(int index) {
    emit(state.copyWith(activeBanner: index));
  }
}
