import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardResumo {
  final int passos;
  final int? bpm;
  final String? pressaoArterial; // "120/80"
  final double? horasSono;
  final int? calorias;
  final int? aguaMl;
  final DateTime data;

  DashboardResumo({
    required this.passos,
    this.bpm,
    this.pressaoArterial,
    this.horasSono,
    this.calorias,
    this.aguaMl,
    required this.data,
  });

  factory DashboardResumo.fromJson(Map<String, dynamic> json) {
    return DashboardResumo(
      passos: json['passos'] ?? 0,
      bpm: json['bpm'],
      pressaoArterial: json['pressao_arterial'],
      horasSono: json['horas_sono']?.toDouble(),
      calorias: json['calorias'],
      aguaMl: json['agua_ml'],
      data: DateTime.parse(json['data']),
    );
  }
}

class DashboardService {
  static const String baseUrl = 'http://104.248.219.200:8000';

  static Future<DashboardResumo?> getResumoDiario(
    String idosoId, {
    DateTime? data,
    String? token,
  }) async {
    try {
      final dataParam = data != null
          ? '?data=${data.toIso8601String().split('T')[0]}'
          : '';

      final url = '$baseUrl/dashboard/resumo-diario/$idosoId$dataParam';

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token'; // Usar token se disponível
      }

      print('📡 Buscando resumo diário: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('✅ Resumo recebido');
        return DashboardResumo.fromJson(jsonData);
      } else {
        print('❌ Erro no resumo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Erro de conexão: $e');
      return null;
    }
  }

  // Buscar dados dos últimos 7 dias para gráficos de tendência
  static Future<List<DashboardResumo>> getTendencia7Dias(
    String idosoId, {
    String? token,
  }) async {
    try {
      final List<DashboardResumo> tendencia = [];
      final hoje = DateTime.now();

      print('📡 Buscando tendência de 7 dias...');

      // Buscar dados dos últimos 7 dias
      for (int i = 6; i >= 0; i--) {
        final data = hoje.subtract(Duration(days: i));
        // Passa token recursivamente
        final resumo = await getResumoDiario(idosoId, data: data, token: token);

        if (resumo != null) {
          tendencia.add(resumo);
        }
      }

      print('✅ ${tendencia.length} dias de dados recuperados');
      return tendencia;
    } catch (e) {
      print('💥 Erro ao buscar tendência: $e');
      return [];
    }
  }
}
