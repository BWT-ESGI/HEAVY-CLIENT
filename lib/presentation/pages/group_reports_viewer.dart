import '../../data/datasources/deliverable_remote_datasource.dart';
import '../../data/datasources/submission_remote_datasource.dart';
import '../../domain/entities/deliverable.dart';
import '../../domain/entities/submission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../data/datasources/report_remote_datasource.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/group.dart';
import '../../data/datasources/section_remote_datasource.dart';

class GroupReportsViewer extends StatefulWidget {
  final String projectId;
  const GroupReportsViewer({Key? key, required this.projectId}) : super(key: key);

  @override
  State<GroupReportsViewer> createState() => _GroupReportsViewerState();
}

class _GroupReportsViewerState extends State<GroupReportsViewer> {
  List<Deliverable> _deliverables = [];
  List<Submission> _submissions = [];
  List<Group> _groups = [];
  int _currentGroupIndex = 0;
  List<Report> _reports = [];
  bool _loadingGroups = true;
  bool _loadingReports = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() {
      _loadingGroups = true;
    });
    try {
      _groups = await GroupRemoteDatasource().fetchGroupsByProject(widget.projectId);
      _currentGroupIndex = 0;
      setState(() {
        _loadingGroups = false;
      });
      if (_groups.isNotEmpty) {
        _fetchReportsForCurrentGroup();
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur chargement groupes';
        _loadingGroups = false;
      });
    }
  }

  Future<void> _fetchReportsForCurrentGroup() async {
    if (_groups.isEmpty) return;
    setState(() {
      _loadingReports = true;
    });
    try {
      final groupId = _groups[_currentGroupIndex].id;
      final reports = await ReportRemoteDatasource().fetchReports(groupId: groupId);
      // Pour chaque rapport, récupérer les sections
      final List<Report> reportsWithSections = [];
      for (final report in reports) {
        final sections = await SectionRemoteDatasource().fetchSections(rapportId: report.id);
        reportsWithSections.add(Report(
          id: report.id,
          content: report.content,
          groupId: report.groupId,
          groupName: report.groupName,
          sections: sections,
        ));
      }
      _reports = reportsWithSections;
      setState(() {
        _loadingReports = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement rapports: $e');
      setState(() {
        _error = 'Erreur chargement rapports';
        _loadingReports = false;
      });
    }
  }

  void _goToPreviousGroup() async {
    if (_currentGroupIndex > 0) {
      setState(() {
        _currentGroupIndex--;
      });
      await _fetchReportsForCurrentGroup();
    }
  }

  void _goToNextGroup() async {
    if (_currentGroupIndex < _groups.length - 1) {
      setState(() {
        _currentGroupIndex++;
      });
      await _fetchReportsForCurrentGroup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _groups.isNotEmpty ? _groups[_currentGroupIndex] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loadingGroups)
          const Center(child: CircularProgressIndicator()),
        if (!_loadingGroups && _groups.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _currentGroupIndex > 0 ? _goToPreviousGroup : null,
              ),
              Text(
                group?.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _currentGroupIndex < _groups.length - 1 ? _goToNextGroup : null,
              ),
            ],
          ),
        if (_loadingReports)
          const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        if (!_loadingReports && !_loadingGroups && _groups.isNotEmpty)
          Expanded(
            child: (() {
              // Un rapport est considéré comme vide si aucune section ET contenu vide
              bool allReportsEmpty = _reports.isEmpty || _reports.every((r) => (r.sections.isEmpty && (r.content == null || r.content.trim().isEmpty)));
              if (allReportsEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, color: Colors.grey, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Aucun rapport n’a été rendu par ce groupe.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    // Si ce rapport est vide, on ne l'affiche pas
                    if (report.sections.isEmpty && (report.content == null || report.content.trim().isEmpty)) {
                      return const SizedBox.shrink();
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            ...report.sections.isNotEmpty
                                ? report.sections.map((section) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          section.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Html(data: section.content),
                                        const Divider(),
                                      ],
                                    ))
                                : [Html(data: report.content)],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            })(),
          ),
      ],
    );
  }
}
