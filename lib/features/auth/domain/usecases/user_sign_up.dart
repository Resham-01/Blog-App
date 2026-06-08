import 'package:blog_app/core/enums/institution_type.dart';
import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
      institutionName: params.institutionName,
      institutionType: params.institutionType,
      institutionId: params.institutionId,
      childName: params.childName,
      className: params.className,
    );
  }
}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? institutionName;
  final InstitutionType? institutionType;
  final String? institutionId;
  final String? childName;
  final String? className;

  UserSignUpParams({
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
