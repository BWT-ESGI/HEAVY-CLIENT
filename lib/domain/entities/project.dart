class Project {
  final String id;
  final String name;
  final String? description;
  final String promotionId;
  final int? nbStudentsMinPerGroup;
  final int? nbStudentsMaxPerGroup;
  final String groupCompositionType;
  final int? nbGroups;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? endAt;
  final String status;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.promotionId,
    this.nbStudentsMinPerGroup,
    this.nbStudentsMaxPerGroup,
    required this.groupCompositionType,
    this.nbGroups,
    this.createdAt,
    this.updatedAt,
    this.endAt,
    required this.status,
  });
}
