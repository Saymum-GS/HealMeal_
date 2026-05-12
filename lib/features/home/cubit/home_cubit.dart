import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/offer_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OfferRepository _offerRepository;
  StreamSubscription? _offerSubscription;

  HomeCubit({required OfferRepository offerRepository}) 
    : _offerRepository = offerRepository,
      super(const HomeState()) {
    _initOffers();
  }

  void _initOffers() {
    _offerSubscription = _offerRepository.watchOffers().listen((offers) {
      emit(state.copyWith(offers: offers, loading: false));
    });
  }

  Future<void> load() async {
    // Already handled by stream, but keeping for compatibility
    emit(state.copyWith(loading: false));
  }

  void setBanner(int index) {
    emit(state.copyWith(activeBanner: index));
  }

  @override
  Future<void> close() {
    _offerSubscription?.cancel();
    return super.close();
  }
}

