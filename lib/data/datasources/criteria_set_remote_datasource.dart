import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/criteria_set.dart';

class CriteriaSetRemoteDatasource {
  static const _baseUrl = 'https://api-bwt.thomasgllt.fr';
  final FlutterSecureStorage storage;

  CriteriaSetRemoteDatasource(this.storage);

  Future<List<CriteriaSet>> getCriteriaSets({String? type}) async {
    final token = await storage.read(key: 'accessToken');
    final uri = Uri.parse('$_baseUrl/criteria-sets${type != null ? '?type=$type' : ''}');
    debugPrint('GET $uri');
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    debugPrint('Response: ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => CriteriaSet.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des grilles');
    }
  }

  Future<CriteriaSet> createCriteriaSet(CriteriaSet set) async {
    final token = await storage.read(key: 'accessToken');
    final uri = Uri.parse('$_baseUrl/criteria-sets');
    debugPrint('POST $uri');
    final res = await http.post(uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': set.title,
          'type': set.type,
          'weight': set.weight,
          'criteria': set.criteria.map((c) => c.toJson()).toList(),
          if (set.groupId != null) 'groupId': set.groupId,
        }));
    debugPrint('Response: ${res.statusCode} ${res.body}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = json.decode(res.body);
      return CriteriaSet.fromJson(data);
    } else {
      throw Exception('Erreur lors de la création de la grille');
    }
  }
}
