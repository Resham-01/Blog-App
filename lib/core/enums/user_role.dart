enum UserRole {
  superAdmin('super_admin'),
  schoolAdmin('school_admin'),
  collegeAdmin('college_admin'),
  parent('parent');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.parent,
    );
  }

  bool get isInstitutionAdmin =>
      this == UserRole.schoolAdmin || this == UserRole.collegeAdmin;
}
