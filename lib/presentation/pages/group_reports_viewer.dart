import 'package:flutter/material.dart';

import '../../data/datasources/report_remote_datasource.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/group.dart';

class GroupReportsViewer extends StatefulWidget {
  final String projectId;
  const GroupReportsViewer({Key? key, required this.projectId}) : super(key: key);

  @override
  State<GroupReportsViewer> createState() => _GroupReportsViewerState();
}

class _GroupReportsViewerState extends State<GroupReportsViewer> {
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
      _reports = await ReportRemoteDatasource().fetchReports(groupId: groupId);
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
            child: _reports.isEmpty
                ? const Center(child: Text('Aucun rapport pour ce groupe'))
                : ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return ListTile(
                        title: Text(report.title),
                        subtitle: Text(report.content),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
