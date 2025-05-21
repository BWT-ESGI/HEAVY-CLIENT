import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final googleSignIn = Get.find<GoogleSignIn>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Column(
        children: [
          // Placeholders pour d'autres paramètres
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                await googleSignIn.disconnect();
                await googleSignIn.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

