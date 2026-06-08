import 'package:blog_app/features/payment/data/models/payment_account_model.dart';
import 'package:blog_app/features/payment/domain/entities/parent_child.dart';
import 'package:blog_app/features/payment/domain/entities/payment_account.dart';
import 'package:blog_app/features/payment/domain/repository/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<LoadInstitutionAccounts>(_onLoadInstitutionAccounts);
    on<LoadAllAccounts>(_onLoadAllAccounts);
    on<SubmitPaymentAccount>(_onSubmitPaymentAccount);
    on<ReviewPaymentAccount>(_onReviewPaymentAccount);
    on<ActivatePaymentAccount>(_onActivatePaymentAccount);
    on<LoadParentPaymentInfo>(_onLoadParentPaymentInfo);
  }

  Future<void> _onLoadInstitutionAccounts(
    LoadInstitutionAccounts event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentRepository.getAccountsByInstitution(
      event.institutionId,
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (accounts) => emit(PaymentAccountsLoaded(accounts)),
    );
  }

  Future<void> _onLoadAllAccounts(
    LoadAllAccounts event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentRepository.getAllAccounts();
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (accounts) => emit(PaymentAccountsLoaded(accounts)),
    );
  }

  Future<void> _onSubmitPaymentAccount(
    SubmitPaymentAccount event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentRepository.submitAccount(event.account);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) {
        emit(const PaymentActionSuccess('Payment account submitted for review.'));
        add(LoadInstitutionAccounts(institutionId: event.account.institutionId));
      },
    );
  }

  Future<void> _onReviewPaymentAccount(
    ReviewPaymentAccount event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentRepository.reviewAccount(
      accountId: event.accountId,
      reviewerId: event.reviewerId,
      status: event.status,
      reviewNote: event.reviewNote,
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) {
        emit(PaymentActionSuccess(
          event.status == 'approved'
              ? 'Payment account approved.'
              : 'Payment account rejected.',
        ));
        add(const LoadAllAccounts());
      },
    );
  }

  Future<void> _onActivatePaymentAccount(
    ActivatePaymentAccount event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentRepository.activateAccount(
      accountId: event.accountId,
      reviewerId: event.reviewerId,
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) {
        emit(const PaymentActionSuccess(
          'Payment account is now active for parents.',
        ));
        add(const LoadAllAccounts());
      },
    );
  }

  Future<void> _onLoadParentPaymentInfo(
    LoadParentPaymentInfo event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final childrenResult =
        await paymentRepository.getChildrenForParent(event.parentId);
    final accountResult =
        await paymentRepository.getActiveAccountForParent(event.parentId);

    childrenResult.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (children) {
        accountResult.fold(
          (failure) => emit(PaymentFailure(failure.message)),
          (account) => emit(ParentPaymentLoaded(
            children: children,
            activeAccount: account,
          )),
        );
      },
    );
  }
}
