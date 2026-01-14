import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agendamento.dart';

class AgendamentoService {
  static const String _baseUrl = 'http://104.248.219.200:8000';

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
