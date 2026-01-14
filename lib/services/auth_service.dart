import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Usuario {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? linkedIdosoId;
  final String? accessToken; // Adicionar token

  Usuario({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.linkedIdosoId,
    this.accessToken,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      name: json['nome'] ?? json['name'] ?? 'Usuário',
      email: json['email'] ?? '',
      role: json['role'] ?? json['tipo'] ?? 'user',
      linkedIdosoId:
          json['idoso_id']?.toString() ?? json['linkedIdosoId']?.toString(),
      accessToken: json['access_token'],
    );
  }
}

class AuthService {
  static const String _baseUrl = 'http://104.248.219.200:8000';
  static const String _tokenKey = 'auth_token';
  static const String _userKey =
      'user_data'; // Store minimal user data if needed

  static Future<Usuario?> login(String email, String senhaHash) async {
    try {
      print('🔐 Tentando login para: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'senha_hash': senhaHash}),
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        if (token == null) {
          print('❌ Token não encontrado na resposta');
          return null;
        }

        // Decodificar JWT para extrair dados do usuário
        final userData = _decodeJWT(token);

        print('✅ Login bem-sucedido! User ID: ${userData['user_id']}');

        final user = Usuario(
          id: userData['user_id']?.toString() ?? 'unknown',
          name: userData['name'] ?? 'Usuário',
          email: userData['sub'] ?? email,
          role: userData['role'] ?? 'viewer',
          linkedIdosoId: userData['idoso_id']?.toString(),
          accessToken: token,
        );

        // Persistir token
        await _saveToken(token);

        return user;
      } else {
        print('❌ Erro no login: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Exception Auth: $e');
      return null;
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<Usuario?> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_tokenKey)) return null;

      final token = prefs.getString(_tokenKey);
      if (token == null) return null;

      // TODO: verificar validade do token (expiração)
      final userData = _decodeJWT(token);
      if (userData.isEmpty) return null;

      return Usuario(
        id: userData['user_id']?.toString() ?? 'unknown',
        name: userData['name'] ?? 'Usuário',
        email: userData['sub'] ?? '',
        role: userData['role'] ?? 'viewer',
        linkedIdosoId: userData['idoso_id']?.toString(),
        accessToken: token,
      );
    } catch (e) {
      print('Erro no auto-login: $e');
      return null;
    }
  }

  // Decodificar JWT (simples, sem verificação de assinatura)
  static Map<String, dynamic> _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded);
    } catch (e) {
      print('❌ Erro ao decodificar JWT: $e');
      return {};
    }
  }
}
