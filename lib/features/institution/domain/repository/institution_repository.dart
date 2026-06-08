import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/features/institution/data/models/institution_model.dart';
import 'package:blog_app/features/institution/domain/entities/institution.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class InstitutionRepository {
  Future<Either<Failure, Institution>> createInstitution(
    InstitutionModel institution,
  );
  Future<Either<Failure, List<Institution>>> getAllInstitutions();
}
