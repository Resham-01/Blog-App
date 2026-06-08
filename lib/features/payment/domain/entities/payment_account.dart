import 'package:blog_app/core/enums/payment_account_status.dart';

class PaymentAccount {
  final String id;
  final String institutionId;
  final String institutionName;
  final String submittedBy;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? branchName;
  final String? paymentInstructions;
  final PaymentAccountStatus status;
  final bool isActive;
  final String? reviewNote;
  final DateTime createdAt;

  const PaymentAccount({
    required this.id,
    required this.institutionId,
    required this.institutionName,
    required this.submittedBy,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.branchName,
    this.paymentInstructions,
    required this.status,
    required this.isActive,
    this.reviewNote,
    required this.createdAt,
  });
}
