class ParentChild {
  final String id;
  final String parentId;
  final String institutionId;
  final String institutionName;
  final String childName;
  final String? className;

  const ParentChild({
    required this.id,
    required this.parentId,
    required this.institutionId,
    required this.institutionName,
    required this.childName,
    this.className,
  });
}
