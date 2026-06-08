import 'package:blog_app/core/enums/institution_type.dart';
import 'package:blog_app/features/institution/domain/entities/institution.dart';

class InstitutionModel extends Institution {
  const InstitutionModel({
    required super.id,
    required super.name,
    required super.type,
    super.address,
    super.contactEmail,
    super.contactPhone,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> map) {
    return InstitutionModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: InstitutionType.fromString(map['type'] ?? 'school'),
      address: map['address'],
      contactEmail: map['contact_email'],
      contactPhone: map['contact_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      'address': address,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
    };
  }
}
