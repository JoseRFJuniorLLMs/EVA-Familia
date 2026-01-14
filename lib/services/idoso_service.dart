import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/idoso.dart';

class IdosoService {
  static const String _baseUrl = 'http://104.248.219.200:8000';

  /// Lista todos os idosos do usuário logado
  static Future<List<Idoso>> getIdosos({String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/idosos/'),
        headers: headers,
      );

      print('📋 GET /idosos/ - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Idoso.fromJson(json)).toList();
      } else {
        print('❌ Erro ao buscar idosos: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception getIdosos: $e');
      return [];
    }
  }

  /// Busca um idoso específico por ID
  static Future<Idoso?> getIdoso(String id, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/idosos/$id'),
        headers: headers,
      );

      print('📋 GET /idosos/$id - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Idoso.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao buscar idoso: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception getIdoso: $e');
      return null;
    }
  }

  /// Cria um novo idoso
  static Future<Idoso?> createIdoso(Idoso idoso, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/idosos/'),
        headers: headers,
        body: jsonEncode(idoso.toJson()),
      );

      print('📋 POST /idosos/ - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Idoso.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao criar idoso: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception createIdoso: $e');
      return null;
    }
  }

  /// Atualiza um idoso existente
  static Future<Idoso?> updateIdoso(
    String id,
    Idoso idoso, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/idosos/$id'),
        headers: headers,
        body: jsonEncode(idoso.toJson()),
      );

      print('📋 PUT /idosos/$id - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Idoso.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao atualizar idoso: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception updateIdoso: $e');
      return null;
    }
  }

  /// Deleta um idoso
  static Future<bool> deleteIdoso(String id, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/idosos/$id'),
        headers: headers,
      );

      print('📋 DELETE /idosos/$id - Status: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('💥 Exception deleteIdoso: $e');
      return false;
    }
  }

  /// Lista familiares de um idoso
  static Future<List<Familiar>> getFamiliares(
    String idosoId, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/idosos/$idosoId/familiares'),
        headers: headers,
      );

      print(
        '📋 GET /idosos/$idosoId/familiares - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Familiar.fromJson(json)).toList();
      } else {
        print('❌ Erro ao buscar familiares: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception getFamiliares: $e');
      return [];
    }
  }

  /// Adiciona um familiar a um idoso
  static Future<Familiar?> addFamiliar(
    String idosoId,
    Familiar familiar, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/idosos/$idosoId/familiares'),
        headers: headers,
        body: jsonEncode(familiar.toJson()),
      );

      print(
        '📋 POST /idosos/$idosoId/familiares - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Familiar.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao adicionar familiar: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception addFamiliar: $e');
      return null;
    }
  }
}
