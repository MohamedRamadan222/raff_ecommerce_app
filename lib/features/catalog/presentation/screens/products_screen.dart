import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_state.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';
import 'package:raff_app/features/catalog/presentation/widgets/product_grid_card.dart';
import 'package:raff_app/features/catalog/presentation/widgets/products_filter_bar.dart';
import 'package:raff_app/features/catalog/presentation/widgets/products_header.dart';
import 'package:raff_app/features/catalog/presentation/widgets/products_sheets.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategorySlug;
  final String? initialCategoryName;

  const ProductsScreen({
    super.key,
    this.initialCategorySlug,
    this.initialCategoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _scrollController = ScrollController();

  late String? _selectedCategorySlug;
  late String? _selectedCategoryName;
  ProductSortOption _sortOption = ProductSortOption.popular;
  bool _discountsOnly = false;
  double _maxPrice = 5000;

  @override
  void initState() {
    super.initState();
    _selectedCategorySlug = widget.initialCategorySlug;
    _selectedCategoryName = widget.initialCategoryName;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      context.read<ProductsCubit>().loadMoreProducts();
    }
  }

  List<ProductEntity> _applySortAndFilter(List<ProductEntity> raw) {
    final filtered = raw.where((p) {
      if (_discountsOnly && p.discountPercentage < 5) return false;
      if (p.price > _maxPrice) return false;
      return true;
    }).toList();

    switch (_sortOption) {
      case ProductSortOption.popular:
        break;
      case ProductSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case ProductSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case ProductSortOption.highestRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filtered;
  }

  void _onCategoryChanged(CategoryEntity? category) {
    setState(() {
      _selectedCategorySlug = category?.slug;
      _selectedCategoryName = category == null
          ? null
          : CatalogHelper.localizeCategory(
              context,
              slug: category.slug,
              fallbackName: category.name,
            );
    });
    context.read<ProductsCubit>().loadProducts(
      categorySlug: _selectedCategorySlug,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final headerTitle = (_selectedCategoryName?.isNotEmpty ?? false)
        ? _selectedCategoryName!
        : l10n.allProducts;

    final hasActiveFilters = _discountsOnly || _maxPrice < 5000;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            final displayedProducts = state is ProductsSuccess
                ? _applySortAndFilter(state.products)
                : <ProductEntity>[];

            return Column(
              children: [
                ProductsHeader(
                  title: headerTitle,
                  productsCount: displayedProducts.length,
                ),
                const Gap(4),
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, homeState) {
                    final categories = homeState is HomeSuccess
                        ? homeState.categories
                        : <CategoryEntity>[];

                    return ProductsFilterBar(
                      sortLabel: _sortOption.label(l10n),
                      hasActiveFilters: hasActiveFilters,
                      selectedCategorySlug: _selectedCategorySlug,
                      categories: categories,
                      onSortTap: () async {
                        final picked = await showProductsSortSheet(
                          context,
                          current: _sortOption,
                        );
                        if (picked != null && mounted) {
                          setState(() => _sortOption = picked);
                        }
                      },
                      onFilterTap: () async {
                        final res = await showProductsFilterSheet(
                          context,
                          initialDiscountsOnly: _discountsOnly,
                          initialMaxPrice: _maxPrice,
                        );
                        if (res != null && mounted) {
                          setState(() {
                            _discountsOnly = res.discountsOnly;
                            _maxPrice = res.maxPrice;
                          });
                        }
                      },
                      onCategorySelected: _onCategoryChanged,
                    );
                  },
                ),
                const Gap(14),
                Expanded(
                  child: _buildBody(context, state, displayedProducts, cs),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductsState state,
    List<ProductEntity> products,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (state is ProductsLoading || state is ProductsInitial) {
      return const LoadingView();
    }

    if (state is ProductsFailure) {
      return ErrorView(
        message: state.failure.message(context),
        onRetry: () => context.read<ProductsCubit>().loadProducts(
          categorySlug: _selectedCategorySlug,
        ),
      );
    }

    if (state is! ProductsSuccess) return const SizedBox.shrink();

    if (products.isEmpty) {
      return EmptyView(title: l10n.noResultsFound);
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () => context.read<ProductsCubit>().loadProducts(
        categorySlug: _selectedCategorySlug,
      ),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 14,
                childAspectRatio: 0.64,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return ProductGridCard(
                  product: product,
                  onFavoriteTap: () {},
                  onAddTap: () {},
                  onTap: () =>
                      context.push(AppRoutes.productDetails, extra: product.id),
                );
              }, childCount: products.length),
            ),
          ),
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: CircularProgressIndicator(color: cs.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
