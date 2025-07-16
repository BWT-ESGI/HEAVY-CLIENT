import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SubmissionRemoteDatasource {
  Future<List<dynamic>> fetchSubmissionsByGroup(String groupId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('https://api-bwt.thomasgllt.fr/submissions/getByGroupId/$groupId'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des soumissions');
    }
  }

  Future<List<dynamic>> fetchRuleResultsBySubmission(String submissionId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('https://api-bwt.thomasgllt.fr/rule-results/submission/$submissionId'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des résultats de règles');
    }
  }
}
