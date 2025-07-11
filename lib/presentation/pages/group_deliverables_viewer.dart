import 'package:flutter/material.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../data/datasources/deliverable_remote_datasource.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/deliverable.dart';

class GroupDeliverablesViewer extends StatefulWidget {
  final String projectId;
  const GroupDeliverablesViewer({Key? key, required this.projectId}) : super(key: key);

  @override
  State<GroupDeliverablesViewer> createState() => _GroupDeliverablesViewerState();
}

class _GroupDeliverablesViewerState extends State<GroupDeliverablesViewer> {
  List<Group> _groups = [];
  int _currentGroupIndex = 0;
  List<Deliverable> _deliverables = [];
  bool _loadingGroups = true;
  bool _loadingDeliverables = false;
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
      if (_groups.isNotEmpty) {
        _currentGroupIndex = 0;
        await _fetchDeliverables(_groups[0].id);
      }
      setState(() {
        _loadingGroups = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur chargement groupes';
        _loadingGroups = false;
      });
    }
  }

  Future<void> _fetchDeliverables(String groupId) async {
    setState(() {
      _loadingDeliverables = true;
      _deliverables = [];
    });
    try {
      // On suppose que l'API retourne les livrables du groupe (sinon, filtrer côté client)
      _deliverables = await DeliverableRemoteDatasource().fetchDeliverablesByProject(widget.projectId);
      setState(() {
        _loadingDeliverables = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur chargement livrables';
        _loadingDeliverables = false;
      });
    }
  }

  void _goToPreviousGroup() async {
    if (_currentGroupIndex > 0) {
      setState(() {
        _currentGroupIndex--;
      });
      await _fetchDeliverables(_groups[_currentGroupIndex].id);
    }
  }

  void _goToNextGroup() async {
    if (_currentGroupIndex < _groups.length - 1) {
      setState(() {
        _currentGroupIndex++;
      });
      await _fetchDeliverables(_groups[_currentGroupIndex].id);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _groups[_currentGroupIndex].name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _currentGroupIndex < _groups.length - 1 ? _goToNextGroup : null,
              ),
            ],
          ),
        if (_loadingDeliverables)
          const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        if (!_loadingDeliverables && _groups.isNotEmpty)
          Expanded(
            child: _deliverables.isEmpty
                ? const Center(child: Text('Aucun livrable pour ce groupe'))
                : ListView.builder(
                    itemCount: _deliverables.length,
                    itemBuilder: (context, index) {
                      final d = _deliverables[index];
                      return ListTile(
                        title: Text(d.title),
                        subtitle: Text(d.description),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(d.submitted ? 'Soumis' : 'Non soumis',
                                style: TextStyle(
                                    color: d.submitted ? Colors.green : Colors.red)),
                            if (d.isLate)
                              const Text('En retard',
                                  style: TextStyle(color: Colors.orange)),
                            Text(d.isConform ? 'Conforme' : 'Non conforme',
                                style: TextStyle(
                                    color: d.isConform ? Colors.green : Colors.red)),
                            if (d.similarityRate != null)
                              Text('Similarité: ${(d.similarityRate! * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
