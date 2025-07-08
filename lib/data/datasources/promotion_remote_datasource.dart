import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/promotion.dart';
import '../../domain/entities/project.dart';
import 'auth_token_util.dart';

class PromotionRemoteDatasource {
  Future<List<Promotion>> fetchPromotions() async {
    final token = await AuthTokenUtil.getToken();
    final response = await http.get(
      Uri.parse('https://api-bwt.thomasgllt.fr/promotions'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
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
