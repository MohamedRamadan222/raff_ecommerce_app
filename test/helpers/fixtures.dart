import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

ProductEntity fakeProduct({
  int id = 1,
  double price = 100,
  int stock = 10,
  double discountPercentage = 0,
}) {
  return ProductEntity(
    id: id,
    title: 'Product $id',
    description: 'Description $id',
    category: 'beauty',
    price: price,
    discountPercentage: discountPercentage,
    rating: 4.5,
    stock: stock,
    thumbnail: 'https://example.com/$id.png',
    images: const [],
  );
}

CartItemEntity fakeCartItem({
  int id = 1,
  double price = 100,
  int quantity = 1,
}) {
  return CartItemEntity(
    product: fakeProduct(id: id, price: price),
    quantity: quantity,
  );
}

OrderEntity fakeOrder({
  String id = 'RF-1',
  OrderStatus status = OrderStatus.placed,
  DateTime? createdAt,
}) {
  return OrderEntity(
    id: id,
    items: const [
      OrderItemEntity(
        productId: 1,
        title: 'Product 1',
        thumbnail: 'https://example.com/1.png',
        price: 100,
        quantity: 2,
      ),
    ],
    subtotal: 200,
    discount: 0,
    shippingFee: 0,
    codFee: 0,
    total: 200,
    status: status,
    createdAt: createdAt ?? DateTime.now(),
    addressLabel: 'Home',
    addressFull: 'Riyadh, King Fahd Road',
    deliveryMethod: 'standard',
    paymentMethod: 'cod',
  );
}
