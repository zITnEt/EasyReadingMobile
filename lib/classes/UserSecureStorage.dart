import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'jwt_token';
  static const _keyId = 'user_id';

  static Future setToken(String token) async =>
      await _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: _keyToken);

  static Future setUserId(String userId) async =>
      await _storage.write(key: _keyId, value: userId);

  static Future<String?> getUserId() async =>
      await _storage.read(key: _keyId);
}
