import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/widgets/app_button.dart';

enum ProductSortOption { popular, priceLowToHigh, priceHighToLow, highestRated }

extension ProductSortOptionX on ProductSortOption {
  String label(AppLocalizations l10n) => switch (this) {
    ProductSortOption.popular => l10n.sortPopular,
    ProductSortOption.priceLowToHigh => l10n.sortPriceLow,
    ProductSortOption.priceHighToLow => l10n.sortPriceHigh,
    ProductSortOption.highestRated => l10n.sortRating,
  };
}

Future<ProductSortOption?> showProductsSortSheet(
  BuildContext context, {
  required ProductSortOption current,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final tt = theme.textTheme;
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<ProductSortOption>(
    context: context,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const Gap(16),
            Text(
              l10n.sortBy,
              style: tt.headlineMedium!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            ...ProductSortOption.values.map((option) {
              final selected = option == current;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option.label(l10n),
                  style: tt.bodyMedium!.copyWith(
                    color: cs.onSurface,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: selected
                    ? Icon(Icons.check_rounded, color: cs.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, option),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

Future<({bool discountsOnly, double maxPrice})?> showProductsFilterSheet(
  BuildContext context, {
  required bool initialDiscountsOnly,
  required double initialMaxPrice,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final tt = theme.textTheme;
  final l10n = AppLocalizations.of(context)!;

  var discountsOnly = initialDiscountsOnly;
  var maxPrice = initialMaxPrice;

  return showModalBottomSheet<({bool discountsOnly, double maxPrice})>(
    context: context,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filter,
                    style: tt.headlineMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setModalState(() {
                      discountsOnly = false;
                      maxPrice = 5000;
                    }),
                    child: Text(l10n.reset),
                  ),
                ],
              ),
              const Gap(8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.discountsOnly,
                  style: tt.bodyMedium!.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: discountsOnly,
                activeThumbColor: cs.primary,
                onChanged: (v) => setModalState(() => discountsOnly = v),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.priceRange,
                    style: tt.bodyMedium!.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '0 - ${maxPrice.round()} ${l10n.currencySar}',
                    style: tt.bodySmall!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: maxPrice,
                min: 50,
                max: 5000,
                divisions: 99,
                activeColor: cs.primary,
                onChanged: (v) => setModalState(() => maxPrice = v),
              ),
              const Gap(14),
              AppButton(
                label: l10n.apply,
                onPressed: () => Navigator.pop(ctx, (
                  discountsOnly: discountsOnly,
                  maxPrice: maxPrice,
                )),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
