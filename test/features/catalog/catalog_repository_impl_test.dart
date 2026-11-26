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
