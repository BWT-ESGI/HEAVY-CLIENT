import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/deliverable.dart';

class DeliverableRemoteDatasource {
  Future<List<Deliverable>> fetchDeliverablesByProject(String projectId) async {
    debugPrint("Récupération des livrables pour le projet $projectId");

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse(
          'https://api-bwt.thomasgllt.fr/deliverables/by-project/$projectId'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Deliverable(
                id: e['id'],
                title: e['name'],
                description: e['description'],
                deadline: DateTime.parse(e['deadline']),
                submitted: e['submitted'] ?? false,
                isLate: e['isLate'] ?? false,
                similarityRate: e['similarityRate'] != null
                    ? (e['similarityRate'] as num).toDouble()
                    : null,
                isConform: e['isConform'] ?? false,
                allowLateSubmission: e['allowLateSubmission'] ?? false,
                penaltyPerHourLate: (e['penaltyPerHourLate'] ?? 0).toDouble(),
                submissionType: e['submissionType'] ?? '',
                maxSize: e['maxSize'] != null
                    ? (e['maxSize'] as num).toDouble()
                    : null,
                projectId: e['project'] is String
                    ? e['project']
                    : (e['project']?['id'] ?? ''),
              ))
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des livrables');
    }
  }
}
