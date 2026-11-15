import 'package:bloc/bloc.dart';
import 'package:raff_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:raff_app/features/auth/presentation/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit(this.registerUseCase) : super(RegisterInitial());

  Future<void> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    emit(RegisterLoading());
    final response = await registerUseCase.call(
      fullName: fullName,
      phone: phone,
      password: password,
      email: email,
    );
    response.fold(
      (failure) {
        emit(RegisterFailure(failure));
      },
      (userEntity) {
        emit(RegisterSuccess(userEntity));
      },
    );
  }
}
