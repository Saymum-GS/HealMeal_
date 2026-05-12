import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/common/info_banner.dart';
import '../checkout/cubit/checkout_cubit.dart';

class CheckoutSlotStep extends StatelessWidget {
  const CheckoutSlotStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CheckoutCubit>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(context.strings.express),
              selected: cubit.state.deliveryType == 'express',
              onSelected: (_) => cubit.selectDeliveryType('express'),
            ),
            ChoiceChip(
              label: Text(context.strings.standard),
              selected: cubit.state.deliveryType == 'standard',
              onSelected: (_) => cubit.selectDeliveryType('standard'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoBanner(
          title: context.strings.freeDelivery,
          body: context.strings.freeDeliveryRequirement,
          type: InfoBannerType.success,
        ),
      ],
    );
  }
}
