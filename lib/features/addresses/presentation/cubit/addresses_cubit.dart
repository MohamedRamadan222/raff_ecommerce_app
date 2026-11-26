import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/domain/usecases/add_address_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/delete_address_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/get_addresses_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/set_default_address_use_case.dart';
import 'package:raff_app/features/addresses/domain/usecases/update_address_use_case.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;

  AddressesCubit({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
    required this.setDefaultAddressUseCase,
  }) : super(const AddressesState());

  void loadAddresses() {
    emit(state.copyWith(status: AddressesStatus.loading));

    final result = getAddressesUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(status: AddressesStatus.failure, failure: failure),
      ),
      (items) => emit(
        state.copyWith(
          status: AddressesStatus.success,
          addresses: items,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> addAddress(AddressEntity address) async {
    final result = await addAddressUseCase(address);
    _emitResult(result);
  }

  Future<void> updateAddress(AddressEntity address) async {
    final result = await updateAddressUseCase(address);
    _emitResult(result);
  }

  Future<void> deleteAddress(String id) async {
    final result = await deleteAddressUseCase(id);
    _emitResult(result);
  }

  Future<void> setDefault(String id) async {
    final result = await setDefaultAddressUseCase(id);
    _emitResult(result);
  }

  /// كل العمليات بترجع الليستة المحدثة، فجمعنا معالجتها في مكان واحد
  void _emitResult(Either<Failure, List<AddressEntity>> result) {
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: AddressesStatus.failure, failure: failure),
      ),
      (items) => emit(
        state.copyWith(
          status: AddressesStatus.success,
          addresses: items,
          clearFailure: true,
        ),
      ),
    );
  }
}
