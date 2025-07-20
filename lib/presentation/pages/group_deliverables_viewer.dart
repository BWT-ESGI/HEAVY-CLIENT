import 'package:flutter/material.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../data/datasources/deliverable_remote_datasource.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/deliverable.dart';
import '../../domain/entities/submission.dart';
import '../../data/datasources/submission_remote_datasource.dart';

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
  List<Submission> _submissions = [];
  // Map pour stocker la conformité de chaque soumission : submissionId -> bool (true = conforme)
  Map<String, bool> _conformityBySubmissionId = {};
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
      _submissions = [];
      _conformityBySubmissionId = {};
    });
    try {
      _deliverables = await DeliverableRemoteDatasource().fetchDeliverablesByProject(widget.projectId);
      // Récupérer les soumissions du groupe courant
      final submissionsRaw = await SubmissionRemoteDatasource().fetchSubmissionsByGroup(groupId);
      _submissions = submissionsRaw.map<Submission>((e) => Submission.fromJson(e)).toList();
      // Pour chaque soumission, charger la conformité
      for (final submission in _submissions) {
        try {
          final ruleResults = await SubmissionRemoteDatasource().fetchRuleResultsBySubmission(submission.id);
          final isConform = ruleResults.isNotEmpty && ruleResults.every((r) => r['passed'] == true);
          _conformityBySubmissionId[submission.id] = isConform;
        } catch (e) {
          _conformityBySubmissionId[submission.id] = false;
        }
      }
      setState(() {
        _loadingDeliverables = false;
      });
    } catch (e) {
      setState(() {
        debugPrint('group_deliverables_viewer.dart Erreur chargement livrables: $e');
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
                      // Trouver la soumission du groupe pour ce livrable (null safe)
                      final subList = _submissions.where((s) => s.deliverableId == d.id).toList();
                      final submission = subList.isNotEmpty ? subList.first : null;
                      IconData iconType;
                      if (d.submissionType.toLowerCase().contains('git')) {
                        iconType = Icons.code;
                      } else if (d.submissionType.toLowerCase().contains('archive')) {
                        iconType = Icons.archive;
                      } else {
                        iconType = Icons.description;
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: ListTile(
                          leading: Icon(iconType, size: 32),
                          title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.description),
                              const SizedBox(height: 4),
                              Text('Date limite : ${d.deadline.toLocal().toString().substring(0, 16)}'),
                              if (submission != null) ...[
                                Text('Rendu le : ${submission.submittedAt.toLocal().toString().substring(0, 16)}',
                                    style: TextStyle(color: submission.isLate ? Colors.orange : Colors.green)),
                                if (submission.isLate)
                                  const Text('En retard', style: TextStyle(color: Colors.orange)),
                                // Affichage conformité
                                if (_conformityBySubmissionId.containsKey(submission.id))
                                  Text(
                                    _conformityBySubmissionId[submission.id]! ? 'Conforme' : 'Non conforme',
                                    style: TextStyle(color: _conformityBySubmissionId[submission.id]! ? Colors.green : Colors.red),
                                  )
                                else
                                  const Text('Conformité inconnue', style: TextStyle(color: Colors.grey)),
                              ] else ...[
                                const Text('Non rendu', style: TextStyle(color: Colors.red)),
                              ],
                              if (d.similarityRate != null)
                                Text('Similarité: ${(d.similarityRate! * 100).toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
