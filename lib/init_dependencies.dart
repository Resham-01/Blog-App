import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/institution/data/datasources/institution_remote_data_source.dart';
import 'package:blog_app/features/institution/data/repositories/institution_repository_impl.dart';
import 'package:blog_app/features/institution/domain/repository/institution_repository.dart';
import 'package:blog_app/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:blog_app/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:blog_app/features/payment/domain/repository/payment_repository.dart';
import 'package:blog_app/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/secrets/app_secrets.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton<SupabaseClient>(() => supabase.client);
  _initAuth();
  _initInstitution();
  _initPayment();
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator<AuthRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserSignUp(
      serviceLocator<AuthRepository>(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserLogin(
      serviceLocator<AuthRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator<UserSignUp>(),
      userLogin: serviceLocator<UserLogin>(),
    ),
  );
}

void _initInstitution() {
  serviceLocator.registerFactory<InstitutionRemoteDataSource>(
    () => InstitutionRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerFactory<InstitutionRepository>(
    () => InstitutionRepositoryImpl(
      serviceLocator<InstitutionRemoteDataSource>(),
    ),
  );
}

void _initPayment() {
  serviceLocator.registerFactory<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerFactory<PaymentRepository>(
    () => PaymentRepositoryImpl(
      serviceLocator<PaymentRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory(
    () => PaymentBloc(
      paymentRepository: serviceLocator<PaymentRepository>(),
    ),
  );
}
