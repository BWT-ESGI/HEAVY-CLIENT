import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReportRemoteDatasource {
  Future<List<Report>> fetchReports({required String groupId}) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('https://api-bwt.thomasgllt.fr/reports/by-group/$groupId');
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    debugPrint('Réponse API rapports: status=${response.statusCode}, body=${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      debugPrint("Erreur lors de la récupération des rapports: \\${response.statusCode} - \\${response.body}");
      throw Exception('Erreur lors du chargement des rapports');
    }
  }
}
