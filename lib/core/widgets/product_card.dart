import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_badge.dart';

import 'favorite_button.dart';
import 'add_button.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Colors.transparent;
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final priceColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 165,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? AppColors.darkLineStrong
                                    : AppColors.lineStrong,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: isDark
                                  ? AppColors.darkLineStrong
                                  : AppColors.lineStrong,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: isDark
                              ? AppColors.darkLineStrong
                              : AppColors.lineStrong,
                        ),
                ),

                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.darkSurface : AppColors.surface)
                              .withValues(alpha: 0.80),
                      shape: BoxShape.circle,
                    ),
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavoriteTap,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 13,
                  start: 8,
                  child: AppBadge(text: 'جديد'),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: priceColor),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: textColor),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$price  ر.س',
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: priceColor),
                      ),
                      AddButton(onTap: onAddTap),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
