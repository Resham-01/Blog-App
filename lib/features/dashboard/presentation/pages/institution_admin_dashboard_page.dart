import 'package:blog_app/core/enums/payment_account_status.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:blog_app/features/payment/domain/entities/payment_account.dart';
import 'package:blog_app/features/dashboard/presentation/widgets/payment_account_card.dart';
import 'package:blog_app/features/payment/data/models/payment_account_model.dart';
import 'package:blog_app/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstitutionAdminDashboardPage extends StatefulWidget {
  final User user;

  const InstitutionAdminDashboardPage({super.key, required this.user});

  static Route<void> route({required User user}) {
    return MaterialPageRoute(
      builder: (_) => InstitutionAdminDashboardPage(user: user),
    );
  }

  @override
  State<InstitutionAdminDashboardPage> createState() =>
      _InstitutionAdminDashboardPageState();
}

class _InstitutionAdminDashboardPageState
    extends State<InstitutionAdminDashboardPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();
  final _branchController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user.institutionId != null) {
      context.read<PaymentBloc>().add(
            LoadInstitutionAccounts(
              institutionId: widget.user.institutionId!,
            ),
          );
    }
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _branchController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submitAccount() {
    if (widget.user.institutionId == null) return;
    if (!_formKey.currentState!.validate()) return;

    context.read<PaymentBloc>().add(
          SubmitPaymentAccount(
            account: PaymentAccountModel(
              id: '',
              institutionId: widget.user.institutionId!,
              institutionName: widget.user.institutionName ?? '',
              submittedBy: widget.user.id,
              accountHolderName: _accountHolderController.text.trim(),
              bankName: _bankNameController.text.trim(),
              accountNumber: _accountNumberController.text.trim(),
              ifscCode: _ifscController.text.trim().isEmpty
                  ? null
                  : _ifscController.text.trim(),
              upiId: _upiController.text.trim().isEmpty
                  ? null
                  : _upiController.text.trim(),
              branchName: _branchController.text.trim().isEmpty
                  ? null
                  : _branchController.text.trim(),
              paymentInstructions: _instructionsController.text.trim().isEmpty
                  ? null
                  : _instructionsController.text.trim(),
              status: PaymentAccountStatus.pending,
              isActive: false,
              createdAt: DateTime.now(),
            ),
          ),
        );

    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.institutionName ?? 'Institution'} Dashboard'),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PaymentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PaymentLoading;
          final accounts = state is PaymentAccountsLoaded
              ? state.accounts
              : const <PaymentAccount>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Submit Payment Account',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide your school/college bank details. '
                'Super admin will review and activate the account for parents.',
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField('Account Holder Name', _accountHolderController),
                    _buildField('Bank Name', _bankNameController),
                    _buildField('Account Number', _accountNumberController),
                    _buildField('IFSC Code', _ifscController, required: false),
                    _buildField('UPI ID', _upiController, required: false),
                    _buildField('Branch Name', _branchController, required: false),
                    _buildField(
                      'Payment Instructions',
                      _instructionsController,
                      required: false,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : _submitAccount,
                        child: Text(
                          isLoading ? 'Submitting...' : 'Submit to Super Admin',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Submitted Accounts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (accounts.isEmpty)
                const Text('No payment accounts submitted yet.')
              else
                ...accounts.map(
                  (account) => PaymentAccountCard(account: account),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }
}
