import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/theme/app_colors.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSunken : AppColors.sunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CatalogHelper.categoryIcon(category.slug),
                size: 26,
                color: cs.onSurface,
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
                color: isDark
                    ? AppColors.darkInkSecondary
                    : AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
