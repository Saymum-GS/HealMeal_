import 'package:equatable/equatable.dart';

import '../../../core/data/models.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.orders = const <AppOrder>[],
    this.lastPlacedAppOrderId,
    this.loaded = false,
  });

  final List<AppOrder> orders;
  final String? lastPlacedAppOrderId;
  final bool loaded;

  OrdersState copyWith({
    List<AppOrder>? orders,
    String? lastPlacedAppOrderId,
    bool? loaded,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      lastPlacedAppOrderId: lastPlacedAppOrderId ?? this.lastPlacedAppOrderId,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => <Object?>[orders, lastPlacedAppOrderId, loaded];
}

