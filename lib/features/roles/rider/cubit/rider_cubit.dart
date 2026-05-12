import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models.dart';
import '../../../../core/repositories/order_repository.dart';

class RiderState {
  final List<AppOrder> assignedOrders;
  final List<AppOrder> pickedUpOrders;
  final List<AppOrder> deliveredOrders;
  final bool isLoading;
  final String? error;

  const RiderState({
    this.assignedOrders = const [],
    this.pickedUpOrders = const [],
    this.deliveredOrders = const [],
    this.isLoading = false,
    this.error,
  });

  RiderState copyWith({
    List<AppOrder>? assignedOrders,
    List<AppOrder>? pickedUpOrders,
    List<AppOrder>? deliveredOrders,
    bool? isLoading,
    String? error,
  }) {
    return RiderState(
      assignedOrders: assignedOrders ?? this.assignedOrders,
      pickedUpOrders: pickedUpOrders ?? this.pickedUpOrders,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RiderCubit extends Cubit<RiderState> {
  final OrderRepository _orderRepository;
  StreamSubscription<List<AppOrder>>? _subscription;

  RiderCubit({required OrderRepository orderRepository}) 
    : _orderRepository = orderRepository,
      super(const RiderState()) {
    _initStream();
  }

  void _initStream() {
    emit(state.copyWith(isLoading: true));
    _subscription = _orderRepository.watchRiderOrders().listen(
      (orders) {
        final assigned = orders.where((o) => o.status == OrderStatus.dispatched).toList();
        final pickedUp = orders.where((o) => o.status == OrderStatus.outForDelivery).toList();
        final delivered = orders.where((o) => o.status == OrderStatus.delivered).toList();
        
        emit(state.copyWith(
          assignedOrders: assigned,
          pickedUpOrders: pickedUp,
          deliveredOrders: delivered,
          isLoading: false,
        ));
      },
      onError: (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      },
    );
  }

  Future<void> markPickedUp(String orderId) async {
    await _orderRepository.updateOrderStatus(orderId, OrderStatus.outForDelivery);
  }

  Future<void> markDelivered(String orderId) async {
    await _orderRepository.updateOrderStatus(orderId, OrderStatus.delivered);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

