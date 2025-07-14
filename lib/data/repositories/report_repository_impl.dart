import '../../domain/entities/report.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl {
  final ReportRemoteDatasource datasource;

  ReportRepositoryImpl(this.datasource);

  Future<List<Report>> getReports({required String groupId}) {
    return datasource.fetchReports(groupId: groupId);
  }
}
