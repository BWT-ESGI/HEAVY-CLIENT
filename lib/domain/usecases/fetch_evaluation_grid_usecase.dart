import '../../data/repositories/evaluation_grid_repository.dart';
import '../entities/evaluation_grid.dart';

class FetchEvaluationGridUsecase {
  final EvaluationGridRepository repository;
  FetchEvaluationGridUsecase(this.repository);

  Future<EvaluationGrid> call({
    required String criteriaSetId,
    required String groupId,
    String? deliverableId,
    String? defenseId,
    String? reportId,
  }) {
    return repository.fetchEvaluationGrid(
      criteriaSetId: criteriaSetId,
      groupId: groupId,
      deliverableId: deliverableId,
      defenseId: defenseId,
      reportId: reportId,
    );
  }
}
