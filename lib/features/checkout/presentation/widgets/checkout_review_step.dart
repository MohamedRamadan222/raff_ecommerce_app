import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/app_image_cache.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_review_block.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_step_title.dart';
import 'package:raff_app/features/checkout/presentation/widgets/order_summary_section.dart';

class CheckoutReviewStep extends StatelessWidget {
  final CartState cartState;
  final CheckoutTotals totals;
  final String? addressId;
  final String deliveryMethod;
  final String paymentMethod;
  final ValueChanged<int> onJumpToStep;

  const CheckoutReviewStep({
    super.key,
    required this.cartState,
    required this.totals,
    required this.addressId,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.onJumpToStep,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final address = context.read<AddressesCubit>().state.addresses.firstWhere(
      (a) => a.id == addressId,
      orElse: () => context.read<AddressesCubit>().state.defaultAddress!,
    );

    final deliveryTitle = switch (deliveryMethod) {
      'express' => l10n.deliveryExpress,
      'pickup' => l10n.deliveryPickup,
      _ => l10n.deliveryStandard,
    };

    final paymentTitle = switch (paymentMethod) {
      'apple' => 'Apple Pay',
      'card' => l10n.payCard,
      'split' => l10n.paySplit,
      _ => l10n.payCod,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutStepTitle(l10n.reviewOrder),
        CheckoutReviewBlock(
          rows: [
            CheckoutReviewRow(
              icon: Icons.location_on_outlined,
              title: l10n.stepAddress,
              value: addressLabelText(l10n, address.label),
              detail: address.fullAddress,
              onEdit: () => onJumpToStep(0),
            ),
            CheckoutReviewRow(
              icon: Icons.local_shipping_outlined,
              title: l10n.stepDelivery,
              value: deliveryTitle,
              onEdit: () => onJumpToStep(1),
            ),
            CheckoutReviewRow(
              icon: Icons.credit_card_outlined,
              title: l10n.stepPayment,
              value: paymentTitle,
              onEdit: () => onJumpToStep(2),
            ),
          ],
        ),
        const Gap(12),
        for (final item in cartState.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.product.thumbnail,
                    cacheManager: AppImageCache.manager,
                    memCacheWidth: 140,
                    maxWidthDiskCache: 140,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      width: 44,
                      height: 44,
                      color: cs.surfaceContainerHighest,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium!.copyWith(fontSize: 14),
                      ),
                      Text(
                        '× ${item.quantity}',
                        style: tt.bodySmall!.copyWith(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Text(
                  '${item.totalPrice.toStringAsFixed(0)} ${l10n.currencySar}',
                  style: tt.bodyMedium!.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        const Gap(12),
        OrderSummarySection(totals: totals),
      ],
    );
  }
}
