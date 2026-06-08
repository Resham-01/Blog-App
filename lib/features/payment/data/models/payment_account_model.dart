import 'package:blog_app/core/enums/payment_account_status.dart';
import 'package:blog_app/features/payment/domain/entities/payment_account.dart';

class PaymentAccountModel extends PaymentAccount {
  const PaymentAccountModel({
    required super.id,
    required super.institutionId,
    required super.institutionName,
    required super.submittedBy,
    required super.accountHolderName,
    required super.bankName,
    required super.accountNumber,
    super.ifscCode,
    super.upiId,
    super.branchName,
    super.paymentInstructions,
    required super.status,
    required super.isActive,
    super.reviewNote,
    required super.createdAt,
  });

  factory PaymentAccountModel.fromJson(Map<String, dynamic> map) {
    final institution = map['institutions'];
    return PaymentAccountModel(
      id: map['id'] ?? '',
      institutionId: map['institution_id'] ?? '',
      institutionName: institution is Map<String, dynamic>
          ? institution['name'] as String? ?? ''
          : map['institution_name'] as String? ?? '',
      submittedBy: map['submitted_by'] ?? '',
      accountHolderName: map['account_holder_name'] ?? '',
      bankName: map['bank_name'] ?? '',
      accountNumber: map['account_number'] ?? '',
      ifscCode: map['ifsc_code'],
      upiId: map['upi_id'],
      branchName: map['branch_name'],
      paymentInstructions: map['payment_instructions'],
      status: PaymentAccountStatus.fromString(map['status'] ?? 'pending'),
      isActive: map['is_active'] ?? false,
      reviewNote: map['review_note'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String institutionId,
    required String submittedBy,
  }) {
    return {
      'institution_id': institutionId,
      'submitted_by': submittedBy,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
      'branch_name': branchName,
      'payment_instructions': paymentInstructions,
    };
  }
}
