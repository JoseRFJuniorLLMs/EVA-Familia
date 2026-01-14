import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  // URL do Backend (Ajustar conforme ambiente: localhost ou IP da VPS)
  static const String _baseUrl =
      'http://104.248.219.200:8000'; // Exemplo IP VPS

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
}
