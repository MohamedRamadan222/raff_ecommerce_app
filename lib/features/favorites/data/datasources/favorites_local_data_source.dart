import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/favorites/data/models/favorite_product_model.dart';

abstract class FavoritesLocalDataSource {
  List<FavoriteProductModel> getFavorites();

  Future<void> toggleFavorite(FavoriteProductModel product);

  bool isFavorite(int productId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final Box<String> box;

  FavoritesLocalDataSourceImpl(this.box);

  @override
  List<FavoriteProductModel> getFavorites() {
    return box.values.toList().reversed.map((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return FavoriteProductModel.fromJson(map);
    }).toList();
  }

  @override
  bool isFavorite(int productId) {
    return box.containsKey(productId.toString());
  }

  @override
  Future<void> toggleFavorite(FavoriteProductModel product) async {
    final key = product.id.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      await box.put(key, jsonEncode(product.toJson()));
    }
  }
}
