class Submission {
  final String id;
  final String deliverableId;
  final String groupId;
  final DateTime submittedAt;
  final String? archiveObjectName;
  final String? filename;
  final String? gitRepoUrl;
  final int? size;
  final bool isLate;
  final int penaltyApplied;

  Submission({
    required this.id,
    required this.deliverableId,
    required this.groupId,
    required this.submittedAt,
    this.archiveObjectName,
    this.filename,
    this.gitRepoUrl,
    this.size,
    required this.isLate,
    required this.penaltyApplied,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    int? parsedSize;
    final rawSize = json['size'];
    if (rawSize is int) {
      parsedSize = rawSize;
    } else if (rawSize is String) {
      parsedSize = int.tryParse(rawSize);
    } else {
      parsedSize = null;
    }
    return Submission(
      id: json['id'],
      deliverableId: json['deliverableId'],
      groupId: json['groupId'],
      submittedAt: DateTime.parse(json['submittedAt']),
      archiveObjectName: json['archiveObjectName'],
      filename: json['filename'],
      gitRepoUrl: json['gitRepoUrl'],
      size: parsedSize,
      isLate: json['isLate'] ?? false,
      penaltyApplied: json['penaltyApplied'] ?? 0,
    );
  }
}
