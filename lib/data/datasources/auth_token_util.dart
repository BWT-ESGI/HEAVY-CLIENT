import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenUtil {
  static const _storage = FlutterSecureStorage();
  static Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
