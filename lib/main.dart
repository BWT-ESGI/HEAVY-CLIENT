import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'injection.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clean Architecture App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      getPages: [
        GetPage(name: '/settings', page: () => const SettingsPage()),
      ],
    );
  }
}
