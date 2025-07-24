class EvaluationGrid {
  final String? id;
  final String criteriaSetId;
  final String groupId;
  final String projectId;
  final String filledBy;
  final Map<String, int> scores;
  final Map<String, String> comments;
  final String? deliverableId;
  final String? defenseId;
  final String? reportId;

  EvaluationGrid({
    this.id,
    required this.criteriaSetId,
    required this.groupId,
    required this.projectId,
    required this.filledBy,
    required this.scores,
    required this.comments,
    this.deliverableId,
    this.defenseId,
    this.reportId,
  });

  factory EvaluationGrid.fromJson(Map<String, dynamic> json) => EvaluationGrid(
        id: json['id']?.toString(),
        criteriaSetId: json['criteriaSetId'] ?? '',
        groupId: json['groupId'] ?? '',
        projectId: json['projectId'] ?? '',
        filledBy: json['filledBy'] ?? '',
        scores: Map<String, int>.from(json['scores'] ?? {}),
        comments: Map<String, String>.from(json['comments'] ?? {}),
        deliverableId: json['deliverableId']?.toString(),
        defenseId: json['defenseId']?.toString(),
        reportId: json['reportId']?.toString(),
      );
}
