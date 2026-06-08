import 'package:blog_app/core/enums/institution_type.dart';
import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? institutionName,
    InstitutionType? institutionType,
    String? institutionId,
    String? childName,
    String? className,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  static const _profileSelect = '*, institutions(name)';

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException('Invalid email and password.');
      }

      return _fetchProfile(response.user!.id);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? institutionName,
    InstitutionType? institutionType,
    String? institutionId,
    String? childName,
    String? className,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw const ServerException(
          'Sign up failed. Please check your email and password.',
        );
      }

      final userId = response.user!.id;
      String? resolvedInstitutionId = institutionId;

      if (role.isInstitutionAdmin) {
        if (institutionName == null || institutionType == null) {
          throw const ServerException(
            'Institution name and type are required.',
          );
        }

        final institution = await supabaseClient
            .from('institutions')
            .insert({
              'name': institutionName,
              'type': institutionType.value,
              'contact_email': email,
            })
            .select()
            .single();

        resolvedInstitutionId = institution['id'] as String;
      }

      await supabaseClient.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'role': role.value,
        'institution_id': resolvedInstitutionId,
      });

      if (role == UserRole.parent) {
        if (resolvedInstitutionId == null ||
            childName == null ||
            childName.isEmpty) {
          throw const ServerException(
            'Institution and child name are required for parents.',
          );
        }

        await supabaseClient.from('parent_children').insert({
          'parent_id': userId,
          'institution_id': resolvedInstitutionId,
          'child_name': childName,
          'class_name': className,
        });
      }

      return _fetchProfile(userId);
    } on AuthException catch (e) {
      final message = e.message.toLowerCase().contains('rate limit')
          ? 'Too many signup emails were sent. Wait about an hour, then try again.'
          : e.message;
      throw ServerException(message);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<UserModel> _fetchProfile(String userId) async {
    final profile = await supabaseClient
        .from('profiles')
        .select(_profileSelect)
        .eq('id', userId)
        .maybeSingle();

    if (profile == null) {
      throw const ServerException(
        'Profile not found. Contact super admin to set up your account.',
      );
    }

    return UserModel.fromProfileJson(profile);
  }
}
