import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/group.dart';

class GroupRemoteDatasource {
  Future<List<Group>> fetchGroupsByProject(String projectId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('https://api-bwt.thomasgllt.fr/groups?projectId=$projectId'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Group(
                id: e['id'],
                name: e['name'],
                leaderId: e['leader'] is String
                    ? e['leader']
                    : (e['leader']?['id'] ?? null),
                leaderName: e['leader'] is String
                    ? ''
                    : (e['leader']?['username'] ?? ''),
                projectId: e['project'] is String
                    ? e['project']
                    : (e['project']?['id'] ?? ''),
              ))
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des groupes');
    }
  }
}
