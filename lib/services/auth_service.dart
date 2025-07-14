import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthService {
  /// Connecte l'utilisateur avec Google, vérifie le rôle via l'API backend,
  /// affiche une alerte et déconnecte si ce n'est pas un professeur.
  static Future<bool> signInWithGoogleAndCheckRole(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false; // L'utilisateur a annulé

      final auth = await account.authentication;
      final idToken = auth.idToken;

      // Appel à l'API backend
      final response = await http.post(
        Uri.parse('https://api-bwt.thomasgllt.fr/authentication/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );
      debugPrint("Appel à /authentication/google, response: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final role = data['role'];

        if (role != 'teacher') {
          await _googleSignIn.signOut();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Accès refusé'),
              content:
                  const Text('L\'application est réservée aux professeurs.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return false;
        }
        // Ici, l'utilisateur est un professeur

        // debug toutes les values dans data
        debugPrint("Données de l'utilisateur : $data");

        const storage = FlutterSecureStorage();
        // Stocker le token dans le stockage sécurisé
        await storage.write(key: 'userId', value: data['userId']);
        await storage.write(key: 'username', value: data['username']);
        await storage.write(key: 'schoolName', value: data['schoolName']);
        await storage.write(key: 'accessToken', value: data['accessToken']);

        return true;
      } else {
        // Gérer l'erreur d'API
        await _googleSignIn.signOut();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: const Text('Erreur lors de la connexion à l\'API.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return false;
      }
    } catch (e) {
      // Gérer l'erreur de connexion
      await _googleSignIn.signOut();
      debugPrint("Erreur lors de la connexion Google : $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Erreur lors de la connexion Google.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }
}
