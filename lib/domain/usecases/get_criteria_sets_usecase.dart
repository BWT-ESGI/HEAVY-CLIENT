import '../../data/repositories/criteria_set_repository.dart';
import '../entities/criteria_set.dart';

class GetCriteriaSetsUsecase {
  final CriteriaSetRepository repository;
  GetCriteriaSetsUsecase(this.repository);

  Future<List<CriteriaSet>> call({String? type}) {
    return repository.getCriteriaSets(type: type);
  }
}
