import 'dart:convert';
import 'package:http/http.dart' as http;

class Alerta {
  final String id;
  final String idosoNome;
  final String mensagem;
  final String severidade; // 'critica', 'alta', 'aviso', 'baixa'
  final String tipo;
  final String data;
  final bool resolvido;

  Alerta({
    required this.id,
    required this.idosoNome,
    required this.mensagem,
    required this.severidade,
    required this.tipo,
    required this.data,
    required this.resolvido,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id'].toString(),
      idosoNome: json['idoso_nome'] ?? 'Idoso',
      mensagem: json['mensagem'] ?? json['descricao'] ?? '',
      severidade: json['severidade'] ?? json['nivel'] ?? 'baixa',
      tipo: json['tipo'] ?? 'GERAL',
      data: json['data'] ?? json['criado_em'] ?? 'Sem data',
      resolvido: json['resolvido'] ?? json['status'] == 'resolvido' ?? false,
    );
  }
}

class AlertStats {
  final int active;
  final int critical;
  final int resolvedToday;

  AlertStats({
    required this.active,
    required this.critical,
    required this.resolvedToday,
  });
}

class AlertService {
  static const String _baseUrl = 'http://104.248.219.200:8000';

  static Future<List<Alerta>> getAlertas({
    String? idosoId,
    String? token,
  }) async {
    try {
      print('📡 Buscando alertas do backend...');

      final url = idosoId != null
          ? '$_baseUrl/alertas?idoso_id=$idosoId'
          : '$_baseUrl/alertas';

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('✅ ${data.length} alertas recebidos');
        return data.map((json) => Alerta.fromJson(json)).toList();
      } else {
        print('❌ Erro ao buscar alertas: ${response.statusCode}');
        print('📄 Detalhes: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception AlertService: $e');
      return [];
    }
  }

  static Future<bool> resolveAlerta(
    String id,
    String nota, {
    String? token,
  }) async {
    try {
      print('🔧 Resolvendo alerta $id...');

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/alertas/$id/resolver'),
        headers: headers,
        body: jsonEncode({'nota': nota}),
      );

      if (response.statusCode == 200) {
        print('✅ Alerta resolvido com sucesso');
        return true;
      } else {
        print('❌ Erro ao resolver alerta: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Exception ao resolver alerta: $e');
      return false;
    }
  }
}
