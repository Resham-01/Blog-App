enum InstitutionType {
  school('school'),
  college('college');

  final String value;
  const InstitutionType(this.value);

  static InstitutionType fromString(String value) {
    return InstitutionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InstitutionType.school,
    );
  }

  String get label => value[0].toUpperCase() + value.substring(1);
}
