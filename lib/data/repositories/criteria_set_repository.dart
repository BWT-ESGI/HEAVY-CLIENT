import '../datasources/criteria_set_remote_datasource.dart';
import '../../domain/entities/criteria_set.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CriteriaSetRepository {
  final CriteriaSetRemoteDatasource remote;

  CriteriaSetRepository(FlutterSecureStorage storage)
      : remote = CriteriaSetRemoteDatasource(storage);

  Future<List<CriteriaSet>> getCriteriaSets({String? type}) async {
    return await remote.getCriteriaSets(type: type);
  }

  Future<CriteriaSet> createCriteriaSet(CriteriaSet set) async {
    return await remote.createCriteriaSet(set);
  }
}
