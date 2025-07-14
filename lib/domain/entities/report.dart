
class Report {
  final String id;
  final String title;
  final String content;
  final String groupName;

  Report({
    required this.id,
    required this.title,
    required this.content,
    required this.groupName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      groupName: json['groupName'] ?? '',
    );
  }
}
