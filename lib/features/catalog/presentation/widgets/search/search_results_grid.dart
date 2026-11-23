import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/cart/presentation/utils/cart_helper.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';

import '../categories/product_grid_card.dart';

class SearchResultsGrid extends StatelessWidget {
  final ScrollController controller;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final ValueChanged<ProductEntity> onProductTap;

  const SearchResultsGrid({
    super.key,
    required this.controller,
    required this.products,
    required this.isLoadingMore,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        return CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.64,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = products[index];
                    return BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        return ProductGridCard(
                          product: product,
                          isFavorite: favState.isFavorite(product.id),
                          isInCart: cartState.isInCart(product.id),
                          onFavoriteTap: () => context
                              .read<FavoritesCubit>()
                              .toggleFavorite(product),
                          onAddTap: () =>
                              CartHelper.addWithFeedback(context, product),
                          onTap: () => onProductTap(product),
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
            if (isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}