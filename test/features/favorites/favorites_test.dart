import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:raff_app/features/favorites/data/models/favorite_product_model.dart';
import 'package:raff_app/features/favorites/domain/usecases/get_favorites_use_case.dart';
import 'package:raff_app/features/favorites/domain/usecases/toggle_favorite_use_case.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/hive_helper.dart';

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

void main() {
  ProductEntity fullProduct({int id = 1}) {
    return ProductEntity(
      id: id,
      title: 'Product $id',
      description: 'A long description for product $id',
      category: 'beauty',
      price: 100,
      discountPercentage: 12.5,
      rating: 4.5,
      stock: 10,
      brand: 'Brand $id',
      thumbnail: 'https://example.com/$id.png',
      images: [
        'https://example.com/$id-1.png',
        'https://example.com/$id-2.png',
      ],
    );
  }

  group('FavoritesCubit', () {
    late MockGetFavoritesUseCase getFavorites;
    late MockToggleFavoriteUseCase toggleFavorite;
    final product = fakeProduct(id: 5);

    setUpAll(() => registerFallbackValue(fakeProduct()));

    setUp(() {
      getFavorites = MockGetFavoritesUseCase();
      toggleFavorite = MockToggleFavoriteUseCase();
    });

    FavoritesCubit buildCubit() => FavoritesCubit(
      getFavoritesUseCase: getFavorites,
      toggleFavoriteUseCase: toggleFavorite,
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'loadFavorites emits loading then the saved products',
      build: () {
        when(() => getFavorites()).thenReturn(Right([product]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        const FavoritesState(status: FavoritesStatus.loading),
        FavoritesState(status: FavoritesStatus.success, favorites: [product]),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavorite emits the updated list and isFavorite follows it',
      build: () {
        when(() => toggleFavorite(any()))
            .thenAnswer((_) async => Right([product]));
        return buildCubit();
      },
      act: (cubit) => cubit.toggleFavorite(product),
      verify: (cubit) {
        expect(cubit.isFavorite(5), isTrue);
        expect(cubit.isFavorite(6), isFalse);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavorite emits failure when saving fails',
      build: () {
        when(() => toggleFavorite(any()))
            .thenAnswer((_) async => const Left(UnknownFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.toggleFavorite(product),
      expect: () => [
        const FavoritesState(
          status: FavoritesStatus.failure,
          failure: UnknownFailure(),
        ),
      ],
    );
  });

  group('FavoritesLocalDataSourceImpl (real Hive box)', () {
    late Box<String> box;
    late Directory dir;
    late FavoritesLocalDataSourceImpl dataSource;

    setUp(() async {
      (box, dir) = await openTempBox('favorites_test');
      dataSource = FavoritesLocalDataSourceImpl(box);
    });

    tearDown(() => closeTempBox(box, dir));

    test(
      'toggle adds the product the first time and removes it the second',
      () async {
        final model = FavoriteProductModel.fromEntity(fakeProduct(id: 3));

        await dataSource.toggleFavorite(model);
        expect(dataSource.isFavorite(3), isTrue);
        expect(dataSource.getFavorites().single.id, 3);

        await dataSource.toggleFavorite(model);
        expect(dataSource.isFavorite(3), isFalse);
        expect(dataSource.getFavorites(), isEmpty);
      },
    );

    test('the most recently added favorite comes first', () async {
      await dataSource.toggleFavorite(
        FavoriteProductModel.fromEntity(fakeProduct(id: 1)),
      );
      await dataSource.toggleFavorite(
        FavoriteProductModel.fromEntity(fakeProduct(id: 2)),
      );

      expect(dataSource.getFavorites().map((e) => e.id), [2, 1]);
    });

    test('the returned list is a copy that cannot change the cache', () async {
      final model = FavoriteProductModel.fromEntity(fakeProduct(id: 3));
      await dataSource.toggleFavorite(model);

      final favorites = dataSource.getFavorites();

      expect(() => favorites.add(model), throwsUnsupportedError);
      expect(dataSource.getFavorites(), hasLength(1));
    });

    test('clearAll empties the box and the cache', () async {
      await dataSource.toggleFavorite(
        FavoriteProductModel.fromEntity(fakeProduct(id: 1)),
      );

      await dataSource.clearAll();

      expect(dataSource.getFavorites(), isEmpty);
      expect(dataSource.isFavorite(1), isFalse);
      expect(box.isEmpty, isTrue);
    });

    test('toJson stores only the summary product fields', () {
      final model = FavoriteProductModel.fromEntity(fullProduct(id: 3));

      final json = model.toJson();

      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('images'), isFalse);
      expect(json.keys, [
        'id',
        'title',
        'category',
        'price',
        'discountPercentage',
        'rating',
        'stock',
        'brand',
        'thumbnail',
      ]);
    });

    test('a compact favorite round-trips the fields the UI needs', () {
      final model = FavoriteProductModel.fromEntity(fullProduct(id: 3));

      final restored = FavoriteProductModel.fromJson(
        jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>,
      );

      expect(restored.id, 3);
      expect(restored.title, 'Product 3');
      expect(restored.category, 'beauty');
      expect(restored.price, 100);
      expect(restored.discountPercentage, 12.5);
      expect(restored.rating, 4.5);
      expect(restored.stock, 10);
      expect(restored.brand, 'Brand 3');
      expect(restored.thumbnail, 'https://example.com/3.png');
      // الحقول المستبعدة بترجع للقيم الافتراضية بدل ما تكسر القراءة.
      expect(restored.description, '');
      expect(restored.images, isEmpty);
    });

    test(
      'a favorite is persisted compactly and reloads after restart',
      () async {
        final model = FavoriteProductModel.fromEntity(fullProduct(id: 3));

        await dataSource.toggleFavorite(model);

        final raw = jsonDecode(box.get('3')!) as Map<String, dynamic>;
        expect(raw.containsKey('description'), isFalse);
        expect(raw.containsKey('images'), isFalse);

        final restored = FavoritesLocalDataSourceImpl(box)
            .getFavorites()
            .single;

        expect(restored.id, 3);
        expect(restored.title, 'Product 3');
        expect(restored.brand, 'Brand 3');
        expect(restored.thumbnail, 'https://example.com/3.png');
        expect(restored.description, '');
        expect(restored.images, isEmpty);
      },
    );
  });
}
