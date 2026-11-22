import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';

class HomeCategoryItem extends StatelessWidget {
  final CategoryEntity category;
  final String localizedName;
  final VoidCallback onTap;

  const HomeCategoryItem({
    super.key,
    required this.category,
    required this.localizedName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  cs.onSurface.withValues(alpha: 0.10),
                  cs.surface,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CatalogHelper.categoryIcon(category.slug),
                size: 25,
                color: cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
            const Gap(8),
            Text(
              localizedName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: tt.bodySmall!.copyWith(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.78),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
