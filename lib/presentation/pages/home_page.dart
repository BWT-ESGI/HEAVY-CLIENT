import 'package:flutter/material.dart';

import 'deliverables_page.dart';
import 'reports_page.dart';
import 'grading_sheets_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const _tabs = <Tab>[
    Tab(text: 'Livrables'),
    Tab(text: 'Rapports'),
    Tab(text: 'Grilles'),
  ];

  static const _pages = <Widget>[
    DeliverablesPage(),
    ReportsPage(),
    GradingSheetsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
          bottom: const TabBar(
            tabs: _tabs,
            indicatorWeight: 3,
          ),
        ),
        body: const TabBarView(
          children: _pages,
        ),
      ),
    );
  }
}