import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/core/network/dio_clint.dart';
import 'package:raff_app/core/network/error_interceptor.dart';
import 'package:raff_app/features/catalog/data/datasources/catalog_remote_data_source.dart';

import '../../helpers/fake_http_adapter.dart';

const _productJson = {
  'id': 1,
  'title': 'Mascara',
  'description': 'Black',
  'category': 'beauty',
  'price': 9.99,
  'discountPercentage': 7,
  'rating': 4.9,
  'stock': 5,
  'brand': 'Essence',
  'thumbnail': 'https://img/1.png',
  'images': ['https://img/1.png'],
};

void main() {
  late DioClint client;

  CatalogRemoteDataSourceImpl dataSourceWith(FakeHttpAdapter adapter) {
    client = DioClint();
    client.dio.httpClientAdapter = adapter;
    return CatalogRemoteDataSourceImpl(client);
  }

  test('getProducts sends limit and skip and parses the products', () async {
    final adapter = FakeHttpAdapter(
      body: {
        'products': [_productJson],
        'total': 100,
        'skip': 10,
        'limit': 10,
      },
    );
    final dataSource = dataSourceWith(adapter);

    final result = await dataSource.getProducts(limit: 10, skip: 10);

    expect(adapter.lastRequest!.path, 'products');
    expect(adapter.lastRequest!.queryParameters, {'limit': 10, 'skip': 10});
    expect(result.products.single.title, 'Mascara');
    expect(result.products.single.discountPercentage, 7.0);
    expect(result.total, 100);
    expect(result.hasMore, isTrue);
  });

  test('getCategories parses the list', () async {
    final dataSource = dataSourceWith(
      FakeHttpAdapter(
        body: [
          {'slug': 'beauty', 'name': 'Beauty', 'url': 'x'},
        ],
      ),
    );

    final result = await dataSource.getCategories();

    expect(result.single.slug, 'beauty');
    expect(result.single.name, 'Beauty');
  });

  test('searchProducts sends the query', () async {
    final adapter = FakeHttpAdapter(
      body: {'products': <dynamic>[], 'total': 0, 'skip': 0, 'limit': 10},
    );
    final dataSource = dataSourceWith(adapter);

    final result = await dataSource.searchProducts(query: 'phone');

    expect(adapter.lastRequest!.path, 'products/search');
    expect(adapter.lastRequest!.queryParameters['q'], 'phone');
    expect(result.products, isEmpty);
  });

  test('getProductsByCategory puts the slug in the path', () async {
    final adapter = FakeHttpAdapter(
      body: {'products': <dynamic>[], 'total': 0, 'skip': 0, 'limit': 10},
    );
    final dataSource = dataSourceWith(adapter);

    await dataSource.getProductsByCategory(categorySlug: 'beauty');

    expect(adapter.lastRequest!.path, 'products/category/beauty');
  });

  test(
    'getProductDetails parses one product and defaults missing fields',
    () async {
      final dataSource = dataSourceWith(
        FakeHttpAdapter(body: {'id': 3, 'title': 'Only title'}),
      );

      final product = await dataSource.getProductDetails(3);

      expect(product.id, 3);
      expect(product.price, 0);
      expect(product.images, isEmpty);
      expect(product.brand, isNull);
    },
  );

  test(
    'a 404 response becomes a DioException carrying a ServerFailure',
    () async {
      final dataSource = dataSourceWith(
        FakeHttpAdapter(statusCode: 404, body: {'message': 'Not found'}),
      );

      expect(
        dataSource.getProductDetails(1),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.badResponse,
          ),
        ),
      );
    },
  );

  test('ErrorInterceptor is registered on the client', () {
    expect(
      DioClint().dio.interceptors.whereType<ErrorInterceptor>(),
      isNotEmpty,
    );
  });
}
