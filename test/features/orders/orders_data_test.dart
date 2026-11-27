import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:raff_app/features/orders/data/models/order_model.dart';
import 'package:raff_app/features/orders/data/repositories/orders_repository_impl.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/hive_helper.dart';

class MockOrdersLocalDataSource extends Mock implements OrdersLocalDataSource {}

void main() {
  group('OrdersLocalDataSourceImpl (real Hive box)', () {
    late Box<String> box;
    late Directory dir;
    late OrdersLocalDataSourceImpl dataSource;

    setUp(() async {
      (box, dir) = await openTempBox('orders_test');
      dataSource = OrdersLocalDataSourceImpl(box);
    });

    tearDown(() => closeTempBox(box, dir));

    test('starts empty', () {
      expect(dataSource.getOrders(), isEmpty);
    });

    test('placeOrder saves the order and returns newest first', () async {
      final old = OrderModel.fromEntity(
        fakeOrder(
          id: 'old',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
      final recent = OrderModel.fromEntity(fakeOrder(id: 'new'));

      await dataSource.placeOrder(old);
      final result = await dataSource.placeOrder(recent);

      expect(result.map((o) => o.id), ['new', 'old']);
    });

    test(
      'placing an existing order id updates it without duplicating',
      () async {
        await dataSource.placeOrder(OrderModel.fromEntity(fakeOrder(id: 'a')));
        final result = await dataSource.placeOrder(
          OrderModel.fromEntity(
            fakeOrder(id: 'a', createdAt: DateTime(2026, 1, 1)),
          ),
        );

        expect(result, hasLength(1));
        expect(result.single.createdAt, DateTime(2026, 1, 1));
      },
    );

    test(
      'caps retained history at the newest 200 orders without duplicates',
      () async {
        const total = 205;
        final start = DateTime(2026, 1, 1);
        for (var i = 0; i < total; i++) {
          await dataSource.placeOrder(
            OrderModel.fromEntity(
              fakeOrder(
                id: 'order-$i',
                createdAt: start.add(Duration(minutes: i)),
              ),
            ),
          );
        }

        final orders = dataSource.getOrders();

        expect(orders, hasLength(200));
        expect(orders.map((o) => o.id).toSet(), hasLength(200));
        expect(orders.first.id, 'order-${total - 1}');
        expect(orders.last.id, 'order-${total - 200}');

        await dataSource.clearAll();

        expect(dataSource.getOrders(), isEmpty);
        expect(box.isEmpty, isTrue);
      },
    );

    test('the returned list is a copy that cannot change the cache', () async {
      await dataSource.placeOrder(OrderModel.fromEntity(fakeOrder(id: 'a')));

      final orders = dataSource.getOrders();

      expect(
        () => orders.add(OrderModel.fromEntity(fakeOrder(id: 'b'))),
        throwsUnsupportedError,
      );
      expect(dataSource.getOrders(), hasLength(1));
    });

    test('clearAll empties the box and the cache', () async {
      await dataSource.placeOrder(OrderModel.fromEntity(fakeOrder(id: 'a')));

      await dataSource.clearAll();

      expect(dataSource.getOrders(), isEmpty);
      expect(box.isEmpty, isTrue);
    });
  });

  group('OrdersRepositoryImpl', () {
    late MockOrdersLocalDataSource local;
    late OrdersRepositoryImpl repository;

    setUp(() {
      local = MockOrdersLocalDataSource();
      repository = OrdersRepositoryImpl(local);
    });

    test('getOrders returns Right with the saved orders', () {
      when(() => local.getOrders())
          .thenReturn([OrderModel.fromEntity(fakeOrder())]);

      final result = repository.getOrders();

      expect(result.isRight(), isTrue);
    });

    test('getOrders returns UnknownFailure when storage throws', () {
      when(() => local.getOrders()).thenThrow(Exception('broken'));

      expect(repository.getOrders(), const Left(UnknownFailure()));
    });
  });
}
