import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';

enum AddressesStatus { initial, loading, success, failure }

class AddressesState extends Equatable {
  final AddressesStatus status;
  final List<AddressEntity> addresses;
  final Failure? failure;

  const AddressesState({
    this.status = AddressesStatus.initial,
    this.addresses = const [],
    this.failure,
  });

  AddressEntity? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  AddressesState copyWith({
    AddressesStatus? status,
    List<AddressEntity>? addresses,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, addresses, failure];
}
