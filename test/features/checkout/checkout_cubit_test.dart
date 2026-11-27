import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/cart/domain/usecases/clear_cart_use_case.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:raff_app/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/usecases/add_notification_use_case.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/usecases/place_order_use_case.dart';

import '../../helpers/fixtures.dart';

class MockPlaceOrderUseCase extends Mock implements PlaceOrderUseCase {}

class MockAddNotificationUseCase extends Mock
    implements AddNotificationUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockPlaceOrderUseCase placeOrder;
  late MockAddNotificationUseCase addNotification;
  late MockClearCartUseCase clearCart;

  const address = AddressEntity(
    id: 'addr-1',
    label: AddressLabel.home,
    fullAddress: 'Riyadh, King Fahd Road',
    phone: '0500000000',
    isDefault: true,
  );

  const totals = CheckoutTotals(
    subtotal: 100,
    discount: 10,
    shippingFee: 12,
    codFee: 10,
    total: 112,
  );

  setUpAll(() {
    registerFallbackValue(fakeOrder());
    registerFallbackValue(
      NotificationEntity(
        id: 'fallback',
        type: NotificationType.general,
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    placeOrder = MockPlaceOrderUseCase();
    addNotification = MockAddNotificationUseCase();
    clearCart = MockClearCartUseCase();
  });

  CheckoutCubit buildCubit() => CheckoutCubit(
    placeOrderUseCase: placeOrder,
    addNotificationUseCase: addNotification,
    clearCartUseCase: clearCart,
  );

  Future<Either<Failure, OrderEntity>> submit(CheckoutCubit cubit) {
    return cubit.submit(
      items: [fakeCartItem(price: 100)],
      totals: totals,
      address: address,
      addressLabel: 'Home',
      deliveryMethod: 'standard',
      paymentMethod: 'cod',
      courierNote: 'Ring the bell',
      promoCode: 'RAFF10',
    );
  }

  test('a failed order does not notify or clear the cart', () async {
    when(() => placeOrder(any()))
        .thenAnswer((_) async => const Left(UnknownFailure()));

    final cubit = buildCubit();
    addTearDown(cubit.close);
    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const CheckoutSubmitting(),
        const CheckoutFailure(UnknownFailure()),
      ]),
    );

    final result = await submit(cubit);

    expect(result, const Left<Failure, OrderEntity>(UnknownFailure()));
    await states;
    verifyNever(() => addNotification(any()));
    verifyNever(() => clearCart());
  });

  test('a successful order is saved before notifying and clearing', () async {
    NotificationEntity? capturedNotification;

    when(() => placeOrder(any())).thenAnswer((_) async => Right([fakeOrder()]));
    when(() => addNotification(any())).thenAnswer((invocation) async {
      capturedNotification =
          invocation.positionalArguments.single as NotificationEntity;
      return const Right([]);
    });
    when(() => clearCart()).thenAnswer((_) async => const Right([]));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    final result = await submit(cubit);

    expect(result.isRight(), isTrue);
    final order = result.getOrElse(() => fakeOrder(id: 'missing'));
    final notification = capturedNotification!;

    expect(order.id, startsWith('RF-'));
    expect(order.status, OrderStatus.placed);
    expect(order.items.single.productId, 1);
    expect(order.items.single.quantity, 1);
    expect(order.subtotal, totals.subtotal);
    expect(order.discount, totals.discount);
    expect(order.shippingFee, totals.shippingFee);
    expect(order.codFee, totals.codFee);
    expect(order.total, totals.total);
    expect(order.promoCode, 'RAFF10');
    expect(order.addressLabel, 'Home');
    expect(order.addressFull, address.fullAddress);
    expect(order.deliveryMethod, 'standard');
    expect(order.paymentMethod, 'cod');
    expect(order.courierNote, 'Ring the bell');

    expect(notification.type, NotificationType.orderPlaced);
    expect(notification.orderId, order.id);
    expect(cubit.state, CheckoutSuccess(order));

    verifyInOrder([
      () => placeOrder(order),
      () => addNotification(notification),
      () => clearCart(),
    ]);
  });

  test('side-effect failures do not fail an already saved order', () async {
    when(() => placeOrder(any())).thenAnswer((_) async => Right([fakeOrder()]));
    when(() => addNotification(any()))
        .thenThrow(Exception('notification storage is unavailable'));
    when(() => clearCart())
        .thenAnswer((_) async => const Left(UnknownFailure()));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    final result = await submit(cubit);

    expect(result.isRight(), isTrue);
    expect(cubit.state, isA<CheckoutSuccess>());
    verify(() => clearCart()).called(1);
  });
}
