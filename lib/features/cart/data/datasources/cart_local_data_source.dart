import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  List<CartItemModel> getCartItems();

  Future<void> addToCart(CartItemModel item);

  Future<void> updateQuantity(int productId, int quantity);

  Future<void> removeFromCart(int productId);

  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Box<String> box;

  CartLocalDataSourceImpl(this.box);

  @override
  List<CartItemModel> getCartItems() {
    return box.values.toList().reversed.map((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CartItemModel.fromJson(map);
    }).toList();
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    final key = item.product.id.toString();
    final maxStock = item.product.stock > 0 ? item.product.stock : 99;

    if (box.containsKey(key)) {
      final existingMap = jsonDecode(box.get(key)!) as Map<String, dynamic>;
      final existing = CartItemModel.fromJson(existingMap);
      final updatedQty = (existing.quantity + item.quantity).clamp(1, maxStock);

      final updatedModel = CartItemModel(
        product: item.product,
        quantity: updatedQty,
        colorHex: item.colorHex ?? existing.colorHex,
      );
      await box.put(key, jsonEncode(updatedModel.toJson()));
    } else {
      final clampedModel = CartItemModel(
        product: item.product,
        quantity: item.quantity.clamp(1, maxStock),
        colorHex: item.colorHex,
      );
      await box.put(key, jsonEncode(clampedModel.toJson()));
    }
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    final key = productId.toString();
    if (!box.containsKey(key)) return;

    if (quantity <= 0) {
      await box.delete(key);
      return;
    }

    final existingMap = jsonDecode(box.get(key)!) as Map<String, dynamic>;
    final existing = CartItemModel.fromJson(existingMap);
    final maxStock = existing.product.stock > 0 ? existing.product.stock : 99;

    final updatedModel = CartItemModel(
      product: existing.product,
      quantity: quantity.clamp(1, maxStock),
      colorHex: existing.colorHex,
    );
    await box.put(key, jsonEncode(updatedModel.toJson()));
  }

  @override
  Future<void> removeFromCart(int productId) async {
    await box.delete(productId.toString());
  }

  @override
  Future<void> clearCart() async {
    await box.clear();
  }
}
