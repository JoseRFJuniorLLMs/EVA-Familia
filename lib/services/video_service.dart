import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  // URL do Backend (Ajustar conforme ambiente: localhost ou IP da VPS)
  static const String _baseUrl =
      'https://eva-ia.org:8000'; // HTTPS com domínio

  /// Inicia uma sessão de vídeo para um idoso específico
  /// Retorna o session_id se sucesso, ou null se falha.
  static Future<String?> startVideoCall(String idosoId, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      // Conexão REAL com o Backend
      final response = await http.post(
        Uri.parse('$_baseUrl/video/start'),
        body: jsonEncode({'idoso_id': idosoId, 'role': 'family'}),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['session_id'];
      } else {
        print('Erro ao iniciar vídeo: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception VideoService: $e');
      return null;
    }
  }

  /// Inicia uma sessão de vídeo/voz IA para um idoso
  /// Retorna true se sucesso, false se falha.
  static Future<bool> startVideoSession(
    String idosoId,
    String idosoNome, {
    String? role,
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.post(
        Uri.parse('$_baseUrl/video/start'),
        body: jsonEncode({
          'idoso_id': idosoId,
          'idoso_nome': idosoNome,
          'role': role ?? 'family',
        }),
        headers: headers,
      );

      print('📹 Start video session: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('💥 Exception startVideoSession: $e');
      return false;
    }
  }
}
