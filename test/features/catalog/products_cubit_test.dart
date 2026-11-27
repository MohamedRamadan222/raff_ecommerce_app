import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_by_category_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_filter.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_state.dart';

import '../../helpers/fixtures.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

void main() {
  late MockGetProductsUseCase getProducts;
  late MockGetProductsByCategoryUseCase getProductsByCategory;

  setUp(() {
    getProducts = MockGetProductsUseCase();
    getProductsByCategory = MockGetProductsByCategoryUseCase();
  });

  ProductsCubit buildCubit() => ProductsCubit(
    getProductsUseCase: getProducts,
    getProductsByCategoryUseCase: getProductsByCategory,
  );

  group('filters and sort', () {
    final products = [
      fakeProduct(id: 1, price: 300, discountPercentage: 10),
      fakeProduct(id: 2, price: 100),
      fakeProduct(id: 3, price: 50, discountPercentage: 20),
    ];
    final page = PaginatedProductsEntity(
      products: products,
      total: products.length,
      skip: 0,
      limit: 10,
    );

    blocTest<ProductsCubit, ProductsState>(
      'applies discount and price filters then sorts the visible list',
      build: () {
        when(() => getProducts(limit: 10, skip: 0))
            .thenAnswer((_) async => Right(page));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProducts();
        cubit.setFilters(discountsOnly: true, maxPrice: 5000);
        cubit.setSortOption(ProductSortOption.priceLowToHigh);
      },
      verify: (cubit) {
        final state = cubit.state as ProductsSuccess;
        expect(state.products.map((product) => product.id), [3, 1]);
        expect(cubit.discountsOnly, isTrue);
        expect(cubit.maxPrice, 5000);
        expect(cubit.sortOption, ProductSortOption.priceLowToHigh);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'keeps filters when the category changes',
      build: () {
        when(() => getProducts(limit: 10, skip: 0))
            .thenAnswer((_) async => Right(page));
        when(
          () =>
              getProductsByCategory(categorySlug: 'beauty', limit: 10, skip: 0),
        ).thenAnswer((_) async => Right(page));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProducts();
        cubit.setFilters(discountsOnly: true, maxPrice: 5000);
        await cubit.loadProducts(categorySlug: 'beauty');
      },
      verify: (cubit) {
        final state = cubit.state as ProductsSuccess;
        expect(state.products.map((product) => product.id), [1, 3]);
        expect(cubit.discountsOnly, isTrue);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'resetFilters restores the defaults',
      build: () {
        when(() => getProducts(limit: 10, skip: 0))
            .thenAnswer((_) async => Right(page));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProducts();
        cubit.setFilters(discountsOnly: true, maxPrice: 100);
        cubit.resetFilters();
      },
      verify: (cubit) {
        final state = cubit.state as ProductsSuccess;
        expect(state.products.map((product) => product.id), [1, 2, 3]);
        expect(cubit.discountsOnly, isFalse);
        expect(cubit.maxPrice, 5000);
      },
    );
  });

  group('pagination', () {
    blocTest<ProductsCubit, ProductsState>(
      'deduplicates appended products and advances skip by the raw page size',
      build: () {
        when(() => getProducts(limit: 10, skip: 0)).thenAnswer(
          (_) async => Right(
            PaginatedProductsEntity(
              products: [fakeProduct(id: 1), fakeProduct(id: 2)],
              total: 4,
              skip: 0,
              limit: 10,
            ),
          ),
        );
        when(() => getProducts(limit: 10, skip: 2)).thenAnswer(
          (_) async => Right(
            PaginatedProductsEntity(
              products: [fakeProduct(id: 2), fakeProduct(id: 3)],
              total: 4,
              skip: 2,
              limit: 10,
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProducts();
        await cubit.loadMoreProducts();
      },
      verify: (cubit) {
        final state = cubit.state as ProductsSuccess;
        expect(state.products.map((product) => product.id), [1, 2, 3]);
        expect(state.hasMore, isFalse);
        expect(state.isLoadingMore, isFalse);
      },
    );

    test('a stale load-more cannot overwrite a newer category load', () async {
      final loadMoreCompleter = Completer<PaginatedProductsEntity>();
      final firstPage = PaginatedProductsEntity(
        products: [fakeProduct(id: 1), fakeProduct(id: 2)],
        total: 4,
        skip: 0,
        limit: 10,
      );
      final categoryPage = PaginatedProductsEntity(
        products: [fakeProduct(id: 7)],
        total: 1,
        skip: 0,
        limit: 10,
      );

      when(() => getProducts(limit: 10, skip: 0))
          .thenAnswer((_) async => Right(firstPage));
      when(() => getProducts(limit: 10, skip: 2))
          .thenAnswer((_) async => Right(await loadMoreCompleter.future));
      when(
        () => getProductsByCategory(categorySlug: 'beauty', limit: 10, skip: 0),
      ).thenAnswer((_) async => Right(categoryPage));

      final cubit = buildCubit();
      await cubit.loadProducts();

      final loadMoreFuture = cubit.loadMoreProducts();
      await cubit.loadProducts(categorySlug: 'beauty');

      loadMoreCompleter.complete(
        PaginatedProductsEntity(
          products: [fakeProduct(id: 3), fakeProduct(id: 4)],
          total: 4,
          skip: 2,
          limit: 10,
        ),
      );
      await loadMoreFuture;

      final state = cubit.state as ProductsSuccess;
      expect(state.products.map((product) => product.id), [7]);
      expect(state.isLoadingMore, isFalse);
      await cubit.close();
    });
  });
}
