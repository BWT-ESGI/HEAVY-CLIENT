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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: _tabs,
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: const TabBarView(
            children: _pages,
          ),
        ),
      ),
    );
  }
}

