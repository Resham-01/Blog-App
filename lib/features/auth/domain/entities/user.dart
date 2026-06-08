import 'package:blog_app/core/enums/user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? institutionId;
  final String? institutionName;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.parent,
    this.institutionId,
    this.institutionName,
  });
}
