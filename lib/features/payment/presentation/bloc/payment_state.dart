part of 'payment_bloc.dart';

@immutable
sealed class PaymentState {
  const PaymentState();
}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentAccountsLoaded extends PaymentState {
  final List<PaymentAccount> accounts;
  const PaymentAccountsLoaded(this.accounts);
}

final class ParentPaymentLoaded extends PaymentState {
  final List<ParentChild> children;
  final PaymentAccount? activeAccount;
  const ParentPaymentLoaded({
    required this.children,
    required this.activeAccount,
  });
}

final class PaymentActionSuccess extends PaymentState {
  final String message;
  const PaymentActionSuccess(this.message);
}

final class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
}
