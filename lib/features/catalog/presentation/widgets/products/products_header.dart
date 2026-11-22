import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/app_back_button.dart';

class ProductsHeader extends StatelessWidget {
  final String title;
  final int productsCount;
  final int cartCount;

  const ProductsHeader({
    super.key,
    required this.title,
    required this.productsCount,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 6),
      child: Row(
        children: [
          const AppBackButton(),
          const Gap(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.headlineMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$productsCount ${l10n.productUnit}',
                  style: tt.bodySmall!.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            icon: Icon(Icons.search_rounded, size: 24, color: cs.onSurface),
          ),
          InkWell(
            onTap: () => context.go(AppRoutes.cart),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 24,
                    color: cs.onSurface,
                  ),
                  if (cartCount > 0)
                    PositionedDirectional(
                      top: -4,
                      end: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cs.inverseSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartCount',
                          style: tt.labelSmall!.copyWith(
                            fontSize: 9.5,
                            color: cs.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
