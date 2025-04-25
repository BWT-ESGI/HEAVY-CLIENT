import 'package:clubz/presentation/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../domain/entities/google_token_dto.dart';
import '../../domain/usecases/authenticate_with_google.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final _storage = const FlutterSecureStorage();
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> authenticateWithGoogle(GoogleTokenDto dto) async {
    state = const AsyncValue.loading();
    try {
      final usecase = Get.find<AuthenticateWithGoogle>();
      final token = await usecase(dto);
      await _storage.write(key: 'accessToken', value: token);
      state = const AsyncValue.data(null);
      Get.offAll(() => const HomePage());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}