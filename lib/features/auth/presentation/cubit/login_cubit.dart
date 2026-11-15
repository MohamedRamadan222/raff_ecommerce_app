import 'package:bloc/bloc.dart';
import 'package:raff_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase useCase;

  LoginCubit(this.useCase) : super(LoginInitial());

  Future<void> login(String username, String password) async {
    emit(LoginLoading());
    final response = await useCase.call(username, password);
    response.fold(
      (failure) {
        emit(LoginFailure(failure));
      },
      (userEntity) {
        emit(LoginSuccess(userEntity));
      },
    );
  }
}
