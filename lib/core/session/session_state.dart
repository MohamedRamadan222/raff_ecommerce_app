import 'package:equatable/equatable.dart';
import 'package:raff_app/features/auth/domain/entities/user_entity.dart';

enum SessionStatus { unknown, unauthenticated, guest, authenticated }

/// Single source of truth for who is currently using the app.
class SessionState extends Equatable {
  final SessionStatus status;
  final UserEntity? user;

  const SessionState({this.status = SessionStatus.unknown, this.user});

  /// Whether the current session may access non-public screens.
  bool get isAllowed =>
      status == SessionStatus.authenticated || status == SessionStatus.guest;

  bool get isGuest => status == SessionStatus.guest;

  bool get isAuthenticated => status == SessionStatus.authenticated;

  @override
  List<Object?> get props => [status, user];
}
