import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/app_text_field.dart';
import 'package:raff_app/features/cart/domain/value_objects/cart_pricing.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_option_card.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_step_title.dart';

class CheckoutDeliveryStep extends StatelessWidget {
  final String method;
  final TextEditingController noteController;
  final CartState cartState;
  final ValueChanged<String> onSelect;

  const CheckoutDeliveryStep({
    super.key,
    required this.method,
    required this.noteController,
    required this.cartState,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final standardPrice = cartState.hasFreeShipping
        ? l10n.freeLabel
        : '${CartPricing.standardShippingFee.toStringAsFixed(0)} ${l10n.currencySar}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutStepTitle(l10n.howDeliver),
        CheckoutOptionCard(
          icon: Icons.local_shipping_outlined,
          title: l10n.deliveryStandard,
          subtitle: l10n.deliveryStandardSub,
          aside: standardPrice,
          selected: method == 'standard',
          onTap: () => onSelect('standard'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.bolt_rounded,
          title: l10n.deliveryExpress,
          subtitle: l10n.deliveryExpressSub,
          aside:
              '${CheckoutTotals.expressFee.toStringAsFixed(0)} ${l10n.currencySar}',
          selected: method == 'express',
          onTap: () => onSelect('express'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.storefront_outlined,
          title: l10n.deliveryPickup,
          subtitle: l10n.deliveryPickupSub,
          aside: l10n.freeLabel,
          selected: method == 'pickup',
          onTap: () => onSelect('pickup'),
        ),
        const Gap(12),
        AppTextField(
          label: l10n.courierNote,
          hint: l10n.courierNoteHint,
          controller: noteController,
        ),
      ],
    );
  }
}
