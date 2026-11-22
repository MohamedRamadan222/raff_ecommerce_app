import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';
import 'package:raff_app/features/catalog/presentation/widgets/category_grid_card.dart';
import 'package:raff_app/features/catalog/presentation/widgets/featured_category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.navCategories,
                    style: tt.headlineMedium!.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push(AppRoutes.search),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.search_rounded,
                        size: 24,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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

                  final categories = state.categories;
                  if (categories.isEmpty) {
                    return EmptyView(title: l10n.noResultsFound);
                  }

                  final remaining = categories.length > 1
                      ? categories.sublist(1)
                      : <CategoryEntity>[];

                  return RefreshIndicator(
                    color: cs.primary,
                    onRefresh: () => context.read<HomeCubit>().loadHomeData(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                          sliver: SliverToBoxAdapter(
                            child: FeaturedCategoryCard(
                              category: categories.first,
                              onTap: () =>
                                  _openCategory(context, categories.first),
                            ),
                          ),
                        ),
                        if (remaining.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 1.05,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => CategoryGridCard(
                                  category: remaining[index],
                                  index: index,
                                  onTap: () =>
                                      _openCategory(context, remaining[index]),
                                ),
                                childCount: remaining.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, CategoryEntity category) {
    context.push(
      AppRoutes.products,
      extra: {
        'slug': category.slug,
        'name': CatalogHelper.localizeCategory(
          context,
          slug: category.slug,
          fallbackName: category.name,
        ),
      },
    );
  }
}
