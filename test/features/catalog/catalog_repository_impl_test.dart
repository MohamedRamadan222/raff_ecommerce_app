import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:raff_app/features/catalog/data/models/paginated_products_model.dart';
import 'package:raff_app/features/catalog/data/repositories/catalog_repository_impl.dart';

class MockCatalogRemoteDataSource extends Mock
    implements CatalogRemoteDataSource {}

void main() {
  late MockCatalogRemoteDataSource remote;
  late CatalogRepositoryImpl repository;

  const page = PaginatedProductsModel(
    products: [],
    total: 0,
    skip: 0,
    limit: 10,
  );

  DioException dioError(DioExceptionType type, {Response? response}) {
    return DioException(
      requestOptions: RequestOptions(path: 'products'),
      type: type,
      response: response,
    );
  }

  setUp(() {
    remote = MockCatalogRemoteDataSource();
    repository = CatalogRepositoryImpl(remote);
  });

  test('returns Right with the data on success', () async {
    when(() => remote.getProducts(limit: 10, skip: 0))
        .thenAnswer((_) async => page);

    final result = await repository.getProducts();

    expect(result, const Right(page));
  });

  test('serves repeated successful product calls from cache', () async {
    when(() => remote.getProducts(limit: 10, skip: 0))
        .thenAnswer((_) async => page);

    await repository.getProducts();
    await repository.getProducts();

    verify(() => remote.getProducts(limit: 10, skip: 0)).called(1);
  });

  test('coalesces concurrent identical product requests', () async {
    final completer = Completer<PaginatedProductsModel>();
    when(() => remote.getProducts(limit: 10, skip: 0))
        .thenAnswer((_) => completer.future);

    final first = repository.getProducts();
    final second = repository.getProducts();

    expect(identical(first, second), isTrue);

    completer.complete(page);

    expect(await first, const Right(page));
    expect(await second, const Right(page));
    verify(() => remote.getProducts(limit: 10, skip: 0)).called(1);
  });

  test(
    'invalidateCache forces the next call to hit the remote again',
    () async {
      when(() => remote.getProducts(limit: 10, skip: 0))
          .thenAnswer((_) async => page);

      await repository.getProducts();
      await repository.getProducts();
      verify(() => remote.getProducts(limit: 10, skip: 0)).called(1);

      repository.invalidateCache();

      await repository.getProducts();

      // mocktail only counts unverified calls, so the post-invalidation call is
      // verified on its own.
      verify(() => remote.getProducts(limit: 10, skip: 0)).called(1);
    },
  );

  test('an in-flight request from before invalidation cannot overwrite a '
      'newer result', () async {
    final staleCompleter = Completer<PaginatedProductsModel>();
    when(() => remote.getProducts(limit: 10, skip: 0))
        .thenAnswer((_) => staleCompleter.future);

    final staleRequest = repository.getProducts();

    repository.invalidateCache();

    const freshPage = PaginatedProductsModel(
      products: [],
      total: 1,
      skip: 0,
      limit: 10,
    );
    final freshCompleter = Completer<PaginatedProductsModel>();
    when(() => remote.getProducts(limit: 10, skip: 0))
        .thenAnswer((_) => freshCompleter.future);

    final freshRequest = repository.getProducts();
    expect(identical(staleRequest, freshRequest), isFalse);

    freshCompleter.complete(freshPage);
    expect(await freshRequest, const Right(freshPage));

    // The pre-invalidation request resolves last and must be ignored.
    staleCompleter.complete(page);
    expect(await staleRequest, const Right(page));

    expect(await repository.getProducts(), const Right(freshPage));
    verify(() => remote.getProducts(limit: 10, skip: 0)).called(2);
  });

  test('does not cache failed responses', () async {
    when(() => remote.getCategories())
        .thenThrow(dioError(DioExceptionType.connectionError));

    expect(await repository.getCategories(), const Left(NetworkFailure()));
    expect(await repository.getCategories(), const Left(NetworkFailure()));

    verify(() => remote.getCategories()).called(2);
  });

  test('timeouts become TimeoutFailure', () async {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      when(() => remote.getProducts(limit: 10, skip: 0))
          .thenThrow(dioError(type));

      expect(await repository.getProducts(), const Left(TimeoutFailure()));
    }
  });

  test('connection error becomes NetworkFailure', () async {
    when(() => remote.getCategories())
        .thenThrow(dioError(DioExceptionType.connectionError));

    expect(await repository.getCategories(), const Left(NetworkFailure()));
  });

  test('bad response uses the server message', () async {
    when(() => remote.getProductDetails(1)).thenThrow(
      dioError(
        DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: 'products/1'),
          statusCode: 404,
          data: {'message': 'Product not found'},
        ),
      ),
    );

    expect(
      await repository.getProductDetails(1),
      const Left(ServerFailure('Product not found')),
    );
  });

  test('any other error becomes UnknownFailure', () async {
    when(() => remote.searchProducts(query: 'x', limit: 10, skip: 0))
        .thenThrow(StateError('boom'));

    expect(
      await repository.searchProducts(query: 'x'),
      const Left(UnknownFailure()),
    );
  });
}
