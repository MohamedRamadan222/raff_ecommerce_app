import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_search_field.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/core/widgets/product_card.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';
import 'package:raff_app/features/catalog/presentation/widgets/home/free_shipping_banner.dart';
import 'package:raff_app/features/catalog/presentation/widgets/home/home_banner_carousel.dart';
import 'package:raff_app/features/catalog/presentation/widgets/home/home_category_item.dart';
import 'package:raff_app/features/catalog/presentation/widgets/home/home_header.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/cart/presentation/utils/cart_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const LoadingView();
            }

            if (state is HomeFailure) {
              return ErrorView(
                message: state.failure.message(context),
                onRetry: () => context.read<HomeCubit>().loadHomeData(),
              );
            }

            if (state is! HomeSuccess) return const SizedBox.shrink();

            return RefreshIndicator(
              color: cs.primary,
              onRefresh: () =>
                  context.read<HomeCubit>().loadHomeData(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: HomeHeader(
                        onNotificationsTap: () =>
                            context.push(AppRoutes.notifications),
                      ),
                    ),
                    const Gap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppSearchField(
                        hintText: l10n.searchHint,
                        readOnly: true,
                        showFilter: true,
                        onTap: () => context.push(AppRoutes.search),
                        onFilterTap: () => context.push(AppRoutes.search),
                      ),
                    ),
                    const Gap(20),
                    HomeBannerCarousel(
                      onShopNowTap: () => context.push(AppRoutes.products),
                    ),
                    const Gap(24),
                    _HomeSectionTitle(
                      title: l10n.navCategories,
                      actionText: l10n.seeAll,
                      onActionTap: () => context.go(AppRoutes.categories),
                    ),
                    const Gap(12),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length,
                        separatorBuilder: (_, _) => const Gap(12),
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final localizedName = CatalogHelper.localizeCategory(
                            context,
                            slug: category.slug,
                            fallbackName: category.name,
                          );
                          return HomeCategoryItem(
                            category: category,
                            localizedName: localizedName,
                            onTap: () => context.push(
                              AppRoutes.products,
                              extra: {
                                'slug': category.slug,
                                'name': localizedName,
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(32),
                    _HomeSectionTitle(
                      title: l10n.newArrivals,
                      actionText: l10n.seeAll,
                      onActionTap: () => context.push(AppRoutes.products),
                    ),
                    const Gap(12),
                    _ProductsHorizontalList(products: state.products),
                    const Gap(32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FreeShippingBanner(
                        onTap: () => context.push(AppRoutes.products),
                      ),
                    ),
                    const Gap(32),
                    _HomeSectionTitle(
                      title: l10n.bestSellers,
                      actionText: l10n.seeAll,
                      onActionTap: () => context.push(AppRoutes.products),
                    ),
                    const Gap(12),
                    _ProductsHorizontalList(
                      products: state.products.reversed.toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeSectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  const _HomeSectionTitle({
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: tt.titleMedium!.copyWith(
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: tt.bodySmall!.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkAccent : AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsHorizontalList extends StatelessWidget {
  final List<ProductEntity> products;

  const _ProductsHorizontalList({required this.products});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            final favoriteIds = favState.favoriteProductIds;
            final cartIds = cartState.productIds;

            return SizedBox(
              height: 245,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) => const Gap(14),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    title: product.title,
                    category: CatalogHelper.localizeCategory(
                      context,
                      slug: product.category,
                    ),
                    price: product.price.toStringAsFixed(0),
                    imageUrl: product.thumbnail,
                    isFavorite: favoriteIds.contains(product.id),
                    isInCart: cartIds.contains(product.id),
                    onFavoriteTap: () =>
                        context.read<FavoritesCubit>().toggleFavorite(product),
                    onAddTap: () =>
                        CartHelper.addWithFeedback(context, product),
                    onTap: () => context.push(
                      AppRoutes.productDetails,
                      extra: product.id,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
