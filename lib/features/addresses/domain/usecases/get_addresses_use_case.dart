import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/domain/repositories/addresses_repository.dart';

class GetAddressesUseCase {
  final AddressesRepository repository;

  GetAddressesUseCase(this.repository);

  Either<Failure, List<AddressEntity>> call() {
    return repository.getAddresses();
  }
}
