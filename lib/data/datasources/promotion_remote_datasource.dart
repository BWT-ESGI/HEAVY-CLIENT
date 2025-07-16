import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/promotion.dart';
import '../../domain/entities/project.dart';

class PromotionRemoteDatasource {
  Future<List<Promotion>> fetchPromotions() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final userId = await storage.read(key: 'userId');
    if (userId == null) {
      throw Exception('Aucun userId trouvé pour charger les promotions');
    }
    final response = await http.get(
      Uri.parse('https://api-bwt.thomasgllt.fr/promotions/user/$userId'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    debugPrint('Réponse API (status: \\${response.statusCode}):');
    try {
      final dynamic jsonBody = jsonDecode(response.body);
      // Supprimer la clé 'students' de chaque promotion si présente
      if (jsonBody is List) {
        for (final item in jsonBody) {
          item.remove('students');
        }
      }
      final String prettyJson = const JsonEncoder.withIndent('  ').convert(jsonBody);
      debugPrint(prettyJson);
    } catch (e) {
      debugPrint('Erreur lors du décodage JSON: \\${e.toString()}');
      debugPrint('Body brut: \\${response.body}');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Promotion(
                id: e['id'],
                name: e['name'],
                teacherId: e['teacher'] is String
                    ? e['teacher']
                    : (e['teacher']?['id'] ?? ''),
                teacherName: e['teacher'] is String
                    ? ''
                    : (e['teacher']?['username'] ?? ''),
                studentIds: (e['students'] as List?)
                        ?.map((s) => s is String ? s : (s['id'] ?? ''))
                        .cast<String>()
                        .toList() ??
                    [],
                studentNames: (e['students'] as List?)
                        ?.map((s) => s is String ? '' : (s['username'] ?? ''))
                        .cast<String>()
                        .toList() ??
                    [],
                projects: (e['projects'] as List?)
                        ?.map((p) => Project(
                              id: p['id'],
                              name: p['name'],
                              description: p['description'],
                              promotionId: p['promotion'] is String
                                  ? p['promotion']
                                  : (p['promotion']?['id'] ?? ''),
                              nbStudentsMinPerGroup: p['nbStudentsMinPerGroup'],
                              nbStudentsMaxPerGroup: p['nbStudentsMaxPerGroup'],
                              groupCompositionType:
                                  p['groupCompositionType'] ?? '',
                              nbGroups: p['nbGroups'],
                              status: p['status'] ?? '',
                            ))
                        .toList() ??
                    [],
              ))
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des promotions'
          ' : \\${response.statusCode} \\${response.reasonPhrase}');
    }
  }
}
