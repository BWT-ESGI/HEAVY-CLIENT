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
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: authState.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
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
                    final prenom = account.displayName?.split(' ').first ?? 'Utilisateur';
                    final dto = GoogleTokenDto(token: idToken);
                    await ref
                        .read(authProvider.notifier)
                        .authenticateWithGoogle(dto, prenom: prenom);
                  } catch (e) {
                    debugPrint('Erreur Google Sign-In : $e');
                  }
                },
              ),
      ),
    );
  }
}
