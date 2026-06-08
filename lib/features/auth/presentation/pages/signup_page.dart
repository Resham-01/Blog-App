import 'package:blog_app/core/enums/institution_type.dart';
import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/core/routing/dashboard_router.dart';
import 'package:blog_app/core/theme/app_pallete.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/auth/presentation/pages/login_page.dart';
import 'package:blog_app/features/auth/presentation/widgets/auth_field.dart';
import 'package:blog_app/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:blog_app/features/institution/domain/entities/institution.dart';
import 'package:blog_app/features/institution/domain/repository/institution_repository.dart';
import 'package:blog_app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final institutionNameController = TextEditingController();
  final childNameController = TextEditingController();
  final classNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.parent;
  InstitutionType _selectedInstitutionType = InstitutionType.school;
  List<Institution> _institutions = [];
  String? _selectedInstitutionId;
  bool _isSubmitting = false;
  bool _loadingInstitutions = true;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    final result = await serviceLocator<InstitutionRepository>().getAllInstitutions();
    result.fold(
      (_) => setState(() => _loadingInstitutions = false),
      (institutions) => setState(() {
        _institutions = institutions;
        _loadingInstitutions = false;
      }),
    );
  }

  void _handleSignUp() {
    if (_isSubmitting) return;
    if (!formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    context.read<AuthBloc>().add(
          AuthSignUp(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            role: _selectedRole,
            institutionName: _selectedRole.isInstitutionAdmin
                ? institutionNameController.text.trim()
                : null,
            institutionType: _selectedRole.isInstitutionAdmin
                ? _selectedInstitutionType
                : null,
            institutionId: _selectedRole == UserRole.parent
                ? _selectedInstitutionId
                : null,
            childName: _selectedRole == UserRole.parent
                ? childNameController.text.trim()
                : null,
            className: _selectedRole == UserRole.parent
                ? (classNameController.text.trim().isEmpty
                    ? null
                    : classNameController.text.trim())
                : null,
          ),
        );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    institutionNameController.dispose();
    childNameController.dispose();
    classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthSuccess) {
            setState(() => _isSubmitting = false);
            DashboardRouter.navigate(context, state.user);
          }
        },
        builder: (context, state) {
          final isLoading = _isSubmitting || state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Register As'),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.parent,
                        child: Text('Parent'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.schoolAdmin,
                        child: Text('School Admin'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.collegeAdmin,
                        child: Text('College Admin'),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (role) => setState(() {
                              _selectedRole = role!;
                              if (role == UserRole.schoolAdmin) {
                                _selectedInstitutionType = InstitutionType.school;
                              } else if (role == UserRole.collegeAdmin) {
                                _selectedInstitutionType = InstitutionType.college;
                              }
                            }),
                  ),
                  const SizedBox(height: 15),
                  AuthField(hintText: 'Name', controller: nameController),
                  const SizedBox(height: 15),
                  AuthField(hintText: 'Email', controller: emailController),
                  const SizedBox(height: 15),
                  AuthField(
                    hintText: 'Password',
                    controller: passwordController,
                    isObscureText: true,
                  ),
                  if (_selectedRole.isInstitutionAdmin) ...[
                    const SizedBox(height: 15),
                    AuthField(
                      hintText: 'Institution Name',
                      controller: institutionNameController,
                    ),
                  ],
                  if (_selectedRole == UserRole.parent) ...[
                    const SizedBox(height: 15),
                    if (_loadingInstitutions)
                      const CircularProgressIndicator()
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedInstitutionId,
                        decoration: const InputDecoration(
                          labelText: 'Child School / College',
                        ),
                        items: _institutions
                            .map(
                              (institution) => DropdownMenuItem(
                                value: institution.id,
                                child: Text(
                                  '${institution.name} (${institution.type.label})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: isLoading
                            ? null
                            : (value) =>
                                setState(() => _selectedInstitutionId = value),
                        validator: (value) =>
                            value == null ? 'Select an institution' : null,
                      ),
                    const SizedBox(height: 15),
                    AuthField(
                      hintText: 'Child Name',
                      controller: childNameController,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: classNameController,
                      decoration: const InputDecoration(
                        labelText: 'Class (optional)',
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  AuthGradientButton(
                    buttonText: isLoading ? 'Signing Up...' : 'Sign Up',
                    onPressed: isLoading ? () {} : _handleSignUp,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(context, LoginPage.route()),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an Account? ',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppPallete.gradient2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
