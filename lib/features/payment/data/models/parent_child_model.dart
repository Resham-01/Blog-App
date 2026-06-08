import 'package:blog_app/features/payment/domain/entities/parent_child.dart';

class ParentChildModel extends ParentChild {
  const ParentChildModel({
    required super.id,
    required super.parentId,
    required super.institutionId,
    required super.institutionName,
    required super.childName,
    super.className,
  });

  factory ParentChildModel.fromJson(Map<String, dynamic> map) {
    final institution = map['institutions'];
    return ParentChildModel(
      id: map['id'] ?? '',
      parentId: map['parent_id'] ?? '',
      institutionId: map['institution_id'] ?? '',
      institutionName: institution is Map<String, dynamic>
          ? institution['name'] as String? ?? ''
          : '',
      childName: map['child_name'] ?? '',
      className: map['class_name'],
    );
  }
}
