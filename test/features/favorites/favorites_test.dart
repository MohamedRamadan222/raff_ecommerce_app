import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
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
  });
}
