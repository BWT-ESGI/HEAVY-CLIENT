import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/project.dart';
import 'auth_token_util.dart';

class ProjectRemoteDatasource {
  Future<List<Project>> fetchProjects(String promotionId) async {
    final token = await AuthTokenUtil.getToken();
    final response = await http.get(
      Uri.parse('https://api-bwt.thomasgllt.fr/projects?promotionId=$promotionId'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Project(
                id: e['id'],
                name: e['name'],
                description: e['description'],
                promotionId: e['promotion'] is String
                    ? e['promotion']
                    : (e['promotion']?['id'] ?? ''),
                nbStudentsMinPerGroup: e['nbStudentsMinPerGroup'],
                nbStudentsMaxPerGroup: e['nbStudentsMaxPerGroup'],
                groupCompositionType: e['groupCompositionType'] ?? '',
                nbGroups: e['nbGroups'],
                status: e['status'] ?? '',
              ))
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des projets');
    }
  }
}
