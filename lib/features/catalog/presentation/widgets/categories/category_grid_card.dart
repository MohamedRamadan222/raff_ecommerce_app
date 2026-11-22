import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';

class CategoryGridCard extends StatelessWidget {
  final CategoryEntity category;
  final int index;
  final VoidCallback onTap;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? cs.outline
        : (index.isEven
              ? cs.secondary
              : Color.alphaBlend(
                  cs.outlineVariant.withValues(alpha: 0.65),
                  cs.surface,
                ));

    final iconColor = index.isEven
        ? cs.primary.withValues(alpha: 0.78)
        : cs.onSurface.withValues(alpha: 0.52);

    final localizedName = CatalogHelper.localizeCategory(
      context,
      slug: category.slug,
      fallbackName: category.name,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium!.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    l10n.seeAll,
                    style: tt.bodySmall!.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CatalogHelper.categoryIcon(category.slug),
                    size: 50,
                    color: iconColor,
                  ),
                  const Gap(4),
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(100),
                    ),
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
