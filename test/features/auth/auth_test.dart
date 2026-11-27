import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:raff_app/features/auth/data/datasources/login_remote_data_source.dart';
import 'package:raff_app/features/auth/data/models/user_model.dart';
import 'package:raff_app/features/auth/data/repositories/login_repository_impl.dart';
import 'package:raff_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginRemoteDataSource extends Mock implements LoginRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

const user = UserModel(
  id: 1,
  firstName: 'Mohamed',
  lastName: 'Ramadan',
  username: 'mohamed',
  email: 'm@test.com',
  token: 'abc',
);

void main() {
  setUpAll(() => registerFallbackValue(user));

  group('UserModel', () {
    test('fromJson reads accessToken as the token', () {
      final model = UserModel.fromJson({
        'id': 2,
        'firstName': 'A',
        'lastName': 'B',
        'username': 'ab',
        'accessToken': 'tok',
      });

      expect(model.token, 'tok');
      expect(model.fullName, 'A B');
    });

    test('fromJson uses empty defaults', () {
      final model = UserModel.fromJson({});

      expect(model.id, 0);
      expect(model.fullName, '');
      expect(model.email, isNull);
    });
  });

  group('LoginRepositoryImpl', () {
    late MockLoginRemoteDataSource remote;
    late MockAuthLocalDataSource local;
    late LoginRepositoryImpl repository;

    setUp(() {
      remote = MockLoginRemoteDataSource();
      local = MockAuthLocalDataSource();
      repository = LoginRepositoryImpl(remote, local);
    });

    test('a successful login caches the user and returns it', () async {
      when(() => remote.login('mohamed', '123')).thenAnswer((_) async => user);
      when(() => local.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.login('mohamed', '123');

      expect(result, const Right(user));
      verify(() => local.cacheUser(user)).called(1);
    });

    test(
      'a 400 response becomes a ServerFailure with the api message',
      () async {
        when(() => remote.login(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'auth/login'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: 'auth/login'),
              statusCode: 400,
              data: {'message': 'Invalid credentials'},
            ),
          ),
        );

        final result = await repository.login('x', 'y');

        expect(result, const Left(ServerFailure('Invalid credentials')));
        verifyNever(() => local.cacheUser(any()));
      },
    );

    test('no internet becomes NetworkFailure', () async {
      when(() => remote.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'auth/login'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(await repository.login('x', 'y'), const Left(NetworkFailure()));
    });

    test('a timeout becomes TimeoutFailure', () async {
      when(() => remote.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'auth/login'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(await repository.login('x', 'y'), const Left(TimeoutFailure()));
    });

    test('an unexpected error becomes UnknownFailure', () async {
      when(() => remote.login(any(), any())).thenThrow(Exception('oops'));

      expect(await repository.login('x', 'y'), const Left(UnknownFailure()));
    });
  });

  group('LoginCubit', () {
    late MockLoginUseCase useCase;

    setUp(() => useCase = MockLoginUseCase());

    blocTest<LoginCubit, LoginState>(
      'emits loading then success',
      build: () {
        when(() => useCase('mohamed', '123'))
            .thenAnswer((_) async => const Right(user));
        return LoginCubit(useCase);
      },
      act: (cubit) => cubit.login('mohamed', '123'),
      expect: () => [const LoginLoading(), const LoginSuccess(user)],
    );

    blocTest<LoginCubit, LoginState>(
      'emits loading then failure',
      build: () {
        when(() => useCase(any(), any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return LoginCubit(useCase);
      },
      act: (cubit) => cubit.login('a', 'b'),
      expect: () => [
        const LoginLoading(),
        const LoginFailure(NetworkFailure()),
      ],
    );
  });

  group('AuthLocalDataSourceImpl', () {
    late SharedPreferences prefs;
    late AuthLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = AuthLocalDataSourceImpl(prefs);
    });

    test('there is no cached user at first', () {
      expect(dataSource.getCacheUser(), isNull);
    });

    test('cacheUser saves the user and marks logged in', () async {
      await dataSource.cacheUser(user);

      expect(dataSource.getCacheUser(), user);
      expect(prefs.getBool('isLoggedIn'), isTrue);
      expect(prefs.getBool('isGuest'), isFalse);
    });

    test('clearUser removes the user and logs out', () async {
      await dataSource.cacheUser(user);

      await dataSource.clearUser();

      expect(dataSource.getCacheUser(), isNull);
      expect(prefs.getBool('isLoggedIn'), isFalse);
    });

    test('corrupt cached user data is ignored instead of crashing', () async {
      SharedPreferences.setMockInitialValues({
        'CACHED_USER_DATA': '{"id": broken json',
      });
      prefs = await SharedPreferences.getInstance();
      dataSource = AuthLocalDataSourceImpl(prefs);

      expect(dataSource.getCacheUser(), isNull);
    });
  });
}
