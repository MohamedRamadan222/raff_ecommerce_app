import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/domain/repositories/addresses_repository.dart';

class DeleteAddressUseCase {
  final AddressesRepository repository;

  DeleteAddressUseCase(this.repository);

  Future<Either<Failure, List<AddressEntity>>> call(String id) {
    return repository.deleteAddress(id);
  }
}
