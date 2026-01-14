import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catalogo_medicamento.dart';

class SafeCheckResult {
  final bool seguro;
  final String? alerta;
  final String? nivelPerigo;

  SafeCheckResult({required this.seguro, this.alerta, this.nivelPerigo});

  factory SafeCheckResult.fromJson(Map<String, dynamic> json) {
    return SafeCheckResult(
      seguro: json['seguro'] ?? true,
      alerta: json['alerta'],
      nivelPerigo: json['nivel_perigo'],
    );
  }
}

class MedicationService {
  static const String _baseUrl = 'http://104.248.219.200:8000'; // IP VPS

  /// Verifica se o medicamento é seguro para o idoso
  static Future<SafeCheckResult> checkSafety(
    String idosoId,
    String medicamentoNome, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/medicamentos/verificar'),
        headers: headers,
        body: jsonEncode({
          'idoso_id': idosoId,
          'nome_medicamento': medicamentoNome,
        }),
      );

      if (response.statusCode == 200) {
        return SafeCheckResult.fromJson(jsonDecode(response.body));
      } else {
        print('Erro ao verificar medicamento: ${response.body}');
        // Se der erro técnico, não bloqueamos, mas logamos
        return SafeCheckResult(seguro: true);
      }
    } catch (e) {
      print('Exception MedicationService: $e');
      return SafeCheckResult(seguro: true);
    }
  }

  /// Busca medicamentos no catálogo farmacêutico
  static Future<List<CatalogoMedicamento>> searchCatalogo(
    String query, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/medicamentos/catalogo/search?q=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => CatalogoMedicamento.fromJson(json)).toList();
      } else {
        print('Erro ao buscar catálogo: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception searchCatalogo: $e');
      return [];
    }
  }

  /// Obtém informações detalhadas de um medicamento do catálogo
  static Future<CatalogoMedicamento?> getCatalogoInfo(
    int catalogoId, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/medicamentos/catalogo/$catalogoId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return CatalogoMedicamento.fromJson(jsonDecode(response.body));
      } else {
        print('Erro ao buscar info do catálogo: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception getCatalogoInfo: $e');
      return null;
    }
  }

  /// Verifica interações medicamentosas
  static Future<List<InteracaoRisco>> checkInteracoes(
    String idosoId,
    String novoMedicamento, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/medicamentos/verificar-interacoes'),
        headers: headers,
        body: jsonEncode({
          'idoso_id': idosoId,
          'novo_medicamento': novoMedicamento,
        }),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => InteracaoRisco.fromJson(json)).toList();
      } else {
        print('Erro ao verificar interações: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception checkInteracoes: $e');
      return [];
    }
  }
}
