import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/institution/data/models/institution_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class InstitutionRemoteDataSource {
  Future<InstitutionModel> createInstitution(InstitutionModel institution);
  Future<List<InstitutionModel>> getAllInstitutions();
}

class InstitutionRemoteDataSourceImpl implements InstitutionRemoteDataSource {
  final SupabaseClient supabaseClient;

  InstitutionRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<InstitutionModel> createInstitution(
    InstitutionModel institution,
  ) async {
    try {
      final response = await supabaseClient
          .from('institutions')
          .insert(institution.toJson())
          .select()
          .single();

      return InstitutionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<InstitutionModel>> getAllInstitutions() async {
    try {
      final response = await supabaseClient
          .from('institutions')
          .select()
          .order('name');

      return (response as List)
          .map((item) => InstitutionModel.fromJson(item))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
