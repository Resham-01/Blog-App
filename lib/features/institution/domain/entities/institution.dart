import 'package:blog_app/core/enums/institution_type.dart';

class Institution {
  final String id;
  final String name;
  final InstitutionType type;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;

  const Institution({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.contactEmail,
    this.contactPhone,
  });
}
