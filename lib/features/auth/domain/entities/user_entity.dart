import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String? email;
  final String? phone;
  final String? token;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.email,
    this.phone,
    this.token,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    email,
    phone,
    token,
  ];
}
