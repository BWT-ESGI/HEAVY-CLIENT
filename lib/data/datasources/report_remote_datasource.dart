import '../../domain/entities/report.dart';

class ReportRemoteDatasource {
  Future<List<Report>> fetchReports() async {
    // TODO: Remplacer par un appel API réel
    await Future.delayed(const Duration(seconds: 1));
    return [
      Report(
        id: '1',
        title: 'Rapport Groupe A',
        content: '# Rapport du Groupe A\nContenu en markdown...',
        groupName: 'Groupe A',
      ),
      Report(
        id: '2',
        title: 'Rapport Groupe B',
        content: '# Rapport du Groupe B\nContenu en markdown...',
        groupName: 'Groupe B',
      ),
    ];
  }
}
