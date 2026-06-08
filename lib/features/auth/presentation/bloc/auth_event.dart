part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? institutionName;
  final InstitutionType? institutionType;
  final String? institutionId;
  final String? childName;
  final String? className;

  AuthSignUp({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.institutionName,
    this.institutionType,
    this.institutionId,
    this.childName,
    this.className,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({
    required this.email,
    required this.password,
  });
}
