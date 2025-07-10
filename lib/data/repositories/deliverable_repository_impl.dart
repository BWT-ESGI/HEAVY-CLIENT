import '../../domain/entities/deliverable.dart';
import '../datasources/deliverable_remote_datasource.dart';

class DeliverableRepositoryImpl {
  final DeliverableRemoteDatasource datasource;

  DeliverableRepositoryImpl(this.datasource);

  Future<List<Deliverable>> getDeliverablesByPromotionAndProject(
      String promotionId, String projectId) {
    return datasource.fetchDeliverablesByProject(projectId);
  }
}
