import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';

class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final iconBoxColor = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), cs.surface)
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.55),
            cs.surface,
          );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: iconBoxColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const Gap(20),
            Text(
              l10n.emptyCartTitle,
              textAlign: TextAlign.center,
              style: tt.headlineMedium!.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              l10n.emptyCartSubtitle,
              textAlign: TextAlign.center,
              style: tt.bodyMedium!.copyWith(
                fontSize: 13.5,
                height: 1.55,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const Gap(24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.inverseSurface,
                  foregroundColor: cs.onInverseSurface,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.startShopping,
                  style: tt.labelLarge!.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: cs.onInverseSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
