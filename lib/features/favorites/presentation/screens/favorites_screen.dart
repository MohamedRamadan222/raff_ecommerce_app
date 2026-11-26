import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/cart/presentation/utils/cart_helper.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:raff_app/features/favorites/presentation/widgets/favorites_empty_view.dart';

import '../../../catalog/presentation/widgets/categories/product_grid_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.status == FavoritesStatus.loading &&
                state.favorites.isEmpty) {
              return const LoadingView();
            }

            if (state.status == FavoritesStatus.failure &&
                state.favorites.isEmpty &&
                state.failure != null) {
              return ErrorView(
                message: state.failure!.message(context),
                onRetry: () => context.read<FavoritesCubit>().loadFavorites(),
              );
            }

            final items = state.favorites;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.navFavorites,
                        style: tt.headlineMedium!.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (items.isNotEmpty)
                        Text(
                          '${items.length} ${l10n.pieceUnit}',
                          style: tt.bodySmall!.copyWith(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const FavoritesEmptyView()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 18,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.64,
                              ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final product = items[index];
                            return BlocBuilder<CartCubit, CartState>(
                              builder: (context, cartState) {
                                return ProductGridCard(
                                  product: product,
                                  isFavorite: true,
                                  isInCart: cartState.isInCart(product.id),
                                  onFavoriteTap: () {
                                    context
                                        .read<FavoritesCubit>()
                                        .toggleFavorite(product);
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.removedFromFavorites,
                                            style: tt.bodyMedium!.copyWith(
                                              color: cs.onInverseSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: cs.inverseSurface,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                  },
                                  onAddTap: () => CartHelper.addWithFeedback(
                                    context,
                                    product,
                                  ),
                                  onTap: () => context.push(
                                    AppRoutes.productDetails,
                                    extra: product.id,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
