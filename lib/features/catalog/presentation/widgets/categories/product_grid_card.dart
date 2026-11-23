import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/favorite_button.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';

class ProductGridCard extends StatelessWidget {
  final ProductEntity product;
  final bool isFavorite;
  final bool isInCart;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddTap;
  final VoidCallback onTap;

  const ProductGridCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.isInCart = false,
    required this.onFavoriteTap,
    required this.onAddTap,
    required this.onTap,
  });

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

    final imageBg = isDark
        ? cs.outline
        : Color.alphaBlend(
      cs.outlineVariant.withValues(alpha: 0.72),
      cs.surface,
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: imageBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: product.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.outline,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: cs.outline,
                    ),
                  )
                      : Icon(Icons.image_outlined, size: 36, color: cs.outline),
                ),
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.88),
                      shape: BoxShape.circle,
                    ),
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavoriteTap,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: hasDiscount
                          ? cs.inverseSurface
                          : (isDark
                          ? AppColors.hero.withValues(alpha: 0.88)
                          : cs.surface.withValues(alpha: 0.92)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasDiscount
                          ? (isAr
                          ? '${l10n.discountLabel} $discount%'
                          : '$discount% ${l10n.discountLabel}')
                          : l10n.newBadge,
                      style: tt.labelSmall!.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: hasDiscount
                            ? cs.onInverseSurface
                            : (isDark ? AppColors.heroInk : cs.onSurface),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Text(
            product.brand ??
                CatalogHelper.localizeCategory(context, slug: product.category),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall!.copyWith(fontSize: 11.5),
          ),
          const Gap(2),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} ${l10n.currencySar}',
                      style: tt.titleMedium!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasDiscount)
                      Text(
                        product.priceBeforeDiscount.toStringAsFixed(0),
                        style: tt.bodySmall!.copyWith(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isInCart ? cs.inverseSurface : cs.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isInCart ? cs.inverseSurface : cs.outlineVariant,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: isInCart ? cs.onInverseSurface : cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}