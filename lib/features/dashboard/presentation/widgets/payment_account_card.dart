import 'package:blog_app/core/enums/payment_account_status.dart';
import 'package:blog_app/core/theme/app_pallete.dart';
import 'package:blog_app/features/payment/domain/entities/payment_account.dart';
import 'package:flutter/material.dart';

class PaymentAccountCard extends StatelessWidget {
  final PaymentAccount account;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onActivate;

  const PaymentAccountCard({
    super.key,
    required this.account,
    this.onApprove,
    this.onReject,
    this.onActivate,
  });

  Color _statusColor(PaymentAccountStatus status) {
    switch (status) {
      case PaymentAccountStatus.approved:
        return Colors.green;
      case PaymentAccountStatus.rejected:
        return AppPallete.errorColor;
      case PaymentAccountStatus.inactive:
        return AppPallete.greyColor;
      case PaymentAccountStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.institutionName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(account.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.isActive
                        ? 'Active'
                        : account.status.label,
                    style: TextStyle(color: _statusColor(account.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow('Account Holder', account.accountHolderName),
            _detailRow('Bank', account.bankName),
            _detailRow('Account Number', account.accountNumber),
            if (account.ifscCode != null)
              _detailRow('IFSC', account.ifscCode!),
            if (account.upiId != null) _detailRow('UPI ID', account.upiId!),
            if (account.branchName != null)
              _detailRow('Branch', account.branchName!),
            if (account.paymentInstructions != null)
              _detailRow('Instructions', account.paymentInstructions!),
            if (account.reviewNote != null)
              _detailRow('Review Note', account.reviewNote!),
            if (onApprove != null || onReject != null || onActivate != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (onApprove != null && account.status == PaymentAccountStatus.pending)
                    ElevatedButton(
                      onPressed: onApprove,
                      child: const Text('Approve'),
                    ),
                  if (onReject != null && account.status == PaymentAccountStatus.pending)
                    OutlinedButton(
                      onPressed: onReject,
                      child: const Text('Reject'),
                    ),
                  if (onActivate != null &&
                      account.status == PaymentAccountStatus.approved &&
                      !account.isActive)
                    FilledButton(
                      onPressed: onActivate,
                      child: const Text('Set Active for Parents'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: AppPallete.greyColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
