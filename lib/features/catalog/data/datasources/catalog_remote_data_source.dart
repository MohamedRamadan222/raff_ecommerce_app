import 'package:dio/dio.dart';
import 'package:raff_app/core/network/dio_clint.dart';
import 'package:raff_app/features/catalog/data/models/category_model.dart';
import 'package:raff_app/features/catalog/data/models/paginated_products_model.dart';

import '../models/product_model.dart';

abstract class CatalogRemoteDataSource {
  Future<PaginatedProductsModel> getProducts({int limit = 10, int skip = 0});

  Future<List<CategoryModel>> getCategories();

  Future<PaginatedProductsModel> getProductsByCategory({
    required String categorySlug,
    int limit = 10,
    int skip = 0,
  });

  Future<PaginatedProductsModel> searchProducts({
    required String query,
    int limit = 10,
    int skip = 0,
  });

  Future<ProductModel> getProductDetails(int id);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio _dio;

  CatalogRemoteDataSourceImpl(DioClint dioClient) : _dio = dioClient.dio;

  @override
  Future<PaginatedProductsModel> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final response = await _dio.get(
      'products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return PaginatedProductsModel.fromJson(response.data);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('products/categories');
    return (response.data as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaginatedProductsModel> getProductsByCategory({
    required String categorySlug,
    int limit = 10,
    int skip = 0,
  }) async {
    final response = await _dio.get(
      'products/category/$categorySlug',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return PaginatedProductsModel.fromJson(response.data);
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    final response = await _dio.get('products/$id');
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<PaginatedProductsModel> searchProducts({
    required String query,
    int limit = 10,
    int skip = 0,
  }) async {
    final response = await _dio.get(
      'products/search',
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return PaginatedProductsModel.fromJson(response.data);
  }
}
