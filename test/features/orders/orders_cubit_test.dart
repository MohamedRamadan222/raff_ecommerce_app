import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:raff_app/features/orders/domain/usecases/place_order_use_case.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';

import '../../helpers/fixtures.dart';

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

class MockPlaceOrderUseCase extends Mock implements PlaceOrderUseCase {}

void main() {
  late MockGetOrdersUseCase getOrders;
  late MockPlaceOrderUseCase placeOrder;

  setUpAll(() => registerFallbackValue(fakeOrder()));

  setUp(() {
    getOrders = MockGetOrdersUseCase();
    placeOrder = MockPlaceOrderUseCase();
  });

  OrdersCubit buildCubit() =>
      OrdersCubit(getOrdersUseCase: getOrders, placeOrderUseCase: placeOrder);

  OrdersSuccess successState(OrdersCubit cubit) {
    final state = cubit.state;
    expect(state, isA<OrdersSuccess>());
    return state as OrdersSuccess;
  }

  OrderStatus statusAfter(Duration age) {
    final order = fakeOrder(createdAt: DateTime.now().subtract(age));
    when(() => getOrders()).thenReturn(Right([order]));
    final cubit = buildCubit()..loadOrders();
    return successState(cubit).orders.single.status;
  }

  group('loadOrders derives the status from the time since creation', () {
    test('a new order is placed', () {
      expect(statusAfter(const Duration(seconds: 5)), OrderStatus.placed);
    });

    test('after 30 seconds it is confirmed', () {
      expect(statusAfter(const Duration(seconds: 40)), OrderStatus.confirmed);
    });

    test('after 2 minutes it is shipped', () {
      expect(statusAfter(const Duration(minutes: 3)), OrderStatus.shipped);
    });

    test('after 5 minutes it is out for delivery', () {
      expect(
        statusAfter(const Duration(minutes: 6)),
        OrderStatus.outForDelivery,
      );
    });

    test('after 10 minutes it is delivered', () {
      expect(statusAfter(const Duration(minutes: 11)), OrderStatus.delivered);
    });

    test('a cancelled order never changes', () {
      final order = fakeOrder(
        status: OrderStatus.cancelled,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      when(() => getOrders()).thenReturn(Right([order]));

      final cubit = buildCubit()..loadOrders();

      expect(successState(cubit).orders.single.status, OrderStatus.cancelled);
    });
  });

  blocTest<OrdersCubit, OrdersState>(
    'loadOrders emits failure when reading fails',
    build: () {
      when(() => getOrders()).thenReturn(const Left(UnknownFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.loadOrders(),
    expect: () => [
      const OrdersLoading(),
      const OrdersFailure(UnknownFailure()),
    ],
  );

  group('ensureLoaded', () {
    test('loads orders when the state is initial', () {
      when(() => getOrders()).thenReturn(Right([fakeOrder()]));

      final cubit = buildCubit()..ensureLoaded();

      expect(cubit.state, isA<OrdersSuccess>());
      verify(() => getOrders()).called(1);
    });

    test('does not reload when orders are already loaded', () {
      when(() => getOrders()).thenReturn(Right([fakeOrder()]));

      buildCubit()
        ..ensureLoaded()
        ..ensureLoaded();

      verify(() => getOrders()).called(1);
    });
  });

  group('refreshStatuses', () {
    test('does nothing outside the success state', () {
      final cubit = buildCubit()..refreshStatuses();

      expect(cubit.state, const OrdersInitial());
      verifyNever(() => getOrders());
    });

    blocTest<OrdersCubit, OrdersState>(
      'emits a new success when a derived status changed',
      build: () => buildCubit(),
      seed: () => OrdersSuccess([
        fakeOrder(
          createdAt: DateTime.now().subtract(const Duration(seconds: 40)),
        ),
      ]),
      act: (cubit) => cubit.refreshStatuses(),
      expect: () => [
        isA<OrdersSuccess>().having(
          (state) => state.orders.single.status,
          'status',
          OrderStatus.confirmed,
        ),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'does not emit when nothing changed',
      build: () => buildCubit(),
      seed: () => OrdersSuccess([fakeOrder()]),
      act: (cubit) => cubit.refreshStatuses(),
      expect: () => const <OrdersState>[],
    );
  });

  test('reset returns to initial', () {
    when(() => getOrders()).thenReturn(Right([fakeOrder()]));

    final cubit = buildCubit()..loadOrders();
    cubit.reset();

    expect(cubit.state, const OrdersInitial());
  });

  blocTest<OrdersCubit, OrdersState>(
    'placeOrder emits success with the new list',
    build: () {
      when(() => placeOrder(any()))
          .thenAnswer((_) async => Right([fakeOrder()]));
      return buildCubit();
    },
    act: (cubit) => cubit.placeOrder(fakeOrder()),
    verify: (cubit) {
      expect(successState(cubit).orders.single.id, 'RF-1');
    },
  );

  blocTest<OrdersCubit, OrdersState>(
    'placeOrder emits failure when placing fails',
    build: () {
      when(() => placeOrder(any()))
          .thenAnswer((_) async => const Left(UnknownFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.placeOrder(fakeOrder()),
    expect: () => [const OrdersFailure(UnknownFailure())],
  );

  test('placeOrder does not emit after the cubit is closed', () async {
    when(() => placeOrder(any())).thenAnswer((_) async => Right([fakeOrder()]));

    final cubit = buildCubit();
    await cubit.close();
    await cubit.placeOrder(fakeOrder());
  });

  group('OrdersState', () {
    final current = fakeOrder(id: 'a', status: OrderStatus.shipped);
    final delivered = fakeOrder(id: 'b', status: OrderStatus.delivered);
    final cancelled = fakeOrder(id: 'c', status: OrderStatus.cancelled);
    final state = OrdersSuccess([current, delivered, cancelled]);

    test('splits current and past orders', () {
      expect(state.currentOrders, [current]);
      expect(state.pastOrders, [delivered, cancelled]);
    });

    test('orderById returns the order or null', () {
      expect(state.orderById('b'), delivered);
      expect(state.orderById('zzz'), isNull);
    });

    test('isEmpty reflects the orders list', () {
      expect(state.isEmpty, isFalse);
      expect(const OrdersSuccess([]).isEmpty, isTrue);
    });

    test('non-success states expose safe empty defaults', () {
      const initial = OrdersInitial();
      expect(initial.orders, isEmpty);
      expect(initial.currentOrders, isEmpty);
      expect(initial.pastOrders, isEmpty);
      expect(initial.orderById('b'), isNull);

      const failure = OrdersFailure(UnknownFailure());
      expect(failure.orders, isEmpty);
      expect(failure.currentOrders, isEmpty);
      expect(failure.pastOrders, isEmpty);
      expect(failure.orderById('b'), isNull);
    });
  });
}
