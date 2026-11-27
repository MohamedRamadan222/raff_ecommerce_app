import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  List<CartItemModel> getCartItems();

  Future<void> addToCart(CartItemModel item);

  Future<void> updateQuantity(int productId, int quantity);

  Future<void> removeFromCart(int productId);

  Future<void> clearCart();

  Future<void> clearAll();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Box<String> box;

  CartLocalDataSourceImpl(this.box);

  /// الأصناف بترتيب العرض (الأحدث الأول) عشان ما نفكش الـ JSON غير مرة واحدة.
  List<CartItemModel>? _itemsCache;

  void _ensureLoaded() {
    if (_itemsCache != null) return;
    final items = box.values
        .map(
          (raw) =>
              CartItemModel.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    // الـ Box بيحفظ الأقدم الأول، والشاشة بتعرض الأحدث الأول.
    _itemsCache = items.reversed.toList();
  }

  List<CartItemModel> get _items {
    _ensureLoaded();
    return _itemsCache!;
  }

  @override
  List<CartItemModel> getCartItems() {
    return List<CartItemModel>.unmodifiable(_items);
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    final key = item.product.id.toString();
    final maxStock = item.product.stock > 0 ? item.product.stock : 99;
    final items = _items;

    final index = items.indexWhere((e) => e.product.id == item.product.id);
    if (index >= 0) {
      final existing = items[index];
      final updatedQty = (existing.quantity + item.quantity).clamp(1, maxStock);

      final updatedModel = CartItemModel(
        product: item.product,
        quantity: updatedQty,
        colorHex: item.colorHex ?? existing.colorHex,
      );
      items[index] = updatedModel;
      await box.put(key, jsonEncode(updatedModel.toJson()));
    } else {
      final clampedModel = CartItemModel(
        product: item.product,
        quantity: item.quantity.clamp(1, maxStock),
        colorHex: item.colorHex,
      );
      // المنتج الجديد بيتضاف آخر الـ Box، يعني أول قائمة العرض.
      items.insert(0, clampedModel);
      await box.put(key, jsonEncode(clampedModel.toJson()));
    }
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    final items = _items;
    final index = items.indexWhere((e) => e.product.id == productId);
    if (index < 0) return;

    if (quantity <= 0) {
      items.removeAt(index);
      await box.delete(productId.toString());
      return;
    }

    final existing = items[index];
    final maxStock = existing.product.stock > 0 ? existing.product.stock : 99;

    final updatedModel = CartItemModel(
      product: existing.product,
      quantity: quantity.clamp(1, maxStock),
      colorHex: existing.colorHex,
    );
    items[index] = updatedModel;
    await box.put(productId.toString(), jsonEncode(updatedModel.toJson()));
  }

  @override
  Future<void> removeFromCart(int productId) async {
    final items = _items;
    items.removeWhere((e) => e.product.id == productId);
    await box.delete(productId.toString());
  }

  @override
  Future<void> clearCart() async {
    await box.clear();
    _itemsCache = <CartItemModel>[];
  }

  @override
  Future<void> clearAll() => clearCart();
}
