import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_categories_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/search_products_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_state.dart';

import '../../helpers/fixtures.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

void main() {
  final products = [fakeProduct(id: 1), fakeProduct(id: 2)];
  const categories = [CategoryEntity(slug: 'beauty', name: 'Beauty')];

  group('PaginatedProductsEntity.hasMore', () {
    test('is true while there are more products on the server', () {
      final page = PaginatedProductsEntity(
        products: products,
        total: 5,
        skip: 0,
        limit: 2,
      );

      expect(page.hasMore, isTrue);
    });

    test('is false on the last page', () {
      final page = PaginatedProductsEntity(
        products: products,
        total: 2,
        skip: 0,
        limit: 2,
      );

      expect(page.hasMore, isFalse);
    });
  });

  group('ProductEntity.priceBeforeDiscount', () {
    test('goes back to the original price', () {
      expect(
        fakeProduct(price: 90, discountPercentage: 10).priceBeforeDiscount,
        closeTo(100, 0.001),
      );
    });

    test('is the same price when there is no discount', () {
      expect(fakeProduct(price: 90).priceBeforeDiscount, 90);
    });
  });

  group('HomeCubit', () {
    late MockGetCategoriesUseCase getCategories;
    late MockGetProductsUseCase getProducts;

    setUp(() {
      getCategories = MockGetCategoriesUseCase();
      getProducts = MockGetProductsUseCase();
    });

    HomeCubit buildCubit() => HomeCubit(
      getProductsUseCase: getProducts,
      getCategoriesUseCase: getCategories,
    );

    final page = PaginatedProductsEntity(
      products: products,
      total: 2,
      skip: 0,
      limit: 10,
    );

    blocTest<HomeCubit, HomeState>(
      'emits loading then success with categories and products',
      build: () {
        when(() => getCategories())
            .thenAnswer((_) async => const Right(categories));
        when(() => getProducts(limit: 10, skip: 0))
            .thenAnswer((_) async => Right(page));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHomeData(),
      expect: () => [
        const HomeLoading(),
        HomeSuccess(categories: categories, products: products),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'still succeeds with no categories when only the categories call fails',
      build: () {
        when(() => getCategories())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => getProducts(limit: 10, skip: 0))
            .thenAnswer((_) async => Right(page));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHomeData(),
      expect: () => [
        const HomeLoading(),
        HomeSuccess(categories: const [], products: products),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits failure when the products call fails',
      build: () {
        when(() => getCategories())
            .thenAnswer((_) async => const Right(categories));
        when(() => getProducts(limit: 10, skip: 0))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHomeData(),
      expect: () => [const HomeLoading(), const HomeFailure(NetworkFailure())],
    );
  });

  group('SearchCubit', () {
    late MockSearchProductsUseCase search;

    setUp(() => search = MockSearchProductsUseCase());

    final firstPage = PaginatedProductsEntity(
      products: products,
      total: 3,
      skip: 0,
      limit: 2,
    );

    blocTest<SearchCubit, SearchState>(
      'waits for the debounce, then emits loading and results',
      build: () {
        when(() => search(query: 'lip', limit: 10, skip: 0))
            .thenAnswer((_) async => Right(firstPage));
        return SearchCubit(search);
      },
      act: (cubit) => cubit.onSearchChanged(' lip '),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        const SearchLoading(),
        SearchSuccess(products: products, hasMore: true),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'typing fast only searches for the last text',
      build: () {
        when(() => search(query: 'lipstick', limit: 10, skip: 0))
            .thenAnswer((_) async => Right(firstPage));
        return SearchCubit(search);
      },
      act: (cubit) {
        cubit.onSearchChanged('l');
        cubit.onSearchChanged('lip');
        cubit.onSearchChanged('lipstick');
      },
      wait: const Duration(milliseconds: 600),
      verify: (_) {
        verify(() => search(query: 'lipstick', limit: 10, skip: 0)).called(1);
        verifyNever(() => search(query: 'l', limit: 10, skip: 0));
      },
    );

    blocTest<SearchCubit, SearchState>(
      'an empty query goes back to the initial state without searching',
      build: () => SearchCubit(search),
      act: (cubit) => cubit.onSearchChanged('   '),
      expect: () => [const SearchInitial()],
      verify: (_) => verifyNever(
        () => search(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        ),
      ),
    );

    blocTest<SearchCubit, SearchState>(
      'loadMoreResults appends the next page using skip',
      build: () {
        when(() => search(query: 'lip', limit: 10, skip: 0))
            .thenAnswer((_) async => Right(firstPage));
        when(() => search(query: 'lip', limit: 10, skip: 2)).thenAnswer(
          (_) async => Right(
            PaginatedProductsEntity(
              products: [fakeProduct(id: 3)],
              total: 3,
              skip: 2,
              limit: 10,
            ),
          ),
        );
        return SearchCubit(search);
      },
      act: (cubit) async {
        cubit.onSearchChanged('lip');
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await cubit.loadMoreResults();
      },
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        final state = cubit.state as SearchSuccess;
        expect(state.products.map((p) => p.id), [1, 2, 3]);
        expect(state.hasMore, isFalse);
        expect(state.isLoadingMore, isFalse);
      },
    );
  });
}
