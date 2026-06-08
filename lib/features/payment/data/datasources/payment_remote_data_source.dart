import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/payment/data/models/parent_child_model.dart';
import 'package:blog_app/features/payment/data/models/payment_account_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PaymentRemoteDataSource {
  Future<List<PaymentAccountModel>> getAccountsByInstitution(String institutionId);
  Future<List<PaymentAccountModel>> getAllAccounts();
  Future<PaymentAccountModel> submitAccount(PaymentAccountModel account);
  Future<PaymentAccountModel> reviewAccount({
    required String accountId,
    required String reviewerId,
    required String status,
    String? reviewNote,
  });
  Future<PaymentAccountModel> activateAccount({
    required String accountId,
    required String reviewerId,
  });
  Future<PaymentAccountModel?> getActiveAccountForParent(String parentId);
  Future<List<ParentChildModel>> getChildrenForParent(String parentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl(this.supabaseClient);

  static const _accountSelect =
      '*, institutions(name)';

  @override
  Future<List<PaymentAccountModel>> getAccountsByInstitution(
    String institutionId,
  ) async {
    try {
      final response = await supabaseClient
          .from('payment_accounts')
          .select(_accountSelect)
          .eq('institution_id', institutionId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => PaymentAccountModel.fromJson(item))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PaymentAccountModel>> getAllAccounts() async {
    try {
      final response = await supabaseClient
          .from('payment_accounts')
          .select(_accountSelect)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => PaymentAccountModel.fromJson(item))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentAccountModel> submitAccount(PaymentAccountModel account) async {
    try {
      final response = await supabaseClient
          .from('payment_accounts')
          .insert(account.toInsertJson(
            institutionId: account.institutionId,
            submittedBy: account.submittedBy,
          ))
          .select(_accountSelect)
          .single();

      return PaymentAccountModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentAccountModel> reviewAccount({
    required String accountId,
    required String reviewerId,
    required String status,
    String? reviewNote,
  }) async {
    try {
      final response = await supabaseClient
          .from('payment_accounts')
          .update({
            'status': status,
            'reviewed_by': reviewerId,
            'review_note': reviewNote,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', accountId)
          .select(_accountSelect)
          .single();

      return PaymentAccountModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentAccountModel> activateAccount({
    required String accountId,
    required String reviewerId,
  }) async {
    try {
      final response = await supabaseClient
          .from('payment_accounts')
          .update({
            'is_active': true,
            'status': 'approved',
            'reviewed_by': reviewerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', accountId)
          .select(_accountSelect)
          .single();

      return PaymentAccountModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentAccountModel?> getActiveAccountForParent(
    String parentId,
  ) async {
    try {
      final children = await supabaseClient
          .from('parent_children')
          .select('institution_id')
          .eq('parent_id', parentId);

      if ((children as List).isEmpty) return null;

      final institutionId = children.first['institution_id'] as String;

      final response = await supabaseClient
          .from('payment_accounts')
          .select(_accountSelect)
          .eq('institution_id', institutionId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return PaymentAccountModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParentChildModel>> getChildrenForParent(String parentId) async {
    try {
      final response = await supabaseClient
          .from('parent_children')
          .select('*, institutions(name)')
          .eq('parent_id', parentId);

      return (response as List)
          .map((item) => ParentChildModel.fromJson(item))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
