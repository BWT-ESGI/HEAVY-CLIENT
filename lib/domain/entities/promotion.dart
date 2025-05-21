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
}
