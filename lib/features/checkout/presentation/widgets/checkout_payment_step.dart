import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/dashed_add_button.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_bank_card.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_option_card.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_step_title.dart';

/// خطوة ٣: طريقة الدفع — اختيار UI للتعلم، ومفيش فلوس حقيقية بتتحرك
class CheckoutPaymentStep extends StatelessWidget {
  final String method;
  final double total;
  final ValueChanged<String> onSelect;

  const CheckoutPaymentStep({
    super.key,
    required this.method,
    required this.total,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutStepTitle(l10n.howPay),
        CheckoutOptionCard(
          icon: Icons.apple,
          title: 'Apple Pay',
          subtitle: l10n.payAppleSub,
          selected: method == 'apple',
          onTap: () => onSelect('apple'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.credit_card,
          title: l10n.payCard,
          subtitle: '•••• 4421',
          selected: method == 'card',
          onTap: () => onSelect('card'),
        ),
        if (method == 'card') ...[
          const Gap(12),
          const CheckoutBankCard(),
          const Gap(12),
          DashedAddButton(label: l10n.addCard, onTap: () {}),
        ],
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.receipt_long_outlined,
          title: l10n.paySplit,
          subtitle:
              '4 × ${(total / 4).toStringAsFixed(0)} ${l10n.currencySar} — ${l10n.paySplitSub}',
          selected: method == 'split',
          onTap: () => onSelect('split'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.payments_outlined,
          title: l10n.payCod,
          subtitle: l10n.payCodSub,
          aside:
              '+${CheckoutTotals.codFeeAmount.toStringAsFixed(0)} ${l10n.currencySar}',
          selected: method == 'cod',
          onTap: () => onSelect('cod'),
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
            const Gap(6),
            Text(
              l10n.securePay,
              style: tt.bodySmall!.copyWith(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
