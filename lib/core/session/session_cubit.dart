import 'package:bloc/bloc.dart';
import 'package:raff_app/core/session/session_state.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthLocalDataSource _authLocalDataSource;

  SessionCubit(this._authLocalDataSource) : super(const SessionState());

  /// Restores the session from the locally cached auth flags and user.
  Future<void> restore() async {
    final cachedUser = _authLocalDataSource.getCacheUser();

    if (_authLocalDataSource.isLoggedIn && cachedUser != null) {
      emit(SessionState(status: SessionStatus.authenticated, user: cachedUser));
      return;
    }

    if (_authLocalDataSource.isGuest) {
      emit(const SessionState(status: SessionStatus.guest));
      return;
    }

    emit(const SessionState(status: SessionStatus.unauthenticated));
  }

  void setUser(UserEntity user) {
    emit(SessionState(status: SessionStatus.authenticated, user: user));
  }

  void setGuest() {
    emit(const SessionState(status: SessionStatus.guest));
  }

  void clear() {
    emit(const SessionState(status: SessionStatus.unauthenticated));
  }
}
