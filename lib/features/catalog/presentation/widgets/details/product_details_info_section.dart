import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_color_swatches.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_description_block.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_info_helpers.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_info_tiles_card.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_quantity_stepper.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_specs_card.dart';

class ProductDetailsInfoSection extends StatelessWidget {
  final ProductEntity product;
  final int selectedColorIndex;
  final int quantity;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductDetailsInfoSection({
    super.key,
    required this.product,
    required this.selectedColorIndex,
    required this.quantity,
    required this.onColorSelected,
    required this.onIncrement,
    required this.onDecrement,
  });

  static final RegExp _englishDescriptionPattern = RegExp(
    r'^[a-zA-Z0-9\s\p{P}]+$',
    unicode: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final discount = product.discountPercentage.round();
    final hasDiscount = discount >= 5;

    final cardSurface = productDetailsCardSurface(context);

    final categoryLabel = CatalogHelper.localizeCategory(
      context,
      slug: product.category,
    );

    final isDescriptionEnglish = _englishDescriptionPattern.hasMatch(
      product.description.trim(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand ?? categoryLabel,
                    style: tt.bodySmall!.copyWith(
                      fontSize: 12.5,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    product.title,
                    style: tt.headlineMedium!.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: AppColors.darkStar,
                  ),
                  const Gap(4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: tt.bodySmall!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    '(${product.stock})',
                    style: tt.bodySmall!.copyWith(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(12),

        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${product.price.toStringAsFixed(0)} ${l10n.currencySar}',
              style: tt.headlineMedium!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasDiscount)
              Text(
                '${product.priceBeforeDiscount.toStringAsFixed(0)} ${l10n.currencySar}',
                style: tt.bodyMedium!.copyWith(
                  fontSize: 13.5,
                  color: cs.onSurface.withValues(alpha: 0.45),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            if (hasDiscount)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.inverseSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAr
                      ? '${l10n.discountLabel} $discount%'
                      : '$discount% ${l10n.discountLabel}',
                  style: tt.labelSmall!.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: cs.onInverseSurface,
                  ),
                ),
              ),
          ],
        ),
        const Gap(6),
        Text(
          l10n.vatIncluded,
          style: tt.bodySmall!.copyWith(
            fontSize: 11.5,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Gap(16),
        Divider(height: 1, color: cs.outlineVariant),
        const Gap(16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductDetailsColorSwatches(
              selectedIndex: selectedColorIndex,
              onSelected: onColorSelected,
            ),
            ProductDetailsQuantityStepper(
              quantity: quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
        const Gap(18),

        const ProductDetailsInfoTilesCard(),
        const Gap(20),

        ProductDetailsDescriptionBlock(
          description: product.description,
          isEnglish: isDescriptionEnglish,
        ),
        const Gap(14),
        ProductDetailsSpecsCard(
          brand: product.brand ?? categoryLabel,
          category: categoryLabel,
          availability: product.stock > 0
              ? '${l10n.inStock} (${product.stock})'
              : l10n.outOfStock,
        ),
      ],
    );
  }
}
