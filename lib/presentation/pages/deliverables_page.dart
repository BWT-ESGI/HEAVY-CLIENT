import 'package:flutter/material.dart';
import '../../data/datasources/deliverable_remote_datasource.dart';
import '../../data/datasources/promotion_remote_datasource.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/entities/project.dart';
import 'group_deliverables_viewer.dart';

class DeliverablesPage extends StatefulWidget {
  const DeliverablesPage({Key? key}) : super(key: key);

  @override
  State<DeliverablesPage> createState() => _DeliverablesPageState();
}

class _DeliverablesPageState extends State<DeliverablesPage> {
  Promotion? _selectedPromotion;
  Project? _selectedProject;
  List<Promotion> _promotions = [];
  List<Project> _projects = [];
  bool _loadingPromos = true;
  bool _loadingProjects = false;
  bool _loadingDeliverables = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() {
      _loadingPromos = true;
    });
    try {
      _promotions = await PromotionRemoteDatasource().fetchPromotions();
      setState(() {
        _loadingPromos = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingPromos = false;
      });
    }
  }

  void _onPromotionSelected(Promotion? promo) {
    setState(() {
      _selectedPromotion = promo;
      _selectedProject = null;
      _projects = promo?.projects ?? [];
    });
  }

  Future<void> _fetchDeliverables(String projectId) async {
    setState(() {
      _loadingDeliverables = true;
    });
    try {
      await DeliverableRemoteDatasource()
          .fetchDeliverablesByProject(projectId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi des livrables')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loadingPromos)
              const Center(child: CircularProgressIndicator()),
            if (!_loadingPromos)
              DropdownButton<Promotion>(
                hint: const Text('Sélectionner une promotion'),
                value: _selectedPromotion,
                items: _promotions
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: _onPromotionSelected,
              ),
            if (_loadingProjects)
              const Center(child: CircularProgressIndicator()),
            if (!_loadingProjects && _selectedPromotion != null)
              _projects.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Aucun projet pour cette promotion',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : DropdownButton<Project>(
                      hint: const Text('Sélectionner un projet'),
                      value: _selectedProject,
                      items: _projects
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              ))
                          .toList(),
                      onChanged: (proj) {
                        setState(() {
                          _selectedProject = proj;
                        });
                        if (proj != null && _selectedPromotion != null) {
                          _fetchDeliverables(proj.id);
                        }
                      },
                    ),
            if (_loadingDeliverables)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_loadingDeliverables &&
                _selectedPromotion != null &&
                _selectedProject != null)
              Expanded(
                child: GroupDeliverablesViewer(projectId: _selectedProject!.id),
              ),
          ],
        ),
      ),
    );
  }
}
