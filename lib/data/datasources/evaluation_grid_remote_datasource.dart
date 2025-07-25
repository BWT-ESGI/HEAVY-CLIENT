import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/evaluation_grid.dart';

class EvaluationGridRemoteDatasource {
  static const _baseUrl = 'https://api-bwt.thomasgllt.fr';
  final FlutterSecureStorage storage;

  EvaluationGridRemoteDatasource(this.storage);

  Future<EvaluationGrid> fetchEvaluationGrid({
    required String criteriaSetId,
    required String groupId,
    String? deliverableId,
    String? defenseId,
    String? reportId,
  }) async {
    final token = await storage.read(key: 'accessToken');
    final params = <String, String>{
      'criteriaSetId': criteriaSetId,
      'groupId': groupId,
      if (deliverableId != null) 'deliverableId': deliverableId,
      if (defenseId != null) 'defenseId': defenseId,
      if (reportId != null) 'reportId': reportId,
    };
    final uri = Uri.parse(_baseUrl + '/evaluation-grids?' + Uri(queryParameters: params).query);
    debugPrint('GET $uri');
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    debugPrint('Response: ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      if (res.body == null || res.body.isEmpty) {
        debugPrint('Réponse vide de l\'API (grille d\'évaluation)');
        // Retourne null ou gère le cas d'une grille absente
        return EvaluationGrid(
          id: null,
          criteriaSetId: criteriaSetId,
          groupId: groupId,
          filledBy: '',
          scores: {},
          comments: {}, projectId: '',
        );
      }
      final data = json.decode(res.body);
      return EvaluationGrid.fromJson(data);
    } else {
      throw Exception('Erreur lors de la récupération de la grille d\'évaluation');
    }
  }

  Future<void> submitEvaluationGrid(EvaluationGrid grid) async {
    final token = await storage.read(key: 'accessToken');
    final uri = Uri.parse('$_baseUrl/evaluation-grids');
    debugPrint('POST $uri');
    final body = {
      'criteriaSetId': grid.criteriaSetId,
      'groupId': grid.groupId,
      'filledBy': grid.filledBy,
      'scores': grid.scores,
      'comments': grid.comments,
      // projectId is required by backend
      'projectId': grid.projectId,
      if (grid.deliverableId != null) 'deliverableId': grid.deliverableId,
      if (grid.defenseId != null) 'defenseId': grid.defenseId,
      if (grid.reportId != null) 'reportId': grid.reportId,
    };
    debugPrint('Payload: ' + json.encode(body));
    final res = await http.post(uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
    debugPrint('Response: ${res.statusCode} ${res.body}');
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Erreur lors de la soumission de la grille d\'évaluation');
    }
  }
}
