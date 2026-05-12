import 'package:equatable/equatable.dart';

import '../../../core/data/models.dart';

class CartEntry extends Equatable {
  const CartEntry({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  CartEntry copyWith({Product? product, int? quantity}) {
    return CartEntry(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get subtotal => product.salePrice * quantity;

  @override
  List<Object?> get props => [product, quantity];
}

class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.couponCode,
    this.cashbackEnabled = false,
    this.selectedPaymentMethod = PaymentMethod.cod,
    this.notifiedProductIds = const {},
    this.hasApprovedPrescription = false,
  });

  final List<CartEntry> items;
  final String? couponCode;
  final bool cashbackEnabled;
  final PaymentMethod selectedPaymentMethod;
  final Set<String> notifiedProductIds;
  final bool hasApprovedPrescription;

  CartState copyWith({
    List<CartEntry>? items,
    String? couponCode,
    bool? cashbackEnabled,
    PaymentMethod? selectedPaymentMethod,
    Set<String>? notifiedProductIds,
    bool? hasApprovedPrescription,
  }) {
    return CartState(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      cashbackEnabled: cashbackEnabled ?? this.cashbackEnabled,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      notifiedProductIds: notifiedProductIds ?? this.notifiedProductIds,
      hasApprovedPrescription:
          hasApprovedPrescription ?? this.hasApprovedPrescription,
    );
  }

  @override
  List<Object?> get props => [
    items,
    couponCode,
    cashbackEnabled,
    selectedPaymentMethod,
    notifiedProductIds,
    hasApprovedPrescription,
  ];
}

