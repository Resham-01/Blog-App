enum PaymentAccountStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  inactive('inactive');

  final String value;
  const PaymentAccountStatus(this.value);

  static PaymentAccountStatus fromString(String value) {
    return PaymentAccountStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentAccountStatus.pending,
    );
  }

  String get label => value[0].toUpperCase() + value.substring(1);
}
