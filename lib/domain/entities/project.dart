
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

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        promotionId: json['promotionId'] ?? '',
        nbStudentsMinPerGroup: json['nbStudentsMinPerGroup'],
        nbStudentsMaxPerGroup: json['nbStudentsMaxPerGroup'],
        groupCompositionType: json['groupCompositionType'] ?? '',
        nbGroups: json['nbGroups'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        endAt: json['endAt'] != null ? DateTime.parse(json['endAt']) : null,
        status: json['status'] ?? '',
      );
}
