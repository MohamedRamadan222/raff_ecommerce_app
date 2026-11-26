import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:raff_app/features/cart/data/models/cart_item_model.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/hive_helper.dart';

void main() {
  late Box<String> box;
  late Directory dir;
  late CartLocalDataSourceImpl dataSource;

  CartItemModel item({int id = 1, int quantity = 1, int stock = 10}) {
    return CartItemModel.fromEntity(
      fakeCartItem(id: id, quantity: quantity).copyWith(
        product: fakeProduct(id: id, stock: stock),
      ),
    );
  }

  setUp(() async {
    (box, dir) = await openTempBox('cart_test');
    dataSource = CartLocalDataSourceImpl(box);
  });

  tearDown(() => closeTempBox(box, dir));

  test('adding the same product twice sums the quantity', () async {
    await dataSource.addToCart(item(quantity: 2));
    await dataSource.addToCart(item(quantity: 3));

    final items = dataSource.getCartItems();
    expect(items, hasLength(1));
    expect(items.single.quantity, 5);
  });

  test('quantity is limited by the product stock', () async {
    await dataSource.addToCart(item(quantity: 8, stock: 5));

    expect(dataSource.getCartItems().single.quantity, 5);
  });

  test('updateQuantity changes the quantity and respects the stock', () async {
    await dataSource.addToCart(item(stock: 4));

    await dataSource.updateQuantity(1, 3);
    expect(dataSource.getCartItems().single.quantity, 3);

    await dataSource.updateQuantity(1, 50);
    expect(dataSource.getCartItems().single.quantity, 4);
  });

  test('updateQuantity with zero removes the item', () async {
    await dataSource.addToCart(item());

    await dataSource.updateQuantity(1, 0);

    expect(dataSource.getCartItems(), isEmpty);
  });

  test('removeFromCart removes only that product', () async {
    await dataSource.addToCart(item(id: 1));
    await dataSource.addToCart(item(id: 2));

    await dataSource.removeFromCart(1);

    expect(dataSource.getCartItems().map((e) => e.product.id), [2]);
  });

  test('clearCart empties the box', () async {
    await dataSource.addToCart(item(id: 1));
    await dataSource.addToCart(item(id: 2));

    await dataSource.clearCart();

    expect(dataSource.getCartItems(), isEmpty);
  });
}
