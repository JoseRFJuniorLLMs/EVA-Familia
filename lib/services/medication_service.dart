import 'dart:convert';
import 'package:http/http.dart' as http;

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
        Uri.parse('$_baseUrl/medicamentos/verificar'),
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
}
