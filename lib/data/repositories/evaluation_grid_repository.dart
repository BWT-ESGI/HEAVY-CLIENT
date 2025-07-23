import '../datasources/evaluation_grid_remote_datasource.dart';
import '../../domain/entities/evaluation_grid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EvaluationGridRepository {
  final EvaluationGridRemoteDatasource remote;

  EvaluationGridRepository(FlutterSecureStorage storage)
      : remote = EvaluationGridRemoteDatasource(storage);

  Future<EvaluationGrid> fetchEvaluationGrid({
    required String criteriaSetId,
    required String groupId,
    String? deliverableId,
    String? defenseId,
    String? reportId,
  }) async {
    return await remote.fetchEvaluationGrid(
      criteriaSetId: criteriaSetId,
      groupId: groupId,
      deliverableId: deliverableId,
      defenseId: defenseId,
      reportId: reportId,
    );
  }

  Future<void> submitEvaluationGrid(EvaluationGrid grid) async {
    await remote.submitEvaluationGrid(grid);
  }
}
