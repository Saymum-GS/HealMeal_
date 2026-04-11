import 'package:equatable/equatable.dart';

import '../../../core/mock_data/mock_models.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.orders = const <MockOrder>[],
    this.lastPlacedOrderId,
    this.loaded = false,
  });

  final List<MockOrder> orders;
  final String? lastPlacedOrderId;
  final bool loaded;

  OrdersState copyWith({
    List<MockOrder>? orders,
    String? lastPlacedOrderId,
    bool? loaded,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      lastPlacedOrderId: lastPlacedOrderId ?? this.lastPlacedOrderId,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => <Object?>[orders, lastPlacedOrderId, loaded];
}
