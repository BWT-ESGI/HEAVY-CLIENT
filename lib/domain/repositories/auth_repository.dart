abstract class AuthRepository {
  Future<String> authenticateWithGoogle(String token, {String? schoolName});
}