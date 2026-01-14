import 'dart:convert';
import 'package:http/http.dart' as http;

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cpf;
  final String tipo;
  final DateTime? dataNascimento;
  final bool ativo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.cpf,
    required this.tipo,
    this.dataNascimento,
    this.ativo = true,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'],
      cpf: json['cpf'],
      tipo: json['tipo'] ?? 'viewer',
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'])
          : null,
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'tipo': tipo,
      'data_nascimento': dataNascimento?.toIso8601String().split('T')[0],
      'ativo': ativo,
    };
  }
}

class SettingsService {
  static const String _baseUrl = 'http://104.248.219.200:8000';

  /// Obtém perfil do usuário logado
  static Future<Usuario?> getProfile({String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/auth/me'),
        headers: headers,
      );

      print('⚙️ GET /auth/me - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao buscar perfil: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception getProfile: $e');
      return null;
    }
  }

  /// Atualiza perfil do usuário
  static Future<Usuario?> updateProfile(
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/auth/profile'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('⚙️ PUT /auth/profile - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao atualizar perfil: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception updateProfile: $e');
      return null;
    }
  }

  /// Altera senha do usuário
  static Future<bool> changePassword(
    String oldPassword,
    String newPassword, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/v1/auth/change-password'),
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      print('⚙️ PATCH /auth/change-password - Status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('💥 Exception changePassword: $e');
      return false;
    }
  }
}
