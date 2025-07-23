
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

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'],
        name: json['name'],
        leaderId: json['leader'] is String
            ? json['leader']
            : (json['leader']?['id']),
        leaderName: json['leader'] is String
            ? ''
            : (json['leader']?['username'] ?? ''),
        projectId: json['project'] is String
            ? json['project']
            : (json['project']?['id'] ?? ''),
      );
}
