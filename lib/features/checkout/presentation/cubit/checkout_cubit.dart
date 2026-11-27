import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/cart/domain/usecases/clear_cart_use_case.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/usecases/add_notification_use_case.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/usecases/place_order_use_case.dart';

/// ينفّذ عملية الشراء كوحدة واحدة: يحفظ الطلب أولًا، وبعد التأكد من حفظه
/// ينشئ الإشعار ويفرّغ السلة كآثار جانبية غير حرجة.
class CheckoutCubit extends Cubit<CheckoutState> {
  final PlaceOrderUseCase placeOrderUseCase;
  final AddNotificationUseCase addNotificationUseCase;
  final ClearCartUseCase clearCartUseCase;

  CheckoutCubit({
    required this.placeOrderUseCase,
    required this.addNotificationUseCase,
    required this.clearCartUseCase,
  }) : super(const CheckoutInitial());

  Future<Either<Failure, OrderEntity>> submit({
    required List<CartItemEntity> items,
    required CheckoutTotals totals,
    required AddressEntity address,
    required String addressLabel,
    required String deliveryMethod,
    required String paymentMethod,
    String? courierNote,
    String? promoCode,
  }) async {
    final now = DateTime.now();
    final order = OrderEntity(
      // Microseconds + base36 keeps IDs unique across rapid orders while
      // remaining short and path-safe.
      id: 'RF-${now.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      items: items
          .map(
            (item) => OrderItemEntity(
              productId: item.product.id,
              title: item.product.title,
              thumbnail: item.product.thumbnail,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
      subtotal: totals.subtotal,
      discount: totals.discount,
      shippingFee: totals.shippingFee,
      codFee: totals.codFee,
      total: totals.total,
      promoCode: promoCode,
      status: OrderStatus.placed,
      createdAt: now,
      addressLabel: addressLabel,
      addressFull: address.fullAddress,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      courierNote: courierNote,
    );

    emit(const CheckoutSubmitting());

    final result = await placeOrderUseCase(order);
    final failure = result.fold<Failure?>((failure) => failure, (_) => null);

    if (failure != null) {
      if (!isClosed) emit(CheckoutFailure(failure));
      return Left(failure);
    }

    // الطلب اتحفظ بالفعل، فالإشعار وتفريغ السلة محاولات بهتر لا تُبطل الطلب.
    await _addOrderNotification(order);
    await _clearCart();

    if (!isClosed) emit(CheckoutSuccess(order));
    return Right(order);
  }

  Future<void> _addOrderNotification(OrderEntity order) async {
    try {
      await addNotificationUseCase(
        NotificationEntity(
          id: 'notif-${order.id}',
          type: NotificationType.orderPlaced,
          orderId: order.id,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // فشل الإشعار لا يغيّر حقيقة أن الطلب محفوظ.
    }
  }

  Future<void> _clearCart() async {
    try {
      await clearCartUseCase();
    } catch (_) {
      // فشل تفريغ السلة لا يغيّر حقيقة أن الطلب محفوظ.
    }
  }
}
