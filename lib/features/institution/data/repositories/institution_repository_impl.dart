import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/features/institution/data/datasources/institution_remote_data_source.dart';
import 'package:blog_app/features/institution/data/models/institution_model.dart';
import 'package:blog_app/features/institution/domain/entities/institution.dart';
import 'package:blog_app/features/institution/domain/repository/institution_repository.dart';
import 'package:fpdart/fpdart.dart';

class InstitutionRepositoryImpl implements InstitutionRepository {
  final InstitutionRemoteDataSource remoteDataSource;

  const InstitutionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Institution>> createInstitution(
    InstitutionModel institution,
  ) async {
    return _handle(() => remoteDataSource.createInstitution(institution));
  }

  @override
  Future<Either<Failure, List<Institution>>> getAllInstitutions() async {
    return _handle(() => remoteDataSource.getAllInstitutions());
  }

  Future<Either<Failure, T>> _handle<T>(Future<T> Function() fn) async {
    try {
      return right(await fn());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
