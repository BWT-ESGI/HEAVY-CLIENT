import '../../data/repositories/evaluation_grid_repository.dart';
import '../entities/evaluation_grid.dart';

class SubmitEvaluationGridUsecase {
  final EvaluationGridRepository repository;
  SubmitEvaluationGridUsecase(this.repository);

  Future<void> call(EvaluationGrid grid) {
    return repository.submitEvaluationGrid(grid);
  }
}
