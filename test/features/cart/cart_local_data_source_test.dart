import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:raff_app/features/cart/data/models/cart_item_model.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

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

  test('a later product comes first and updates stay in place', () async {
    await dataSource.addToCart(item(id: 1));
    await dataSource.addToCart(item(id: 2));
    await dataSource.addToCart(item(id: 1, quantity: 2));

    final items = dataSource.getCartItems();

    expect(items.map((e) => e.product.id), [2, 1]);
    expect(items.last.quantity, 3);
  });

  test('the returned list is a copy that cannot change the cache', () async {
    await dataSource.addToCart(item());

    final items = dataSource.getCartItems();

    expect(() => items.add(item(id: 2)), throwsUnsupportedError);
    expect(dataSource.getCartItems(), hasLength(1));
  });

  test('clearAll empties the box and the cache', () async {
    await dataSource.addToCart(item(id: 1));

    await dataSource.clearAll();

    expect(dataSource.getCartItems(), isEmpty);
    expect(box.isEmpty, isTrue);
  });

  test('toJson stores only the summary product fields', () {
    final model = CartItemModel.fromEntity(
      CartItemEntity(
        product: fullProduct(id: 7),
        quantity: 3,
        colorHex: 'FF0000',
      ),
    );

    final productJson = model.toJson()['product'] as Map<String, dynamic>;

    expect(productJson.containsKey('description'), isFalse);
    expect(productJson.containsKey('images'), isFalse);
    expect(productJson.keys, [
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

  test('a compact cart item round-trips the fields the UI needs', () {
    final model = CartItemModel.fromEntity(
      CartItemEntity(
        product: fullProduct(id: 7),
        quantity: 3,
        colorHex: 'FF0000',
      ),
    );

    final restored = CartItemModel.fromJson(
      jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>,
    );

    expect(restored.product.id, 7);
    expect(restored.product.title, 'Product 7');
    expect(restored.product.category, 'beauty');
    expect(restored.product.price, 100);
    expect(restored.product.discountPercentage, 12.5);
    expect(restored.product.rating, 4.5);
    expect(restored.product.stock, 10);
    expect(restored.product.brand, 'Brand 7');
    expect(restored.product.thumbnail, 'https://example.com/7.png');
    expect(restored.quantity, 3);
    expect(restored.colorHex, 'FF0000');
    // الحقول المستبعدة بترجع للقيم الافتراضية بدل ما تكسر القراءة.
    expect(restored.product.description, '');
    expect(restored.product.images, isEmpty);
  });

  test('the box stores compact product JSON', () async {
    await dataSource.addToCart(
      CartItemModel.fromEntity(
        CartItemEntity(product: fullProduct(id: 7), quantity: 1),
      ),
    );

    final raw = jsonDecode(box.get('7')!) as Map<String, dynamic>;
    final productJson = raw['product'] as Map<String, dynamic>;

    expect(productJson.containsKey('description'), isFalse);
    expect(productJson.containsKey('images'), isFalse);
  });

  test('a compact item persisted in Hive loads again', () async {
    final model = CartItemModel.fromEntity(
      CartItemEntity(product: fullProduct(id: 7), quantity: 2),
    );
    await box.put('7', jsonEncode(model.toJson()));

    final restored = CartLocalDataSourceImpl(box).getCartItems().single;

    expect(restored.product.title, 'Product 7');
    expect(restored.product.brand, 'Brand 7');
    expect(restored.product.thumbnail, 'https://example.com/7.png');
    expect(restored.quantity, 2);
    expect(restored.product.description, '');
    expect(restored.product.images, isEmpty);
  });
}
