import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';

class FreeShippingBanner extends StatelessWidget {
  final VoidCallback onTap;

  const FreeShippingBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: cs.primary,
                size: 22,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.freeShippingTitle,
                    style: tt.titleMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cs.onSecondary,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    l10n.freeShippingSubtitle,
                    style: tt.bodySmall!.copyWith(
                      color: cs.onSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: cs.onSecondary.withValues(alpha: 0.65),
            ),
          ],
        ),
      ),
    );
  }
}
