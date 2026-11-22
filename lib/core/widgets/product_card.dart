import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';

import 'favorite_button.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddTap;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
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

    final cardBoxColor = Color.alphaBlend(
      cs.onSurface.withValues(alpha: 0.14),
      cs.surface,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 156,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBoxColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.85),
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
                      color: AppColors.hero.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.newBadge,
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.heroInk,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall?.copyWith(
                fontSize: 11.5,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$price ${l10n.currencySar}',
                  style: tt.titleMedium?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: onAddTap,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
