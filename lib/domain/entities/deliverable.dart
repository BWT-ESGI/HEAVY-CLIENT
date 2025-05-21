class Deliverable {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool submitted;
  final bool isLate;
  final double? similarityRate;
  final bool isConform;
  final bool allowLateSubmission;
  final double penaltyPerHourLate;
  final String submissionType;
  final double? maxSize;
  final String projectId;

  Deliverable({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.submitted,
    required this.isLate,
    this.similarityRate,
    required this.isConform,
    required this.allowLateSubmission,
    required this.penaltyPerHourLate,
    required this.submissionType,
    this.maxSize,
    required this.projectId,
  });
}
