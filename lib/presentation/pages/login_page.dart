import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/google_token_dto.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final googleSignIn = Get.find<GoogleSignIn>();

    ref.listen<AsyncValue<void>>(authProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.white.withOpacity(0.8)),
              const SizedBox(height: 32),
              Text(
                'Bienvenue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Connectez-vous avec votre compte Google pour continuer.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              authState.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Se connecter avec Google'),
                        onPressed: () async {
                          try {
                            final account = await googleSignIn.signIn();
                            if (account == null) return;
                            final auth = await account.authentication;
                            final idToken = auth.idToken;
                            if (idToken == null) {
                              throw Exception('Le token Google est nul');
                            }
                            debugPrint('Nom : ${account.displayName}');
                            debugPrint('Token : $idToken');
                            final prenom = account.displayName?.split(' ').first ?? 'Utilisateur';
                            final dto = GoogleTokenDto(token: idToken);
                            await ref.read(authProvider.notifier).authenticateWithGoogle(dto, prenom: prenom);
                          } catch (e) {
                            debugPrint('Erreur Google Sign-In : $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
