import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';

abstract class AddressesRepository {
  Either<Failure, List<AddressEntity>> getAddresses();

  Future<Either<Failure, List<AddressEntity>>> addAddress(
    AddressEntity address,
  );

  Future<Either<Failure, List<AddressEntity>>> updateAddress(
    AddressEntity address,
  );

  Future<Either<Failure, List<AddressEntity>>> deleteAddress(String id);

  Future<Either<Failure, List<AddressEntity>>> setDefaultAddress(String id);
}
