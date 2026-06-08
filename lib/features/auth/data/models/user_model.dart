import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.role,
    super.institutionId,
    super.institutionName,
  });

  factory UserModel.fromProfileJson(Map<String, dynamic> map) {
    final institution = map['institutions'];
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'parent'),
      institutionId: map['institution_id'],
      institutionName: institution is Map<String, dynamic>
          ? institution['name'] as String?
          : null,
    );
  }
}
