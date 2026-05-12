import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutState(selectedDate: DateTime.now()));

  void selectAddress(String id) => emit(state.copyWith(selectedAddressId: id));
  void selectDeliveryType(String value) =>
      emit(state.copyWith(deliveryType: value));
  void selectDate(DateTime value) => emit(state.copyWith(selectedDate: value));
  void selectTimeSlot(String value) =>
      emit(state.copyWith(selectedTimeSlot: value));
  void applyCoupon(String? value) => emit(state.copyWith(appliedCoupon: value));
  void toggleCashback(bool value) => emit(state.copyWith(useCashback: value));
  void selectPayment(PaymentMethod method) =>
      emit(state.copyWith(selectedPaymentMethod: method));
}

