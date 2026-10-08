import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'jwt_token';
  static const _roleKey = 'user_role'; // Chứa chức vụ (USER hoặc ORGANIZER)
  
  final _storage = const FlutterSecureStorage();

  Future<void> save(String token) => _storage.write(key: _key, value: token);
  Future<String?> read() => _storage.read(key: _key);
  
  Future<void> saveRole(String role) => _storage.write(key: _roleKey, value: role);
  Future<String?> readRole() => _storage.read(key: _roleKey);

  Future<void> clear() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _roleKey);
  }
}
