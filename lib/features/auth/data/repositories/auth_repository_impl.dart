import 'package:blog_app/core/enums/institution_type.dart';
import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(() => remoteDataSource.loginWithEmailPassword(
          email: email,
          password: password,
        ));
  }

  @override
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
  }) async {
    return _getUser(() => remoteDataSource.signUpWithEmailPassword(
          name: name,
          email: email,
          password: password,
          role: role,
          institutionName: institutionName,
          institutionType: institutionType,
          institutionId: institutionId,
          childName: childName,
          className: className,
        ));
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      final user = await fn();
      return right(user);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
