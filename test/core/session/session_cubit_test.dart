import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/session/session_cleaner.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/core/session/session_state.dart';
import 'package:raff_app/features/addresses/data/datasources/addresses_local_data_source.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:raff_app/features/auth/data/models/user_model.dart';
import 'package:raff_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:raff_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:raff_app/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:raff_app/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

class MockAddressesLocalDataSource extends Mock
    implements AddressesLocalDataSource {}

class MockOrdersLocalDataSource extends Mock implements OrdersLocalDataSource {}

class MockNotificationsLocalDataSource extends Mock
    implements NotificationsLocalDataSource {}

const user = UserModel(
  id: 1,
  firstName: 'Mohamed',
  lastName: 'Ramadan',
  username: 'mohamed',
  phone: '0500000000',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionCubit', () {
    late MockAuthLocalDataSource auth;

    setUp(() => auth = MockAuthLocalDataSource());

    blocTest<SessionCubit, SessionState>(
      'restore emits authenticated when a logged-in user is cached',
      build: () {
        when(() => auth.getCacheUser()).thenReturn(user);
        when(() => auth.isLoggedIn).thenReturn(true);
        when(() => auth.isGuest).thenReturn(false);
        return SessionCubit(auth);
      },
      act: (cubit) => cubit.restore(),
      expect: () => [
        const SessionState(status: SessionStatus.authenticated, user: user),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'restore emits guest when only the guest flag is set',
      build: () {
        when(() => auth.getCacheUser()).thenReturn(null);
        when(() => auth.isLoggedIn).thenReturn(false);
        when(() => auth.isGuest).thenReturn(true);
        return SessionCubit(auth);
      },
      act: (cubit) => cubit.restore(),
      expect: () => [const SessionState(status: SessionStatus.guest)],
    );

    blocTest<SessionCubit, SessionState>(
      'restore emits unauthenticated when nothing is cached',
      build: () {
        when(() => auth.getCacheUser()).thenReturn(null);
        when(() => auth.isLoggedIn).thenReturn(false);
        when(() => auth.isGuest).thenReturn(false);
        return SessionCubit(auth);
      },
      act: (cubit) => cubit.restore(),
      expect: () => [const SessionState(status: SessionStatus.unauthenticated)],
    );

    blocTest<SessionCubit, SessionState>(
      'setUser, setGuest and clear update the session state',
      build: () => SessionCubit(auth),
      act: (cubit) {
        cubit.setUser(user);
        cubit.setGuest();
        cubit.clear();
      },
      expect: () => [
        const SessionState(status: SessionStatus.authenticated, user: user),
        const SessionState(status: SessionStatus.guest),
        const SessionState(status: SessionStatus.unauthenticated),
      ],
    );
  });

  group('SessionCleaner', () {
    late MockCartLocalDataSource cart;
    late MockFavoritesLocalDataSource favorites;
    late MockAddressesLocalDataSource addresses;
    late MockOrdersLocalDataSource orders;
    late MockNotificationsLocalDataSource notifications;
    late MockAuthLocalDataSource auth;
    late SharedPreferences prefs;
    late SessionCleaner cleaner;

    setUp(() async {
      cart = MockCartLocalDataSource();
      favorites = MockFavoritesLocalDataSource();
      addresses = MockAddressesLocalDataSource();
      orders = MockOrdersLocalDataSource();
      notifications = MockNotificationsLocalDataSource();
      auth = MockAuthLocalDataSource();

      SharedPreferences.setMockInitialValues({
        'RECENT_SEARCH_QUERIES': ['old query'],
      });
      prefs = await SharedPreferences.getInstance();

      when(() => cart.clearAll()).thenAnswer((_) async {});
      when(() => favorites.clearAll()).thenAnswer((_) async {});
      when(() => addresses.clearAll()).thenAnswer((_) async {});
      when(() => orders.clearAll()).thenAnswer((_) async {});
      when(() => notifications.clearAll()).thenAnswer((_) async {});
      when(() => auth.clearUser()).thenAnswer((_) async {});

      cleaner = SessionCleaner(
        cartLocalDataSource: cart,
        favoritesLocalDataSource: favorites,
        addressesLocalDataSource: addresses,
        ordersLocalDataSource: orders,
        notificationsLocalDataSource: notifications,
        authLocalDataSource: auth,
        sharedPreferences: prefs,
      );
    });

    test('clearAll wipes every user-scoped store and the auth cache', () async {
      await cleaner.clearAll();

      verify(() => cart.clearAll()).called(1);
      verify(() => favorites.clearAll()).called(1);
      verify(() => addresses.clearAll()).called(1);
      verify(() => orders.clearAll()).called(1);
      verify(() => notifications.clearAll()).called(1);
      verify(() => auth.clearUser()).called(1);
      expect(prefs.getStringList('RECENT_SEARCH_QUERIES'), isNull);
    });

    test(
      'clearAll clears the disk image cache when a callback is wired',
      () async {
        var diskCacheClears = 0;
        final withDiskCache = SessionCleaner(
          cartLocalDataSource: cart,
          favoritesLocalDataSource: favorites,
          addressesLocalDataSource: addresses,
          ordersLocalDataSource: orders,
          notificationsLocalDataSource: notifications,
          authLocalDataSource: auth,
          sharedPreferences: prefs,
          clearDiskImageCache: () async => diskCacheClears++,
        );

        await withDiskCache.clearAll();

        expect(diskCacheClears, 1);
        verify(() => auth.clearUser()).called(1);
      },
    );

    test(
      'clearAll still signs the user out without a disk cache callback',
      () async {
        final noDiskCache = SessionCleaner(
          cartLocalDataSource: cart,
          favoritesLocalDataSource: favorites,
          addressesLocalDataSource: addresses,
          ordersLocalDataSource: orders,
          notificationsLocalDataSource: notifications,
          authLocalDataSource: auth,
          sharedPreferences: prefs,
          clearDiskImageCache: null,
        );

        await noDiskCache.clearAll();

        verify(() => auth.clearUser()).called(1);
        expect(prefs.getStringList('RECENT_SEARCH_QUERIES'), isNull);
      },
    );

    test('a failing disk cache clear does not abort logout', () async {
      final failingDiskCache = SessionCleaner(
        cartLocalDataSource: cart,
        favoritesLocalDataSource: favorites,
        addressesLocalDataSource: addresses,
        ordersLocalDataSource: orders,
        notificationsLocalDataSource: notifications,
        authLocalDataSource: auth,
        sharedPreferences: prefs,
        clearDiskImageCache: () async => throw StateError('disk full'),
      );

      await failingDiskCache.clearAll();

      verify(() => auth.clearUser()).called(1);
      expect(prefs.getStringList('RECENT_SEARCH_QUERIES'), isNull);
    });
  });
}
