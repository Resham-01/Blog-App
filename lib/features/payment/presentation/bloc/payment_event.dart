part of 'payment_bloc.dart';

@immutable
sealed class PaymentEvent {
  const PaymentEvent();
}

final class LoadInstitutionAccounts extends PaymentEvent {
  final String institutionId;
  const LoadInstitutionAccounts({required this.institutionId});
}

final class LoadAllAccounts extends PaymentEvent {
  const LoadAllAccounts();
}

final class SubmitPaymentAccount extends PaymentEvent {
  final PaymentAccountModel account;
  const SubmitPaymentAccount({required this.account});
}

final class ReviewPaymentAccount extends PaymentEvent {
  final String accountId;
  final String reviewerId;
  final String status;
  final String? reviewNote;
  const ReviewPaymentAccount({
    required this.accountId,
    required this.reviewerId,
    required this.status,
    this.reviewNote,
  });
}

final class ActivatePaymentAccount extends PaymentEvent {
  final String accountId;
  final String reviewerId;
  const ActivatePaymentAccount({
    required this.accountId,
    required this.reviewerId,
  });
}

final class LoadParentPaymentInfo extends PaymentEvent {
  final String parentId;
  const LoadParentPaymentInfo({required this.parentId});
}
