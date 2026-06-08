import 'package:blog_app/core/enums/institution_type.dart';
import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? institutionName,
    InstitutionType? institutionType,
    String? institutionId,
    String? childName,
    String? className,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
}
