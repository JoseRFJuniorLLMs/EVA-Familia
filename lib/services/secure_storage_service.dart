import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const String _emailKey = 'saved_email';
  static const String _senhaKey = 'saved_senha';

  /// Salva as credenciais de forma segura
  static Future<void> saveCredentials(String email, String senha) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _senhaKey, value: senha);
  }

  /// Recupera as credenciais salvas
  static Future<Map<String, String>?> getCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final senha = await _storage.read(key: _senhaKey);

    if (email != null && senha != null) {
      return {'email': email, 'senha': senha};
    }
    return null;
  }

  /// Remove as credenciais salvas
  static Future<void> deleteCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _senhaKey);
  }

  /// Verifica se existem credenciais salvas
  static Future<bool> hasCredentials() async {
    final email = await _storage.read(key: _emailKey);
    return email != null;
  }
}
