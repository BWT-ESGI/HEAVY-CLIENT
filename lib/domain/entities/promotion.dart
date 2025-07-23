import 'project.dart';


class Promotion {
  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final List<String> studentNames;
  final List<Project> projects;

  Promotion({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.studentIds,
    required this.studentNames,
    required this.projects,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'],
        name: json['name'],
        teacherId: json['teacher'] is String
            ? json['teacher']
            : (json['teacher']?['id'] ?? ''),
        teacherName: json['teacher'] is String
            ? ''
            : (json['teacher']?['username'] ?? ''),
        studentIds: (json['students'] as List?)
                ?.map((s) => s is String ? s : (s['id'] ?? ''))
                .cast<String>()
                .toList() ??
            [],
        studentNames: (json['students'] as List?)
                ?.map((s) => s is String ? '' : (s['username'] ?? ''))
                .cast<String>()
                .toList() ??
            [],
        projects: (json['projects'] as List?)
                ?.map((p) => Project.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
