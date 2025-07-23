
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/criteria_set_repository.dart';
import '../../data/repositories/evaluation_grid_repository.dart';
import '../../data/datasources/promotion_remote_datasource.dart';
import '../../data/datasources/group_remote_datasource.dart';

// Utilisation des entités du domaine pour Promotion, Project, Group
import '../../domain/entities/promotion.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/criteria_set.dart';
import '../../domain/entities/evaluation_grid.dart';

class GradingSheetsPage extends StatefulWidget {
  const GradingSheetsPage({Key? key}) : super(key: key);

  @override
  State<GradingSheetsPage> createState() => _GradingSheetsPageState();
}

class _GradingSheetsPageState extends State<GradingSheetsPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Promotion? _selectedPromotion;
  Project? _selectedProject;
  Group? _selectedGroup;
  String _selectedCriteriaType = 'defense';
  List<Promotion> _promotions = [];
  List<Project> _projects = [];
  List<Group> _groups = [];
  int _currentGroupIndex = 0;
  List<CriteriaSet> _criteriaSets = [];
  CriteriaSet? _selectedCriteriaSet;
  EvaluationGrid? _evaluationGrid;
  bool _loadingPromos = true;
  bool _loadingProjects = false;
  bool _loadingGroups = false;
  bool _loadingCriteriaSets = false;
  bool _loadingGrid = false;
  String? _error;
  Map<String, int> _scores = {};
  Map<String, String> _comments = {};

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() { _loadingPromos = true; });
    try {
      _promotions = await PromotionRemoteDatasource().fetchPromotions();
      setState(() { _loadingPromos = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loadingPromos = false; });
    }
  }

  void _onPromotionSelected(Promotion? promo) {
    setState(() {
      _selectedPromotion = promo;
      _selectedProject = null;
      _projects = promo?.projects ?? [];
      _groups = [];
      _selectedGroup = null;
      _currentGroupIndex = 0;
      _criteriaSets = [];
      _selectedCriteriaSet = null;
      _evaluationGrid = null;
    });
  }

  void _onProjectSelected(Project? project) async {
    setState(() {
      _selectedProject = project;
      _groups = [];
      _selectedGroup = null;
      _currentGroupIndex = 0;
      _criteriaSets = [];
      _selectedCriteriaSet = null;
      _evaluationGrid = null;
      _loadingGroups = true;
    });
    if (project != null) {
      try {
        _groups = await GroupRemoteDatasource().fetchGroupsByProject(project.id);
        setState(() {
          _loadingGroups = false;
          if (_groups.isNotEmpty) {
            _currentGroupIndex = 0;
            _selectedGroup = _groups[0];
            _fetchCriteriaSets();
          }
        });
      } catch (e) {
        setState(() { _error = e.toString(); _loadingGroups = false; });
      }
    }
  }

  void _onGroupChanged(int index) {
    setState(() {
      _currentGroupIndex = index;
      _selectedGroup = _groups[index];
      _criteriaSets = [];
      _selectedCriteriaSet = null;
      _evaluationGrid = null;
    });
    _fetchCriteriaSets();
  }

  void _onCriteriaTypeChanged(String? type) {
    setState(() {
      _selectedCriteriaType = type ?? 'defense';
      _criteriaSets = [];
      _selectedCriteriaSet = null;
      _evaluationGrid = null;
    });
    _fetchCriteriaSets();
  }

  Future<void> _fetchCriteriaSets() async {
    if (_selectedGroup == null) return;
    setState(() { _loadingCriteriaSets = true; });
    final repo = CriteriaSetRepository(_storage);
    try {
      _criteriaSets = await repo.getCriteriaSets(type: _selectedCriteriaType);
      setState(() {
        _loadingCriteriaSets = false;
        if (_criteriaSets.isNotEmpty) {
          _selectedCriteriaSet = _criteriaSets[0];
          _fetchEvaluationGrid();
        }
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loadingCriteriaSets = false; });
    }
  }

  Future<void> _fetchEvaluationGrid() async {
    if (_selectedCriteriaSet == null || _selectedGroup == null) return;
    setState(() { _loadingGrid = true; });
    final repo = EvaluationGridRepository(_storage);
    try {
      _evaluationGrid = await repo.fetchEvaluationGrid(
        criteriaSetId: _selectedCriteriaSet!.id!,
        groupId: _selectedGroup!.id,
      );
      setState(() {
        _loadingGrid = false;
        _scores = Map<String, int>.from(_evaluationGrid?.scores ?? {});
        _comments = Map<String, String>.from(_evaluationGrid?.comments ?? {});
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loadingGrid = false; });
    }
  }

  Future<void> _submitGrid() async {
    if (_selectedCriteriaSet == null || _selectedGroup == null) return;
    setState(() { _loadingGrid = true; });
    final repo = EvaluationGridRepository(_storage);
    final userId = await _storage.read(key: 'userId') ?? '';
    final grid = EvaluationGrid(
      criteriaSetId: _selectedCriteriaSet!.id!,
      groupId: _selectedGroup!.id,
      filledBy: userId,
      scores: _scores,
      comments: _comments,
    );
    try {
      await repo.submitEvaluationGrid(grid);
      debugPrint('Grille soumise avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grille soumise avec succès')),
      );
      _fetchEvaluationGrid();
    } catch (e) {
      debugPrint('Erreur soumission grille: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() { _loadingGrid = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grilles de notation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown promo
            DropdownButton<Promotion>(
              value: _selectedPromotion,
              hint: const Text('Sélectionner une promo'),
              items: _promotions.map((promo) => DropdownMenuItem<Promotion>(
                value: promo,
                child: Text(promo.name ?? ''),
              )).toList(),
              onChanged: _loadingPromos ? null : _onPromotionSelected,
            ),
            if (_selectedPromotion != null)
              DropdownButton<Project>(
                value: _selectedProject,
                hint: const Text('Sélectionner un projet'),
                items: _projects.map((proj) => DropdownMenuItem<Project>(
                  value: proj,
                  child: Text(proj.name ?? ''),
                )).toList(),
                onChanged: _loadingProjects ? null : _onProjectSelected,
              ),
            if (_selectedProject != null && _groups.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: _currentGroupIndex > 0
                        ? () => _onGroupChanged(_currentGroupIndex - 1)
                        : null,
                  ),
                  Expanded(
                    child: DropdownButton<Group>(
                      value: _selectedGroup,
                      hint: const Text('Sélectionner un groupe'),
                      items: _groups.map((g) => DropdownMenuItem<Group>(
                        value: g,
                        child: Text(g.name ?? ''),
                      )).toList(),
                      onChanged: (g) {
                        final idx = _groups.indexOf(g!);
                        _onGroupChanged(idx);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: _currentGroupIndex < _groups.length - 1
                        ? () => _onGroupChanged(_currentGroupIndex + 1)
                        : null,
                  ),
                ],
              ),
            if (_selectedGroup != null)
              DropdownButton<String>(
                value: _selectedCriteriaType,
                items: const [
                  DropdownMenuItem(value: 'defense', child: Text('Soutenance')),
                  DropdownMenuItem(value: 'deliverable', child: Text('Rendu')),
                  DropdownMenuItem(value: 'report', child: Text('Rapport')),
                ],
                onChanged: _onCriteriaTypeChanged,
              ),
            if (_loadingCriteriaSets || _loadingGrid)
              const Center(child: CircularProgressIndicator()),
            if (_selectedCriteriaSet != null && !_loadingGrid)
              Expanded(
                child: ListView(
                  children: [
                    Text('Grille: ${_selectedCriteriaSet!.title ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                    ..._selectedCriteriaSet!.criteria.map((c) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.label ?? '', style: Theme.of(context).textTheme.bodyLarge),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _scores[c.id ?? c.label]?.toString() ?? '',
                                    decoration: InputDecoration(labelText: 'Note (max ${c.maxScore ?? ''})'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      setState(() {
                                        _scores[c.id ?? c.label] = int.tryParse(val) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _comments[c.id ?? c.label] ?? '',
                                    decoration: const InputDecoration(labelText: 'Commentaire'),
                                    onChanged: (val) {
                                      setState(() {
                                        _comments[c.id ?? c.label] = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadingGrid ? null : _submitGrid,
                      child: const Text('Soumettre la grille'),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

