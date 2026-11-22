import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';

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

  static const _swatchColors = [
    Color(0xFFB5A495),
    Color(0xFFEAE8E3),
    Color(0xFF5A5651),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final discount = product.discountPercentage.round();
    final hasDiscount = discount >= 5;

    final cardSurface = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.05), cs.surface)
        : Color.alphaBlend(
      cs.outlineVariant.withValues(alpha: 0.32),
      cs.surface,
    );

    final categoryLabel = CatalogHelper.localizeCategory(
      context,
      slug: product.category,
    );

    final isDescriptionEnglish = RegExp(
      r'^[a-zA-Z0-9\s\p{P}]+$',
      unicode: true,
    ).hasMatch(product.description.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. الماركة + العنوان + شارة التقييم
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
                    style: tt.labelLarge!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    '(${product.stock})',
                    style: tt.bodySmall!.copyWith(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(12),

        // 2. السعر + السعر القديم + بادج الخصم
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

        // 3. اللون + الكمية
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.colorLabel,
                  style: tt.bodySmall!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const Gap(8),
                Row(
                  children: List.generate(_swatchColors.length, (index) {
                    final selected = index == selectedColorIndex;
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: GestureDetector(
                        onTap: () => onColorSelected(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? cs.onSurface
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _swatchColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.outlineVariant),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quantityLabel,
                  style: tt.bodySmall!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const Gap(8),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: cardSurface,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepperBtn(
                        icon: Icons.remove_rounded,
                        onTap: quantity > 1 ? onDecrement : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: tt.titleMedium!.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StepperBtn(icon: Icons.add_rounded, onTap: onIncrement),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const Gap(18),

        // 4. كارت الشحن والإرجاع
        Container(
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              _InfoTileRow(
                icon: Icons.local_shipping_outlined,
                title: l10n.deliveryDaysTitle,
                trailing: l10n.freeOver200,
              ),
              Divider(height: 1, color: cs.outlineVariant),
              _InfoTileRow(
                icon: Icons.refresh_rounded,
                title: l10n.freeReturnTitle,
                trailing: l10n.within14Days,
              ),
            ],
          ),
        ),
        const Gap(20),

        // 5. عن المنتج + جدول المواصفات
        Text(
          l10n.aboutProduct,
          style: tt.titleMedium!.copyWith(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Text(
          product.description,
          textDirection: isDescriptionEnglish ? TextDirection.ltr : null,
          textAlign: isDescriptionEnglish ? TextAlign.end : TextAlign.start,
          style: tt.bodyMedium!.copyWith(
            fontSize: 13.5,
            height: 1.55,
            color: cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
        const Gap(14),
        Container(
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              _SpecRow(
                label: l10n.brand,
                value: product.brand ?? categoryLabel,
              ),
              Divider(height: 1, color: cs.outlineVariant),
              _SpecRow(label: l10n.categoryLabel, value: categoryLabel),
              Divider(height: 1, color: cs.outlineVariant),
              _SpecRow(
                label: l10n.availability,
                value: product.stock > 0
                    ? '${l10n.inStock} (${product.stock})'
                    : l10n.outOfStock,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 32,
        height: 36,
        child: Icon(
          icon,
          size: 15,
          color: onTap != null
              ? cs.onSurface
              : cs.onSurface.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class _InfoTileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _InfoTileRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: cs.primary),
          const Gap(10),
          Expanded(
            child: Text(
              title,
              style: tt.bodyMedium!.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            trailing,
            style: tt.bodySmall!.copyWith(
              fontSize: 11.5,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tt.bodySmall!.copyWith(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const Gap(16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium!.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}