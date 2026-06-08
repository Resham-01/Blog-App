import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:blog_app/features/dashboard/presentation/widgets/payment_account_card.dart';
import 'package:blog_app/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentDashboardPage extends StatefulWidget {
  final User user;

  const ParentDashboardPage({super.key, required this.user});

  static Route<void> route({required User user}) {
    return MaterialPageRoute(
      builder: (_) => ParentDashboardPage(user: user),
    );
  }

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(
          LoadParentPaymentInfo(parentId: widget.user.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ParentPaymentLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Welcome, ${widget.user.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Children',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (state.children.isEmpty)
                  const Text('No child linked to your account.')
                else
                  ...state.children.map(
                    (child) => Card(
                      child: ListTile(
                        title: Text(child.childName),
                        subtitle: Text(
                          '${child.institutionName}'
                          '${child.className != null ? ' • ${child.className}' : ''}',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Payment Account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use only this account to pay fees. '
                  'Each school/college has its own separate payment account.',
                ),
                const SizedBox(height: 12),
                if (state.activeAccount == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No active payment account yet. '
                        'Super admin has not activated your institution account.',
                      ),
                    ),
                  )
                else
                  PaymentAccountCard(account: state.activeAccount!),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
