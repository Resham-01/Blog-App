import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:blog_app/features/payment/data/models/payment_account_model.dart';
import 'package:blog_app/features/payment/domain/entities/parent_child.dart';
import 'package:blog_app/features/payment/domain/entities/payment_account.dart';
import 'package:blog_app/features/payment/domain/repository/payment_repository.dart';
import 'package:fpdart/fpdart.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  const PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PaymentAccount>>> getAccountsByInstitution(
    String institutionId,
  ) async {
    return _handle(() => remoteDataSource.getAccountsByInstitution(institutionId));
  }

  @override
  Future<Either<Failure, List<PaymentAccount>>> getAllAccounts() async {
    return _handle(() => remoteDataSource.getAllAccounts());
  }

  @override
  Future<Either<Failure, PaymentAccount>> submitAccount(
    PaymentAccountModel account,
  ) async {
    return _handle(() => remoteDataSource.submitAccount(account));
  }

  @override
  Future<Either<Failure, PaymentAccount>> reviewAccount({
    required String accountId,
    required String reviewerId,
    required String status,
    String? reviewNote,
  }) async {
    return _handle(() => remoteDataSource.reviewAccount(
          accountId: accountId,
          reviewerId: reviewerId,
          status: status,
          reviewNote: reviewNote,
        ));
  }

  @override
  Future<Either<Failure, PaymentAccount>> activateAccount({
    required String accountId,
    required String reviewerId,
  }) async {
    return _handle(() => remoteDataSource.activateAccount(
          accountId: accountId,
          reviewerId: reviewerId,
        ));
  }

  @override
  Future<Either<Failure, PaymentAccount?>> getActiveAccountForParent(
    String parentId,
  ) async {
    return _handle(() => remoteDataSource.getActiveAccountForParent(parentId));
  }

  @override
  Future<Either<Failure, List<ParentChild>>> getChildrenForParent(
    String parentId,
  ) async {
    return _handle(() => remoteDataSource.getChildrenForParent(parentId));
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
