import 'package:bloc/bloc.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase useCase;
  final SessionCubit? session;

  LoginCubit(this.useCase, {this.session}) : super(LoginInitial());

  Future<void> login(String username, String password) async {
    emit(LoginLoading());
    final response = await useCase.call(username, password);
    if (isClosed) return;
    response.fold(
      (failure) {
        emit(LoginFailure(failure));
      },
      (userEntity) {
        session?.setUser(userEntity);
        emit(LoginSuccess(userEntity));
      },
    );
  }
}
