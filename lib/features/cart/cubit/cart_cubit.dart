import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit()
    : super(
        const CartState(
          items: [],
        ),
      );

  void addItem(Product product) {
    final items = List<CartEntry>.from(state.items);
    final index = items.indexWhere(
      (element) => element.product.id == product.id,
    );
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartEntry(product: product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  void addMultipleItems(List<Product> products) {
    final items = List<CartEntry>.from(state.items);
    for (final product in products) {
      final index = items.indexWhere(
        (element) => element.product.id == product.id,
      );
      if (index >= 0) {
        items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
      } else {
        items.add(CartEntry(product: product, quantity: 1));
      }
    }
    emit(state.copyWith(items: items));
  }

  void removeItem(String productId) {
    emit(
      state.copyWith(
        items: state.items
            .where((item) => item.product.id != productId)
            .toList(),
      ),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final items = state.items
        .map(
          (item) => item.product.id == productId
              ? item.copyWith(quantity: quantity)
              : item,
        )
        .toList();
    emit(state.copyWith(items: items));
  }

  void applyCoupon(String code) {
    emit(
      state.copyWith(
        couponCode: code.trim().isEmpty ? null : code.trim().toUpperCase(),
      ),
    );
  }

  void removeCoupon() {
    emit(state.copyWith(couponCode: null));
  }

  void toggleCashback(bool enabled) {
    emit(state.copyWith(cashbackEnabled: enabled));
  }

  void selectPayment(PaymentMethod method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }

  void clearCart() {
    emit(state.copyWith(items: []));
  }

  void setPrescriptionApproved(bool approved) {
    emit(state.copyWith(hasApprovedPrescription: approved));
  }

  void notifyWhenAvailable(String productId) {
    final next = Set<String>.from(state.notifiedProductIds)..add(productId);
    emit(state.copyWith(notifiedProductIds: next));
  }

  int get totalCount => state.items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      state.items.fold(0, (sum, item) => sum + item.subtotal);
  double get discountAmount {
    final code = state.couponCode;
    if (code == null) return 0;
    if (code == 'SAVE20') return subtotal * .2;
    if (code == 'NEWUSER50') return subtotal * .1;
    if (code == 'REFILL10') return subtotal * .1;
    if (code == 'LAB25') return subtotal * .05;
    return 0;
  }

  double get deliveryCharge => subtotal >= 500 ? 0 : 60;
  double get cashbackEarned => subtotal * .05;
  double get cashbackUsed =>
      state.cashbackEnabled ? (subtotal * .08).clamp(0, 125.5) : 0;
  double get totalPrice =>
      subtotal - discountAmount - cashbackUsed + deliveryCharge;
}

