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
      print('🔐 ========== INÍCIO DO LOGIN ==========');
      print('📧 Email: $email');
      print('🔑 Senha: ${senhaHash.substring(0, 3)}***');
      print('🌐 URL: $_baseUrl/api/v1/auth/login');

      final requestBody = {'email': email.trim(), 'senha_hash': senhaHash};
      print('📦 Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      print('📡 Response Body: ${response.body}');

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
        print('🔐 ========== FIM DO LOGIN ==========');

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
        print('❌ Response: ${response.body}');
        print('🔐 ========== FIM DO LOGIN (ERRO) ==========');
        return null;
      }
    } catch (e, stackTrace) {
      print('💥 Exception Auth: $e');
      print('📚 Stack trace: $stackTrace');
      print('🔐 ========== FIM DO LOGIN (EXCEPTION) ==========');
      return null;
    }
  }

  /// Registra novo usuário
  static Future<Usuario?> register({
    required String name,
    required String email,
    required String senhaHash,
    String role = 'cuidador',
  }) async {
    try {
      print('📝 Registrando novo usuário: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email.trim(),
          'senha_hash': senhaHash,
          'role': role,
        }),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        if (token == null) {
          print('❌ Token não encontrado na resposta');
          return null;
        }

        // Decodificar JWT para extrair dados do usuário
        final userData = _decodeJWT(token);

        print('✅ Registro bem-sucedido! User ID: ${userData['user_id']}');

        final user = Usuario(
          id: userData['user_id']?.toString() ?? 'unknown',
          name: userData['name'] ?? name,
          email: userData['sub'] ?? email,
          role: userData['role'] ?? role,
          linkedIdosoId: userData['idoso_id']?.toString(),
          accessToken: token,
        );

        // Persistir token
        await _saveToken(token);

        return user;
      } else if (response.statusCode == 400) {
        print('❌ Email já cadastrado');
        return null;
      } else {
        print('❌ Erro no registro: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception Register: $e');
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

      final userData = _decodeJWT(token);
      if (userData.isEmpty) return null;

      // Verificar se o token expirou
      if (!_isTokenValid(userData)) {
        print('⚠️ Token expirado, removendo...');
        await logout();
        return null;
      }

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

  /// Verifica se o token JWT ainda é válido (não expirou)
  static bool _isTokenValid(Map<String, dynamic> payload) {
    try {
      final exp = payload['exp'];
      if (exp == null) {
        // Se não tem exp, considera válido (backend não usa expiração)
        return true;
      }

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Token é válido se a data de expiração é no futuro
      final isValid = expirationDate.isAfter(now);

      if (!isValid) {
        print('🕐 Token expirou em: $expirationDate');
      }

      return isValid;
    } catch (e) {
      print('❌ Erro ao verificar expiração do token: $e');
      return true; // Em caso de erro, assume válido
    }
  }

  /// Verifica se o token atual é válido
  static Future<bool> isCurrentTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return false;

      final userData = _decodeJWT(token);
      return _isTokenValid(userData);
    } catch (e) {
      return false;
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
