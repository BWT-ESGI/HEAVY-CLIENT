

import 'section.dart';

class Report {
  final String id;
  final String content;
  final String groupId;
  final String groupName;
  final List<Section> sections;

  Report({
    required this.id,
    required this.content,
    required this.groupId,
    required this.groupName,
    required this.sections,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      groupId: json['group'] != null && json['group']['id'] != null ? json['group']['id'].toString() : '',
      groupName: json['group'] != null && json['group']['name'] != null ? json['group']['name'] : '',
      sections: json['sections'] != null
          ? List<Section>.from((json['sections'] as List).map((s) => Section.fromJson(s)))
          : [],
    );
  }
}
