import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/domain/repositories/addresses_repository.dart';

class UpdateAddressUseCase {
  final AddressesRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<Either<Failure, List<AddressEntity>>> call(AddressEntity address) {
    return repository.updateAddress(address);
  }
}
