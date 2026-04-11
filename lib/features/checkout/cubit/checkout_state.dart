import 'package:equatable/equatable.dart';

import '../../../core/mock_data/mock_models.dart';

class CheckoutState extends Equatable {
  const CheckoutState({
    this.selectedAddressId = 'addr-1',
    this.deliveryType = 'express',
    this.selectedDate,
    this.selectedTimeSlot = 'Evening 5-9',
    this.appliedCoupon,
    this.useCashback = false,
    this.selectedPaymentMethod = PaymentMethod.cod,
  });

  final String selectedAddressId;
  final String deliveryType;
  final DateTime? selectedDate;
  final String selectedTimeSlot;
  final String? appliedCoupon;
  final bool useCashback;
  final PaymentMethod selectedPaymentMethod;

  CheckoutState copyWith({
    String? selectedAddressId,
    String? deliveryType,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? appliedCoupon,
    bool? useCashback,
    PaymentMethod? selectedPaymentMethod,
  }) {
    return CheckoutState(
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      deliveryType: deliveryType ?? this.deliveryType,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      useCashback: useCashback ?? this.useCashback,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
    selectedAddressId,
    deliveryType,
    selectedDate,
    selectedTimeSlot,
    appliedCoupon,
    useCashback,
    selectedPaymentMethod,
  ];
}
