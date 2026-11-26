import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class FreeShippingBanner extends StatelessWidget {
  final VoidCallback onTap;

  const FreeShippingBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;
    final inkSecondary = isDark
        ? AppColors.darkInkSecondary
        : AppColors.inkSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkAccentSoft : AppColors.accentSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: accent,
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
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    l10n.freeShippingSubtitle,
                    style: tt.bodySmall!.copyWith(
                      fontSize: 13,
                      color: inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 18,
              color: cs.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
