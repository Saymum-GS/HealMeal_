import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_formatters.dart';
import '../../core/localization/app_localizations.dart';
import '../cart/cubit/cart_cubit.dart';

class CheckoutCouponStep extends StatelessWidget {
  const CheckoutCouponStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: cartCubit.state.cashbackEnabled,
          onChanged: (_) => cartCubit.toggleCashback(true),
          title: Text(context.strings.useCashback),
          subtitle: Text('${context.strings.balance}: ${AppFormatters.taka(125.5)}'),
        ),
      ],
    );
  }
}
