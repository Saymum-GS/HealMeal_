import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/models.dart';
import '../../cart/cubit/cart_state.dart';
import '../../checkout/cubit/checkout_state.dart';
import 'orders_state.dart';
import '../../../core/utils/app_session.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState(orders: []));

  static const String _lastPlacedKey = 'healmeal_last_order.id';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastPlacedAppOrderId = prefs.getString(_lastPlacedKey);
    final userId = AppSession.userId;

    try {
      Query query = _firestore.collection('orders').orderBy('placedAt', descending: true);
      
      // If not admin, only show user's own orders
      if (AppSession.currentUserRole != UserRole.admin) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      
      final List<AppOrder> orders = snapshot.docs
          .map((doc) => AppOrder.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
          
      emit(
        OrdersState(
          orders: orders,
          lastPlacedAppOrderId: lastPlacedAppOrderId,
          loaded: true,
        ),
      );

      // Trigger refill check after loading
      _checkRefills(orders);
    } catch (e) {
      debugPrint('Error loading orders: $e');
      emit(
        OrdersState(
          orders: [],
          lastPlacedAppOrderId: lastPlacedAppOrderId,
          loaded: true,
        ),
      );
    }
  }

  void _checkRefills(List<AppOrder> orders) {
    if (orders.isEmpty) return;
    
    final now = DateTime.now();
    for (final order in orders) {
      // If order was placed 27-30 days ago and is delivered
      final diff = now.difference(order.placedAt).inDays;
      if (diff >= 27 && diff <= 30 && order.status == OrderStatus.delivered) {
        // Check if user already notified for this order recently
        // (In a real app, we'd check a 'notifications' collection)
        _createRefillNotification(order);
      }
    }
  }

  Future<void> _createRefillNotification(AppOrder order) async {
    final userId = AppSession.userId;
    if (userId == null) return;

    final notification = AppNotification(
      id: 'refill-${order.id}',
      title: 'Time for Refill!',
      body: 'Your medicines from order ${order.id} might be running out. Would you like to reorder?',
      time: DateTime.now(),
      type: 'refill',
    );

    // Save to Firestore
    await _firestore.collection('users').doc(userId).collection('notifications').doc(notification.id).set(notification.toMap());
  }

  AppOrder? get lastPlacedAppOrder {
    final String? id = state.lastPlacedAppOrderId;
    if (id == null || id.isEmpty) return null;
    return findById(id);
  }

  AppOrder? findById(String id) {
    final String normalized = id.replaceAll('#', '').trim().toUpperCase();
    for (final AppOrder order in state.orders) {
      if (order.id.replaceAll('#', '').trim().toUpperCase() == normalized) {
        return order;
      }
    }
    return null;
  }

  Future<AppOrder> placeOrder({
    required CartState cartState,
    required CheckoutState checkoutState,
    required Address deliveryAddress,
  }) async {
    final DateTime placedAt = DateTime.now();
    final double subtotal = cartState.items.fold(0.0, (sum, item) => sum + item.subtotal);
    final double discount = _calculateDiscount(cartState, subtotal);
    final double deliveryCharge = subtotal >= 500 ? 0 : 60;
    final double cashbackUsed = cartState.cashbackEnabled
        ? (subtotal * .08).clamp(0, 125.5).toDouble()
        : 0;
    final double total = subtotal - discount - cashbackUsed + deliveryCharge;

    final AppOrder order = AppOrder(
      id: _buildOrderId(placedAt),
      status: OrderStatus.placed,
      paymentMethod: checkoutState.selectedPaymentMethod,
      paymentStatus: checkoutState.selectedPaymentMethod == PaymentMethod.cod
          ? 'pending'
          : 'paid',
      items: cartState.items
          .map(
            (CartEntry item) => AppOrderItem(
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
      userId: AppSession.userId,
    );

    final batch = _firestore.batch();
    batch.set(_firestore.collection('orders').doc(order.id), order.toMap());

    // Decrement Stock
    for (final item in cartState.items) {
      batch.update(_firestore.collection('products').doc(item.product.id), {
        'stockLeft': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();

    emit(
      state.copyWith(
        orders: [order, ...state.orders],
        lastPlacedAppOrderId: order.id,
        loaded: true,
      ),
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlacedKey, order.id);
    
    return order;
  }

  double _calculateDiscount(CartState cartState, double subtotal) {
    final String? code = cartState.couponCode?.trim().toUpperCase();
    if (code == 'SAVE20') return subtotal * .2;
    if (code == 'NEWUSER50' || code == 'REFILL10') return subtotal * .1;
    if (code == 'LAB25') return subtotal * .05;
    return 0;
  }

  String _buildOrderId(DateTime date) {
    final prefix = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final suffix = (date.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return '#ORD-$prefix-$suffix';
  }

  List<AppOrderTimeline> _buildTimeline(DateTime placedAt, OrderStatus status) {
    final steps = OrderStatus.values.where((s) => s != OrderStatus.cancelled).toList();
    return steps.map((s) => AppOrderTimeline(
      status: s.label,
      time: placedAt.add(Duration(hours: s.index * 2)),
      completed: s.index <= status.index,
    )).toList();
  }
}
