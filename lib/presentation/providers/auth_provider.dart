import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/home_page.dart';
import '../../domain/entities/google_token_dto.dart';
import '../../domain/usecases/authenticate_with_google.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final _storage = const FlutterSecureStorage();
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> authenticateWithGoogle(GoogleTokenDto dto, {required String prenom}) async {
    state = const AsyncValue.loading();
    try {
      final usecase = Get.find<AuthenticateWithGoogle>();
      final token = await usecase(dto);
      await _storage.write(key: 'accessToken', value: token);
      state = const AsyncValue.data(null);
      // Redirige vers HomePage avec le prénom
      Get.offAll(() => HomePage(prenom: prenom));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
