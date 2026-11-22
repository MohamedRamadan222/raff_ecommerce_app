import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/widgets/app_ship.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';

class ProductsFilterBar extends StatelessWidget {
  final String sortLabel;
  final bool hasActiveFilters;
  final String? selectedCategorySlug;
  final List<CategoryEntity> categories;
  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;
  final ValueChanged<CategoryEntity?> onCategorySelected;

  const ProductsFilterBar({
    super.key,
    required this.sortLabel,
    required this.hasActiveFilters,
    required this.selectedCategorySlug,
    required this.categories,
    required this.onSortTap,
    required this.onFilterTap,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          AppChip(label: sortLabel, icon: Icons.tune_rounded, onTap: onSortTap),
          const Gap(8),
          AppChip(
            label: l10n.filter,
            selected: hasActiveFilters,
            onTap: onFilterTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(width: 1, color: cs.outlineVariant),
          ),
          AppChip(
            label: l10n.all,
            selected:
                selectedCategorySlug == null || selectedCategorySlug!.isEmpty,
            onTap: () => onCategorySelected(null),
          ),
          ...categories.map((category) {
            final isSelected = selectedCategorySlug == category.slug;
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: AppChip(
                label: CatalogHelper.localizeCategory(
                  context,
                  slug: category.slug,
                  fallbackName: category.name,
                ),
                selected: isSelected,
                onTap: () => onCategorySelected(category),
              ),
            );
          }),
        ],
      ),
    );
  }
}
