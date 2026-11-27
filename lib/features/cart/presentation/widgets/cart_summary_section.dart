import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/widgets/summary_row.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';

class CartSummarySection extends StatelessWidget {
  final CartState state;
  final TextEditingController promoController;
  final VoidCallback onApplyPromo;
  final VoidCallback onRemovePromo;

  const CartSummarySection({
    super.key,
    required this.state,
    required this.promoController,
    required this.onApplyPromo,
    required this.onRemovePromo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final cardSurface = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.05), cs.surface)
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.32),
            cs.surface,
          );

    final hasPromo = state.appliedPromoCode != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: state.isPromoInvalid ? cs.error : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sell_outlined,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              const Gap(10),
              Expanded(
                child: TextField(
                  controller: promoController,
                  enabled: !hasPromo,
                  textCapitalization: TextCapitalization.characters,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hasPromo
                        ? state.appliedPromoCode
                        : l10n.promoCodeHint,
                    hintStyle: tt.bodyMedium!.copyWith(
                      fontSize: 13.5,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const Gap(8),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: hasPromo ? onRemovePromo : onApplyPromo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.inverseSurface,
                    foregroundColor: cs.onInverseSurface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    hasPromo ? l10n.clear : l10n.apply,
                    style: tt.labelLarge!.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: cs.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Text(
          state.isPromoInvalid
              ? l10n.invalidPromoCode
              : (hasPromo ? l10n.promoApplied : l10n.promoCodeHelper),
          style: tt.bodySmall!.copyWith(
            fontSize: 11.5,
            color: state.isPromoInvalid
                ? cs.error
                : (hasPromo
                      ? const Color(0xFF55A665)
                      : cs.onSurface.withValues(alpha: 0.5)),
          ),
        ),
        const Gap(18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              SummaryRow(
                label: l10n.subtotalLabel,
                value:
                    '${state.subtotal.toStringAsFixed(0)} ${l10n.currencySar}',
                emphasized: true,
              ),
              if (state.discountAmount > 0) ...[
                const Gap(10),
                SummaryRow(
                  label: l10n.discountRowLabel,
                  value:
                      '-${state.discountAmount.toStringAsFixed(0)} ${l10n.currencySar}',
                  emphasized: true,
                  valueColor: const Color(0xFF55A665),
                ),
              ],
              const Gap(10),
              SummaryRow(
                label: l10n.shippingLabel,
                value: state.hasFreeShipping
                    ? l10n.freeLabel
                    : '${state.shippingFee.toStringAsFixed(0)} ${l10n.currencySar}',
                emphasized: true,
                valueColor: state.hasFreeShipping
                    ? const Color(0xFF55A665)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: cs.outlineVariant),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalLabel,
                        style: tt.titleMedium!.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        l10n.vatIncluded,
                        style: tt.bodySmall!.copyWith(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${state.total.toStringAsFixed(0)} ${l10n.currencySar}',
                    style: tt.headlineMedium!.copyWith(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
