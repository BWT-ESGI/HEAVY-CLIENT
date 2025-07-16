import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/section.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SectionRemoteDatasource {
  Future<List<Section>> fetchSections({required String rapportId}) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('https://api-bwt.thomasgllt.fr/reports/$rapportId/sections');
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    debugPrint('Réponse API (api-bwt.thomasgllt.fr/reports/$rapportId/sections): status=${response.statusCode}, \nbody=${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Section.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des sections');
    }
  }
}
