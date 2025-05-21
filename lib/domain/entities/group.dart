class Group {
  final String id;
  final String name;
  final String? leaderId;
  final String? leaderName;
  final String projectId;

  Group({
    required this.id,
    required this.name,
    this.leaderId,
    this.leaderName,
    required this.projectId,
  });
}
