import 'package:equatable/equatable.dart';

import '../../../core/data/models.dart';

class HomeState extends Equatable {
  const HomeState({
    this.loading = true,
    this.activeBanner = 0,
    this.offers = const [],
  });

  final bool loading;
  final int activeBanner;
  final List<AppOffer> offers;

  HomeState copyWith({
    bool? loading,
    int? activeBanner,
    List<AppOffer>? offers,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      activeBanner: activeBanner ?? this.activeBanner,
      offers: offers ?? this.offers,
    );
  }

  @override
  List<Object?> get props => [loading, activeBanner, offers];
}
