import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/favorites/data/models/favorite_product_model.dart';

abstract class FavoritesLocalDataSource {
  List<FavoriteProductModel> getFavorites();

  Future<void> toggleFavorite(FavoriteProductModel product);

  bool isFavorite(int productId);

  Future<void> clearAll();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final Box<String> box;

  FavoritesLocalDataSourceImpl(this.box);

  /// المفضلة بترتيب العرض (الأحدث الأول) عشان ما نفكش الـ JSON غير مرة واحدة.
  List<FavoriteProductModel>? _favoritesCache;

  void _ensureLoaded() {
    if (_favoritesCache != null) return;
    final favorites = box.values
        .map(
          (raw) => FavoriteProductModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          ),
        )
        .toList();
    // الـ Box بيحفظ الأقدم الأول، والشاشة بتعرض الأحدث الأول.
    _favoritesCache = favorites.reversed.toList();
  }

  List<FavoriteProductModel> get _favorites {
    _ensureLoaded();
    return _favoritesCache!;
  }

  @override
  List<FavoriteProductModel> getFavorites() {
    return List<FavoriteProductModel>.unmodifiable(_favorites);
  }

  @override
  bool isFavorite(int productId) {
    return box.containsKey(productId.toString());
  }

  @override
  Future<void> toggleFavorite(FavoriteProductModel product) async {
    final key = product.id.toString();
    final favorites = _favorites;
    final index = favorites.indexWhere((e) => e.id == product.id);

    if (index >= 0) {
      favorites.removeAt(index);
      await box.delete(key);
    } else {
      // المنتج الجديد بيتضاف آخر الـ Box، يعني أول قائمة العرض.
      favorites.insert(0, product);
      await box.put(key, jsonEncode(product.toJson()));
    }
  }

  @override
  Future<void> clearAll() async {
    await box.clear();
    _favoritesCache = <FavoriteProductModel>[];
  }
}
