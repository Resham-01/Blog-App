import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:blog_app/features/dashboard/presentation/widgets/payment_account_card.dart';
import 'package:blog_app/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  final User user;

  const SuperAdminDashboardPage({super.key, required this.user});

  static Route<void> route({required User user}) {
    return MaterialPageRoute(
      builder: (_) => SuperAdminDashboardPage(user: user),
    );
  }

  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadAllAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
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
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentAccountsLoaded) {
            if (state.accounts.isEmpty) {
              return const Center(
                child: Text(
                  'No payment accounts submitted yet.\n'
                  'Schools and colleges will submit from their dashboards.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Manage Payment Accounts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Each institution has its own payment account. '
                  'Approve and activate one account per school/college for parents.',
                ),
                const SizedBox(height: 16),
                ...state.accounts.map(
                  (account) => PaymentAccountCard(
                    account: account,
                    onApprove: () {
                      context.read<PaymentBloc>().add(
                            ReviewPaymentAccount(
                              accountId: account.id,
                              reviewerId: widget.user.id,
                              status: 'approved',
                            ),
                          );
                    },
                    onReject: () {
                      context.read<PaymentBloc>().add(
                            ReviewPaymentAccount(
                              accountId: account.id,
                              reviewerId: widget.user.id,
                              status: 'rejected',
                              reviewNote: 'Rejected by super admin',
                            ),
                          );
                    },
                    onActivate: () {
                      context.read<PaymentBloc>().add(
                            ActivatePaymentAccount(
                              accountId: account.id,
                              reviewerId: widget.user.id,
                            ),
                          );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
