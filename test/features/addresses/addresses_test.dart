import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/data/datasources/addresses_local_data_source.dart';
import 'package:raff_app/features/addresses/data/models/address_model.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/domain/usecases/add_address_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/delete_address_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/get_addresses_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/set_default_address_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/update_address_use_case.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';

import '../../helpers/hive_helper.dart';

class MockGetAddressesUseCase extends Mock implements GetAddressesUseCase {}

class MockAddAddressUseCase extends Mock implements AddAddressUseCase {}

class MockUpdateAddressUseCase extends Mock implements UpdateAddressUseCase {}

class MockDeleteAddressUseCase extends Mock implements DeleteAddressUseCase {}

class MockSetDefaultAddressUseCase extends Mock
    implements SetDefaultAddressUseCase {}

const home = AddressEntity(
  id: 'a',
  label: AddressLabel.home,
  fullAddress: 'King Fahd Road, Riyadh',
  phone: '0500000000',
);
const work = AddressEntity(
  id: 'b',
  label: AddressLabel.work,
  fullAddress: 'Olaya Street, Riyadh',
  phone: '0511111111',
  isDefault: true,
);

void main() {
  group('AddressEntity', () {
    test('shortTitle is the first part before the comma', () {
      expect(home.shortTitle, 'King Fahd Road');
    });

    test('shortTitle also splits on the arabic comma', () {
      final address = home.copyWith(fullAddress: 'شارع التحرير، القاهرة');

      expect(address.shortTitle, 'شارع التحرير');
    });

    test(
      'shortTitle falls back to the full address when it starts with a comma',
      () {
        final address = home.copyWith(fullAddress: ', Riyadh');

        expect(address.shortTitle, ', Riyadh');
      },
    );
  });

  group('AddressesState.defaultAddress', () {
    test('returns the address marked as default', () {
      expect(
        const AddressesState(addresses: [home, work]).defaultAddress,
        work,
      );
    });

    test('falls back to the first address when none is default', () {
      expect(const AddressesState(addresses: [home]).defaultAddress, home);
    });

    test('is null for an empty list', () {
      expect(const AddressesState().defaultAddress, isNull);
    });
  });

  group('AddressModel', () {
    test('an unknown label becomes other', () {
      final model = AddressModel.fromJson({'id': 'x', 'label': 'old_value'});

      expect(model.label, AddressLabel.other);
      expect(model.fullAddress, '');
      expect(model.isDefault, isFalse);
    });

    test('toJson then fromJson keeps the data', () {
      final model = AddressModel.fromEntity(work);

      expect(AddressModel.fromJson(model.toJson()), model);
    });
  });

  group('AddressesCubit', () {
    late MockGetAddressesUseCase getAddresses;
    late MockAddAddressUseCase addAddress;
    late MockUpdateAddressUseCase updateAddress;
    late MockDeleteAddressUseCase deleteAddress;
    late MockSetDefaultAddressUseCase setDefault;

    setUpAll(() => registerFallbackValue(home));

    setUp(() {
      getAddresses = MockGetAddressesUseCase();
      addAddress = MockAddAddressUseCase();
      updateAddress = MockUpdateAddressUseCase();
      deleteAddress = MockDeleteAddressUseCase();
      setDefault = MockSetDefaultAddressUseCase();
    });

    AddressesCubit buildCubit() => AddressesCubit(
      getAddressesUseCase: getAddresses,
      addAddressUseCase: addAddress,
      updateAddressUseCase: updateAddress,
      deleteAddressUseCase: deleteAddress,
      setDefaultAddressUseCase: setDefault,
    );

    blocTest<AddressesCubit, AddressesState>(
      'loadAddresses emits loading then the addresses',
      build: () {
        when(() => getAddresses()).thenReturn(const Right([home]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadAddresses(),
      expect: () => const [
        AddressesState(status: AddressesStatus.loading),
        AddressesState(status: AddressesStatus.success, addresses: [home]),
      ],
    );

    blocTest<AddressesCubit, AddressesState>(
      'addAddress emits the updated list',
      build: () {
        when(() => addAddress(any()))
            .thenAnswer((_) async => const Right([home, work]));
        return buildCubit();
      },
      act: (cubit) => cubit.addAddress(work),
      expect: () => const [
        AddressesState(
          status: AddressesStatus.success,
          addresses: [home, work],
        ),
      ],
    );

    blocTest<AddressesCubit, AddressesState>(
      'deleteAddress emits failure when it fails',
      build: () {
        when(() => deleteAddress('a'))
            .thenAnswer((_) async => const Left(UnknownFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.deleteAddress('a'),
      expect: () => const [
        AddressesState(
          status: AddressesStatus.failure,
          failure: UnknownFailure(),
        ),
      ],
    );
  });

  group('AddressesLocalDataSourceImpl (real Hive box)', () {
    late Box<String> box;
    late Directory dir;
    late AddressesLocalDataSourceImpl dataSource;

    AddressModel model(String id, {bool isDefault = false}) => AddressModel(
      id: id,
      label: AddressLabel.home,
      fullAddress: 'Address $id',
      phone: '050',
      isDefault: isDefault,
    );

    setUp(() async {
      (box, dir) = await openTempBox('addresses_test');
      dataSource = AddressesLocalDataSourceImpl(box);
    });

    tearDown(() => closeTempBox(box, dir));

    test('the first saved address becomes the default', () async {
      final result = await dataSource.addAddress(model('1'));

      expect(result.single.isDefault, isTrue);
    });

    test('adding a new default removes the default from the old one', () async {
      await dataSource.addAddress(model('1'));
      final result = await dataSource.addAddress(model('2', isDefault: true));

      expect(result.where((a) => a.isDefault).map((a) => a.id), ['2']);
    });

    test('setDefaultAddress keeps exactly one default', () async {
      await dataSource.addAddress(model('1'));
      await dataSource.addAddress(model('2'));

      final result = await dataSource.setDefaultAddress('2');

      expect(result.where((a) => a.isDefault).map((a) => a.id), ['2']);
    });

    test('deleteAddress removes it', () async {
      await dataSource.addAddress(model('1'));

      final result = await dataSource.deleteAddress('1');

      expect(result, isEmpty);
    });

    test('a corrupted entry is skipped instead of crashing', () async {
      await dataSource.addAddress(model('1'));
      await box.put('bad', 'not json');

      expect(dataSource.getAddresses().map((a) => a.id), ['1']);
    });
  });
}
