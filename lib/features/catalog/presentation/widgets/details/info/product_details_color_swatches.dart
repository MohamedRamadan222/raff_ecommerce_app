import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_info_helpers.dart';

class ProductDetailsColorSwatches extends StatelessWidget {
  static const _swatchColors = [
    Color(0xFFB5A495),
    Color(0xFFEAE8E3),
    Color(0xFF5A5651),
  ];

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ProductDetailsColorSwatches({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.colorLabel, style: productDetailsInfoLabelStyle(theme)),
        const Gap(8),
        Row(
          children: List.generate(_swatchColors.length, (index) {
            final selected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? cs.onSurface : Colors.transparent,
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
    );
  }
}
