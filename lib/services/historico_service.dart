import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/historico_ligacao.dart';

class HistoricoService {
  static const String _baseUrl = 'https://eva-ia.org:8000';

  /// Lista todo o histórico de ligações
  static Future<List<HistoricoLigacao>> getHistorico({String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/historico/'),
        headers: headers,
      );

      print('📞 GET /historico/ - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => HistoricoLigacao.fromJson(json)).toList();
      } else {
        print('❌ Erro ao buscar histórico: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception getHistorico: $e');
      return [];
    }
  }

  /// Busca uma ligação específica por ID
  static Future<HistoricoLigacao?> getHistoricoById(
    String id, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/historico/$id'),
        headers: headers,
      );

      print('📞 GET /historico/$id - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return HistoricoLigacao.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erro ao buscar ligação: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception getHistoricoById: $e');
      return null;
    }
  }

  /// Busca histórico de um idoso específico
  static Future<List<HistoricoLigacao>> getHistoricoByIdoso(
    String idosoId, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/historico/idoso/$idosoId'),
        headers: headers,
      );

      print(
        '📞 GET /historico/idoso/$idosoId - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => HistoricoLigacao.fromJson(json)).toList();
      } else {
        print('❌ Erro ao buscar histórico do idoso: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception getHistoricoByIdoso: $e');
      return [];
    }
  }
}
