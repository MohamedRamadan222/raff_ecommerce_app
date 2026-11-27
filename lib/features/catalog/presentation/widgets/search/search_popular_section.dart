import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/widgets/app_image_cache.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

class SearchPopularSection extends StatelessWidget {
  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onProductTap;

  const SearchPopularSection({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final thumbBg = isDark
        ? cs.outline
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.72),
            cs.surface,
          );

    final topItems = products.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mostSearched,
          style: tt.titleMedium!.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topItems.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.65),
          ),
          itemBuilder: (context, index) {
            final product = topItems[index];
            return InkWell(
              onTap: () => onProductTap(product),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${index + 1}',
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: thumbBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: product.thumbnail.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.thumbnail,
                              cacheManager: AppImageCache.manager,
                              memCacheWidth: 150,
                              maxWidthDiskCache: 150,
                              fit: BoxFit.contain,
                              errorWidget: (_, _, _) => Icon(
                                Icons.image_outlined,
                                size: 22,
                                color: cs.outline,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 22,
                              color: cs.outline,
                            ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
