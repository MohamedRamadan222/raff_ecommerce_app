import 'package:bloc/bloc.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:raff_app/features/auth/presentation/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;
  final SessionCubit? session;

  RegisterCubit(this.registerUseCase, {this.session})
    : super(RegisterInitial());

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
    if (isClosed) return;
    response.fold(
      (failure) {
        emit(RegisterFailure(failure));
      },
      (userEntity) {
        session?.setUser(userEntity);
        emit(RegisterSuccess(userEntity));
      },
    );
  }
}
