import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/mock_data/mock_models.dart';
import '../../../core/mock_data/mock_orders.dart';
import '../../../core/mock_data/mock_products.dart';
import '../../cart/cubit/cart_state.dart';
import '../../checkout/cubit/checkout_state.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState(orders: mockOrders));

  static const String _ordersKey = 'healmeal_orders';
  static const String _lastPlacedKey = 'healmeal_last_order_id';

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedOrders = prefs.getString(_ordersKey);
    final String? lastPlacedOrderId = prefs.getString(_lastPlacedKey);

    if (encodedOrders == null || encodedOrders.isEmpty) {
      final List<MockOrder> seeded = _sortedOrders(mockOrders);
      emit(
        OrdersState(
          orders: seeded,
          lastPlacedOrderId: lastPlacedOrderId,
          loaded: true,
        ),
      );
      await _persist(seeded, lastPlacedOrderId: lastPlacedOrderId);
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(encodedOrders) as List<dynamic>;
      final List<MockOrder> orders = decoded
          .whereType<Map<String, dynamic>>()
          .map(_decodeOrder)
          .toList();
      emit(
        OrdersState(
          orders: _sortedOrders(orders.isEmpty ? mockOrders : orders),
          lastPlacedOrderId: lastPlacedOrderId,
          loaded: true,
        ),
      );
    } catch (_) {
      final List<MockOrder> fallback = _sortedOrders(mockOrders);
      emit(
        OrdersState(
          orders: fallback,
          lastPlacedOrderId: lastPlacedOrderId,
          loaded: true,
        ),
      );
      await _persist(fallback, lastPlacedOrderId: lastPlacedOrderId);
    }
  }

  MockOrder? findById(String id) {
    final String normalized = _normalizeId(id);
    for (final MockOrder order in state.orders) {
      if (_normalizeId(order.id) == normalized) {
        return order;
      }
    }
    return null;
  }

  MockOrder? get lastPlacedOrder {
    final String? id = state.lastPlacedOrderId;
    if (id == null || id.isEmpty) {
      return null;
    }
    return findById(id);
  }

  Future<MockOrder> placeOrder({
    required CartState cartState,
    required CheckoutState checkoutState,
    required MockAddress deliveryAddress,
  }) async {
    final DateTime placedAt = DateTime.now();
    final double subtotal = _subtotalFrom(cartState);
    final double discount = _discountFrom(cartState, subtotal);
    final double deliveryCharge = subtotal >= 500 ? 0 : 60;
    final double cashbackUsed = cartState.cashbackEnabled
        ? (subtotal * .08).clamp(0, 125.5).toDouble()
        : 0;
    final double total = subtotal - discount - cashbackUsed + deliveryCharge;

    final MockOrder order = MockOrder(
      id: _buildOrderId(placedAt),
      status: OrderStatus.placed,
      paymentMethod: checkoutState.selectedPaymentMethod,
      paymentStatus: checkoutState.selectedPaymentMethod == PaymentMethod.cod
          ? 'pending'
          : 'paid',
      items: cartState.items
          .map(
            (CartEntry item) => MockOrderItem(
              id: 'oi-${placedAt.microsecondsSinceEpoch}-${item.product.id}',
              product: item.product,
              quantity: item.quantity,
            ),
          )
          .toList(),
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      cashbackUsed: cashbackUsed,
      total: total,
      placedAt: placedAt,
      deliveryAddress: deliveryAddress,
      timeline: _buildTimeline(placedAt, OrderStatus.placed),
      rider: null,
    );

    final List<MockOrder> nextOrders = _sortedOrders(<MockOrder>[
      order,
      ...state.orders,
    ]);
    emit(
      state.copyWith(
        orders: nextOrders,
        lastPlacedOrderId: order.id,
        loaded: true,
      ),
    );
    await _persist(nextOrders, lastPlacedOrderId: order.id);
    return order;
  }

  Future<void> _persist(
    List<MockOrder> orders, {
    String? lastPlacedOrderId,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey,
      jsonEncode(orders.map(_encodeOrder).toList()),
    );
    final String? lastId = lastPlacedOrderId ?? state.lastPlacedOrderId;
    if (lastId != null && lastId.isNotEmpty) {
      await prefs.setString(_lastPlacedKey, lastId);
    }
  }

  static List<MockOrder> _sortedOrders(List<MockOrder> orders) {
    final List<MockOrder> next = List<MockOrder>.from(orders);
    next.sort((MockOrder a, MockOrder b) => b.placedAt.compareTo(a.placedAt));
    return next;
  }

  static String _normalizeId(String id) =>
      id.replaceAll('#', '').trim().toUpperCase();

  static String _buildOrderId(DateTime date) {
    final String prefix =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final String suffix = (date.millisecondsSinceEpoch % 1000)
        .toString()
        .padLeft(3, '0');
    return '#ORD-$prefix-$suffix';
  }

  static double _subtotalFrom(CartState cartState) => cartState.items
      .fold<double>(0, (double sum, CartEntry item) => sum + item.subtotal);

  static double _discountFrom(CartState cartState, double subtotal) {
    final String? code = cartState.couponCode?.trim().toUpperCase();
    switch (code) {
      case 'SAVE20':
        return subtotal * .2;
      case 'NEWUSER50':
      case 'REFILL10':
        return subtotal * .1;
      case 'LAB25':
        return subtotal * .05;
      default:
        return 0;
    }
  }

  static List<MockTimeline> _buildTimeline(
    DateTime placedAt,
    OrderStatus status,
  ) {
    final List<OrderStatus> steps = <OrderStatus>[
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.dispatched,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    if (status == OrderStatus.cancelled) {
      return <MockTimeline>[
        MockTimeline(
          status: OrderStatus.placed.label,
          time: placedAt,
          completed: true,
        ),
        MockTimeline(
          status: OrderStatus.cancelled.label,
          time: placedAt.add(const Duration(minutes: 45)),
          completed: true,
        ),
      ];
    }

    return steps.asMap().entries.map((MapEntry<int, OrderStatus> entry) {
      return MockTimeline(
        status: entry.value.label,
        time: placedAt.add(Duration(hours: entry.key == 0 ? 0 : entry.key * 2)),
        completed: entry.value.index <= status.index,
      );
    }).toList();
  }

  static Map<String, dynamic> _encodeOrder(MockOrder order) {
    return <String, dynamic>{
      'id': order.id,
      'status': order.status.name,
      'paymentMethod': order.paymentMethod.name,
      'paymentStatus': order.paymentStatus,
      'subtotal': order.subtotal,
      'discount': order.discount,
      'deliveryCharge': order.deliveryCharge,
      'cashbackUsed': order.cashbackUsed,
      'total': order.total,
      'placedAt': order.placedAt.toIso8601String(),
      'deliveryAddress': _encodeAddress(order.deliveryAddress),
      'timeline': order.timeline.map(_encodeTimeline).toList(),
      'items': order.items.map(_encodeItem).toList(),
      'rider': order.rider == null ? null : _encodeRider(order.rider!),
    };
  }

  static MockOrder _decodeOrder(Map<String, dynamic> json) {
    return MockOrder(
      id: json['id'] as String? ?? '#ORD-UNKNOWN',
      status: _decodeOrderStatus(json['status'] as String?),
      paymentMethod: _decodePaymentMethod(json['paymentMethod'] as String?),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_decodeItem)
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0,
      cashbackUsed: (json['cashbackUsed'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      placedAt:
          DateTime.tryParse(json['placedAt'] as String? ?? '') ??
          DateTime.now(),
      deliveryAddress: _decodeAddress(
        json['deliveryAddress'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      timeline: (json['timeline'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_decodeTimeline)
          .toList(),
      rider: json['rider'] is Map<String, dynamic>
          ? _decodeRider(json['rider'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, dynamic> _encodeItem(MockOrderItem item) {
    return <String, dynamic>{
      'id': item.id,
      'productId': item.product.id,
      'quantity': item.quantity,
    };
  }

  static MockOrderItem _decodeItem(Map<String, dynamic> json) {
    final String productId =
        json['productId'] as String? ?? mockMedicines.first.id;
    final MockProduct product = mockMedicines.firstWhere(
      (MockProduct item) => item.id == productId,
      orElse: () => mockMedicines.first,
    );
    return MockOrderItem(
      id: json['id'] as String? ?? 'oi-${product.id}',
      product: product,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  static Map<String, dynamic> _encodeAddress(MockAddress address) {
    return <String, dynamic>{
      'id': address.id,
      'label': address.label,
      'recipientName': address.recipientName,
      'phoneNumber': address.phoneNumber,
      'district': address.district,
      'upazila': address.upazila,
      'area': address.area,
      'houseFlat': address.houseFlat,
      'roadStreet': address.roadStreet,
      'landmark': address.landmark,
      'isDefault': address.isDefault,
    };
  }

  static MockAddress _decodeAddress(Map<String, dynamic> json) {
    return MockAddress(
      id: json['id'] as String? ?? 'addr-local',
      label: json['label'] as String? ?? 'Saved',
      recipientName: json['recipientName'] as String? ?? 'Customer',
      phoneNumber: json['phoneNumber'] as String? ?? '01700000000',
      district: json['district'] as String? ?? 'Dhaka',
      upazila: json['upazila'] as String? ?? 'Dhaka',
      area: json['area'] as String? ?? 'Bangladesh',
      houseFlat: json['houseFlat'] as String? ?? '',
      roadStreet: json['roadStreet'] as String? ?? '',
      landmark: json['landmark'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _encodeTimeline(MockTimeline timeline) {
    return <String, dynamic>{
      'status': timeline.status,
      'time': timeline.time.toIso8601String(),
      'completed': timeline.completed,
    };
  }

  static MockTimeline _decodeTimeline(Map<String, dynamic> json) {
    return MockTimeline(
      status: json['status'] as String? ?? OrderStatus.placed.label,
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      completed: json['completed'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _encodeRider(MockRider rider) {
    return <String, dynamic>{
      'name': rider.name,
      'phone': rider.phone,
      'rating': rider.rating,
    };
  }

  static MockRider _decodeRider(Map<String, dynamic> json) {
    return MockRider(
      name: json['name'] as String? ?? 'HealMeal Rider',
      phone: json['phone'] as String? ?? '01700000000',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  static OrderStatus _decodeOrderStatus(String? value) {
    return OrderStatus.values.firstWhere(
      (OrderStatus status) => status.name == value,
      orElse: () => OrderStatus.placed,
    );
  }

  static PaymentMethod _decodePaymentMethod(String? value) {
    return PaymentMethod.values.firstWhere(
      (PaymentMethod method) => method.name == value,
      orElse: () => PaymentMethod.cod,
    );
  }
}
