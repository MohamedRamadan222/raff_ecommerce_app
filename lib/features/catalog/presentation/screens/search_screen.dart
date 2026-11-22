import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/app_back_button.dart';
import 'package:raff_app/core/widgets/app_search_field.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_state.dart';
import 'package:raff_app/features/catalog/presentation/widgets/search/search_popular_section.dart';
import 'package:raff_app/features/catalog/presentation/widgets/search/search_recent_section.dart';
import 'package:raff_app/features/catalog/presentation/widgets/search/search_results_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _recentKey = 'RECENT_SEARCH_QUERIES';

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    final saved = sl<SharedPreferences>().getStringList(_recentKey);
    if (saved != null) {
      setState(() => _recentSearches = saved);
    }
  }

  Future<void> _saveSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;

    final updated = [
      trimmed,
      ..._recentSearches.where((item) => item != trimmed),
    ].take(8).toList();

    setState(() => _recentSearches = updated);
    await sl<SharedPreferences>().setStringList(_recentKey, updated);
  }

  Future<void> _clearRecentSearches() async {
    setState(() => _recentSearches = []);
    await sl<SharedPreferences>().remove(_recentKey);
  }

  void _selectRecentQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _saveSearchQuery(query);
    context.read<SearchCubit>().onSearchChanged(query);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      context.read<SearchCubit>().loadMoreResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 20, 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(4),
                  Expanded(
                    child: AppSearchField(
                      controller: _searchController,
                      hintText: l10n.searchHint,
                      autofocus: true,
                      isOutline: true,
                      onChanged: (value) =>
                          context.read<SearchCubit>().onSearchChanged(value),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocConsumer<SearchCubit, SearchState>(
                listener: (context, state) {
                  if (state is SearchSuccess && state.products.isNotEmpty) {
                    _saveSearchQuery(_searchController.text);
                  }
                },
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchRecentSection(
                            searches: _recentSearches,
                            onSelect: _selectRecentQuery,
                            onClear: _clearRecentSearches,
                          ),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, homeState) {
                              final popular = homeState is HomeSuccess
                                  ? homeState.products
                                  : <ProductEntity>[];
                              return SearchPopularSection(
                                products: popular,
                                onProductTap: (product) => context.push(
                                  AppRoutes.productDetails,
                                  extra: product.id,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchLoading) {
                    return const LoadingView();
                  }

                  if (state is SearchFailure) {
                    return ErrorView(
                      message: state.failure.message(context),
                      onRetry: () => context
                          .read<SearchCubit>()
                          .onSearchChanged(_searchController.text),
                    );
                  }

                  if (state is SearchSuccess) {
                    if (state.products.isEmpty) {
                      return EmptyView(title: l10n.noResultsFound);
                    }

                    return SearchResultsGrid(
                      controller: _scrollController,
                      products: state.products,
                      isLoadingMore: state.isLoadingMore,
                      onProductTap: (product) {
                        _saveSearchQuery(_searchController.text);
                        context.push(
                          AppRoutes.productDetails,
                          extra: product.id,
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
