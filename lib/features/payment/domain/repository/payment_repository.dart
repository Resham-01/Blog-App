import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/features/payment/data/models/payment_account_model.dart';
import 'package:blog_app/features/payment/domain/entities/parent_child.dart';
import 'package:blog_app/features/payment/domain/entities/payment_account.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PaymentRepository {
  Future<Either<Failure, List<PaymentAccount>>> getAccountsByInstitution(
    String institutionId,
  );
  Future<Either<Failure, List<PaymentAccount>>> getAllAccounts();
  Future<Either<Failure, PaymentAccount>> submitAccount(
    PaymentAccountModel account,
  );
  Future<Either<Failure, PaymentAccount>> reviewAccount({
    required String accountId,
    required String reviewerId,
    required String status,
    String? reviewNote,
  });
  Future<Either<Failure, PaymentAccount>> activateAccount({
    required String accountId,
    required String reviewerId,
  });
  Future<Either<Failure, PaymentAccount?>> getActiveAccountForParent(
    String parentId,
  );
  Future<Either<Failure, List<ParentChild>>> getChildrenForParent(
    String parentId,
  );
}
