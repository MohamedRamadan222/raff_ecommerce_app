import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class CartHelper {
  static void addWithFeedback(
      BuildContext context,
      ProductEntity product, {
        int quantity = 1,
        String? colorHex,
      }) {
    context.read<CartCubit>().addToCart(
      product,
      quantity: quantity,
      colorHex: colorHex,
    );

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.addedToCart,
            style: tt.bodyMedium!.copyWith(
              color: cs.onInverseSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: cs.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: l10n.viewCart,
            textColor: cs.onInverseSurface,
            onPressed: () => context.go(AppRoutes.cart),
          ),
        ),
      );
  }
}