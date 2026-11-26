import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/features/checkout/presentation/utils/checkout_totals.dart';

class OrderSummarySection extends StatelessWidget {
  final CheckoutTotals totals;

  const OrderSummarySection({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkLine
              : AppColors.line,
        ),
      ),
      child: Column(
        children: [
          _Row(
            label: l10n.subtotalLabel,
            value: '${totals.subtotal.toStringAsFixed(0)} ${l10n.currencySar}',
          ),
          if (totals.discount > 0) ...[
            const Gap(12),
            _Row(
              label: l10n.discountRowLabel,
              value:
                  '-${totals.discount.toStringAsFixed(0)} ${l10n.currencySar}',
              valueColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSuccess
                  : AppColors.success,
            ),
          ],
          const Gap(12),
          _Row(
            label: l10n.shippingLabel,
            value: totals.shippingFee == 0
                ? l10n.freeLabel
                : '${totals.shippingFee.toStringAsFixed(0)} ${l10n.currencySar}',
          ),
          if (totals.codFee > 0) ...[
            const Gap(12),
            _Row(
              label: l10n.codFeeLabel,
              value: '${totals.codFee.toStringAsFixed(0)} ${l10n.currencySar}',
            ),
          ],
          const Gap(12),
          _Row(
            label: l10n.totalLabel,
            value: '${totals.total.toStringAsFixed(0)} ${l10n.currencySar}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _Row({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final style = isBold
        ? tt.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w700)
        : tt.bodyMedium!.copyWith(fontSize: 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? style : style.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: style.copyWith(
            fontWeight: valueColor != null ? FontWeight.w500 : style.fontWeight,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
