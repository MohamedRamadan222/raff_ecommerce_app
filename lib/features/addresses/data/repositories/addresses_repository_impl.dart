import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/data/datasources/addresses_local_data_source.dart';
import 'package:raff_app/features/addresses/data/models/address_model.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/domain/repositories/addresses_repository.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesLocalDataSource localDataSource;

  AddressesRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, List<AddressEntity>> getAddresses() {
    try {
      return Right(localDataSource.getAddresses());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> addAddress(
    AddressEntity address,
  ) async {
    try {
      final model = AddressModel.fromEntity(address);
      return Right(await localDataSource.addAddress(model));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> updateAddress(
    AddressEntity address,
  ) async {
    try {
      final model = AddressModel.fromEntity(address);
      return Right(await localDataSource.updateAddress(model));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> deleteAddress(String id) async {
    try {
      return Right(await localDataSource.deleteAddress(id));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> setDefaultAddress(
    String id,
  ) async {
    try {
      return Right(await localDataSource.setDefaultAddress(id));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
