import 'package:flutter/material.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_info_helpers.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_spec_row.dart';

class ProductDetailsSpecsCard extends StatelessWidget {
  final String brand;
  final String category;
  final String availability;

  const ProductDetailsSpecsCard({
    super.key,
    required this.brand,
    required this.category,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ProductDetailsInfoCard(
      child: Column(
        children: [
          ProductDetailsSpecRow(label: l10n.brand, value: brand),
          Divider(height: 1, color: cs.outlineVariant),
          ProductDetailsSpecRow(label: l10n.categoryLabel, value: category),
          Divider(height: 1, color: cs.outlineVariant),
          ProductDetailsSpecRow(label: l10n.availability, value: availability),
        ],
      ),
    );
  }
}
