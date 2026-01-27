import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agendamento.dart';

class AgendamentoService {
  static const String _baseUrl = 'https://eva-ia.org:8000';

  static Future<List<Agendamento>> getAgendamentos({
    String? idosoId,
    String? token,
  }) async {
    try {
      final url = idosoId != null
          ? '$_baseUrl/api/v1/agendamentos?idoso_id=$idosoId'
          : '$_baseUrl/api/v1/agendamentos';

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('📡 Buscando agendamentos: $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      print('📊 Status Agendamentos: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => _fromJson(json)).toList();
      } else {
        print('❌ Erro ao buscar agendamentos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Exception AgendamentoService: $e');
      return [];
    }
  }

  static Future<bool> createAgendamento(
    Agendamento agendamento, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'idoso_id': int.tryParse(agendamento.idosoId ?? '0'),
        'data_hora': agendamento.dataHora.toIso8601String(),
        'tipo': agendamento.tipo,
        'descricao': agendamento.descricao,
        'status': 'AGENDADO',
        'nome_idoso': agendamento.nome, // Backend as vezes precisa
        'telefone_contato': agendamento.telefone,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/agendamentos'),
        headers: headers,
        body: jsonEncode(body),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('💥 Erro ao criar agendamento: $e');
      return false;
    }
  }

  /// Cancela um agendamento (muda status para CANCELADO ou deleta)
  static Future<bool> cancelAgendamento(
    String agendamentoId, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      // Tentar PATCH para mudar status
      var response = await http.patch(
        Uri.parse('$_baseUrl/api/v1/agendamentos/$agendamentoId'),
        headers: headers,
        body: jsonEncode({'status': 'CANCELADO'}),
      );

      print('📡 PATCH agendamento $agendamentoId: ${response.statusCode}');

      // Se PATCH não funcionar, tentar DELETE
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http.delete(
          Uri.parse('$_baseUrl/api/v1/agendamentos/$agendamentoId'),
          headers: headers,
        );
        print('📡 DELETE agendamento $agendamentoId: ${response.statusCode}');
      }

      return response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201;
    } catch (e) {
      print('💥 Erro ao cancelar agendamento: $e');
      return false;
    }
  }

  /// Atualiza status de um agendamento
  static Future<bool> updateAgendamentoStatus(
    String agendamentoId,
    String newStatus, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/v1/agendamentos/$agendamentoId'),
        headers: headers,
        body: jsonEncode({'status': newStatus}),
      );

      print('📡 Update status $agendamentoId -> $newStatus: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('💥 Erro ao atualizar status: $e');
      return false;
    }
  }

  static Agendamento _fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'].toString(),
      nome: json['nome_idoso'] ?? 'Idoso', // Backend pode retornar nome_idoso
      telefone: json['telefone_contato'] ?? '',
      dataHora: DateTime.parse(json['data_hora']),
      tipo: json['tipo'] ?? 'Geral',
      descricao: json['descricao'] ?? '',
      status: json['status'] ?? 'AGENDADO',
      tentativas: json['tentativas'] ?? 0,
      idosoId: json['idoso_id']?.toString(),
    );
  }
}
