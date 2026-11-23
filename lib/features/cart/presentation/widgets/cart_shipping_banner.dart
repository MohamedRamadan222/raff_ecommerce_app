import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';

class CartShippingBanner extends StatelessWidget {
  final bool hasFreeShipping;
  final double remainingAmount;
  final double progress;

  const CartShippingBanner({
    super.key,
    required this.hasFreeShipping,
    required this.remainingAmount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final bannerBg = isDark
        ? Color.alphaBlend(cs.primary.withValues(alpha: 0.14), cs.surface)
        : Color.alphaBlend(cs.primary.withValues(alpha: 0.10), cs.surface);

    final message = hasFreeShipping
        ? l10n.freeShippingUnlocked
        : l10n.addMoreForFreeShipping(remainingAmount.toStringAsFixed(0));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFreeShipping
                    ? Icons.check_rounded
                    : Icons.local_shipping_outlined,
                size: 17,
                color: cs.onSurface.withValues(alpha: 0.85),
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  message,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3.5,
              backgroundColor: cs.onSurface.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(
                cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
