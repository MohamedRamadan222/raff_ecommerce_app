import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/core/widgets/product_card.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/cart/presentation/utils/cart_helper.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';
import 'package:raff_app/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/product_details_state.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';

import '../widgets/details/product_details_bottom_bar.dart';
import '../widgets/details/product_details_gallery.dart';
import '../widgets/details/product_details_info_section.dart';
import '../widgets/details/product_details_reviews_section.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedColorIndex = 0;
  int _quantity = 1;

  static const _swatchHexCodes = ['#B5A495', '#EAE8E3', '#5A5651'];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        if (state is ProductDetailsLoading || state is ProductDetailsInitial) {
          return const Scaffold(body: LoadingView());
        }

        if (state is ProductDetailsFailure) {
          return Scaffold(
            body: ErrorView(
              message: state.failure.message(context),
              onRetry: () {
                if (context.canPop()) context.pop();
              },
            ),
          );
        }

        if (state is! ProductDetailsSuccess) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final product = state.product;
        final galleryImages = product.images.isNotEmpty
            ? product.images
            : [product.thumbnail];
        final maxStock = product.stock > 0 ? product.stock : 99;

        return Scaffold(
          bottomNavigationBar: ProductDetailsBottomBar(
            totalPrice: product.price * _quantity,
            onAddToCart: () {
              CartHelper.addWithFeedback(
                context,
                product,
                quantity: _quantity,
                colorHex: _swatchHexCodes[_selectedColorIndex],
              );
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favState) {
                    return ProductDetailsGallery(
                      images: galleryImages,
                      selectedIndex: state.selectedImageIndex,
                      isFavorite: favState.isFavorite(product.id),
                      onPageChanged: (index) => context
                          .read<ProductDetailsCubit>()
                          .selectImage(index),
                      onFavoriteTap: () => context
                          .read<FavoritesCubit>()
                          .toggleFavorite(product),
                      onShareTap: () =>
                          Clipboard.setData(ClipboardData(text: product.title)),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductDetailsInfoSection(
                        product: product,
                        selectedColorIndex: _selectedColorIndex,
                        quantity: _quantity,
                        onColorSelected: (i) =>
                            setState(() => _selectedColorIndex = i),
                        onIncrement: () {
                          if (_quantity < maxStock) {
                            setState(() => _quantity++);
                          }
                        },
                        onDecrement: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      const Gap(24),
                      ProductDetailsReviewsSection(
                        rating: product.rating,
                        reviewsCount: product.stock > 0 ? product.stock : 24,
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, homeState) {
                    if (homeState is! HomeSuccess) {
                      return const SizedBox.shrink();
                    }

                    final related = homeState.products
                        .where((p) => p.id != product.id)
                        .toList();
                    if (related.isEmpty) return const SizedBox.shrink();

                    return BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        return BlocBuilder<CartCubit, CartState>(
                          builder: (context, cartState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    l10n.youMayAlsoLike,
                                    style: tt.titleMedium!.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                SizedBox(
                                  height: 245,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: related.length,
                                    separatorBuilder: (_, _) => const Gap(14),
                                    itemBuilder: (context, index) {
                                      final item = related[index];
                                      return ProductCard(
                                        title: item.title,
                                        category:
                                            CatalogHelper.localizeCategory(
                                              context,
                                              slug: item.category,
                                            ),
                                        price: item.price.toStringAsFixed(0),
                                        imageUrl: item.thumbnail,
                                        isFavorite: favState.isFavorite(
                                          item.id,
                                        ),
                                        isInCart: cartState.isInCart(item.id),
                                        onFavoriteTap: () => context
                                            .read<FavoritesCubit>()
                                            .toggleFavorite(item),
                                        onAddTap: () =>
                                            CartHelper.addWithFeedback(
                                              context,
                                              item,
                                            ),
                                        onTap: () => context.push(
                                          AppRoutes.productDetails,
                                          extra: item.id,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
