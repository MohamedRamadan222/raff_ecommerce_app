import 'package:flutter/material.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_info_helpers.dart';
import 'package:raff_app/features/catalog/presentation/widgets/details/info/product_details_info_tile_row.dart';

class ProductDetailsInfoTilesCard extends StatelessWidget {
  const ProductDetailsInfoTilesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ProductDetailsInfoCard(
      child: Column(
        children: [
          ProductDetailsInfoTileRow(
            icon: Icons.local_shipping_outlined,
            title: l10n.deliveryDaysTitle,
            trailing: l10n.freeOver200,
          ),
          Divider(height: 1, color: cs.outlineVariant),
          ProductDetailsInfoTileRow(
            icon: Icons.refresh_rounded,
            title: l10n.freeReturnTitle,
            trailing: l10n.within14Days,
          ),
        ],
      ),
    );
  }
}
