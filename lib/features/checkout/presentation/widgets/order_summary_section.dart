import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/summary_row.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';

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
          SummaryRow(
            label: l10n.subtotalLabel,
            value: '${totals.subtotal.toStringAsFixed(0)} ${l10n.currencySar}',
          ),
          if (totals.discount > 0) ...[
            const Gap(12),
            SummaryRow(
              label: l10n.discountRowLabel,
              value:
                  '-${totals.discount.toStringAsFixed(0)} ${l10n.currencySar}',
              valueColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSuccess
                  : AppColors.success,
            ),
          ],
          const Gap(12),
          SummaryRow(
            label: l10n.shippingLabel,
            value: totals.shippingFee == 0
                ? l10n.freeLabel
                : '${totals.shippingFee.toStringAsFixed(0)} ${l10n.currencySar}',
          ),
          if (totals.codFee > 0) ...[
            const Gap(12),
            SummaryRow(
              label: l10n.codFeeLabel,
              value: '${totals.codFee.toStringAsFixed(0)} ${l10n.currencySar}',
            ),
          ],
          const Gap(12),
          SummaryRow(
            label: l10n.totalLabel,
            value: '${totals.total.toStringAsFixed(0)} ${l10n.currencySar}',
            emphasized: true,
          ),
        ],
      ),
    );
  }
}
