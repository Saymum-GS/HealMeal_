import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  const HomeState({this.loading = true, this.activeBanner = 0});

  final bool loading;
  final int activeBanner;

  HomeState copyWith({bool? loading, int? activeBanner}) {
    return HomeState(
      loading: loading ?? this.loading,
      activeBanner: activeBanner ?? this.activeBanner,
    );
  }

  @override
  List<Object?> get props => [loading, activeBanner];
}
