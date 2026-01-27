import 'dart:convert';
import 'package:http/http.dart' as http;

class EmotionalData {
  final List<EmotionalPoint> history;
  final List<Topic> topics;
  final List<Insight> insights;

  EmotionalData({
    required this.history,
    required this.topics,
    required this.insights,
  });

  factory EmotionalData.fromJson(Map<String, dynamic> json) {
    return EmotionalData(
      history:
          (json['history'] as List?)
              ?.map((e) => EmotionalPoint.fromJson(e))
              .toList() ??
          [],
      topics:
          (json['topics'] as List?)?.map((e) => Topic.fromJson(e)).toList() ??
          [],
      insights:
          (json['insights'] as List?)
              ?.map((e) => Insight.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmotionalPoint {
  final String day;
  final double happy; // 0-100
  final double neutral;
  final double sad;

  EmotionalPoint(this.day, this.happy, this.neutral, this.sad);

  factory EmotionalPoint.fromJson(Map<String, dynamic> json) {
    return EmotionalPoint(
      json['day'] ?? json['dia'] ?? '',
      (json['happy'] ?? json['feliz'] ?? 0).toDouble(),
      (json['neutral'] ?? json['neutro'] ?? 0).toDouble(),
      (json['sad'] ?? json['triste'] ?? 0).toDouble(),
    );
  }
}

class Topic {
  final String text;
  final double weight; // 0-1
  final String sentiment; // 'positive', 'neutral', 'negative'

  Topic(this.text, this.weight, this.sentiment);

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      json['text'] ?? json['texto'] ?? '',
      (json['weight'] ?? json['peso'] ?? 0).toDouble(),
      json['sentiment'] ?? json['sentimento'] ?? 'neutral',
    );
  }
}

class Insight {
  final String id;
  final String type; // 'positive', 'alert', 'info'
  final String message;
  final String date;

  Insight(this.id, this.type, this.message, this.date);

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      json['id']?.toString() ?? '',
      json['type'] ?? json['tipo'] ?? 'info',
      json['message'] ?? json['mensagem'] ?? '',
      json['date'] ?? json['data'] ?? '',
    );
  }
}

class EmotionalService {
  static const String _baseUrl = 'https://eva-ia.org:8000';

  static Future<EmotionalData?> getEmotionalData(
    String idosoId, {
    String? token,
  }) async {
    try {
      print('📡 Buscando dados emocionais do backend...');

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/emotional_data/$idosoId'),
        headers: headers,
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('✅ Dados emocionais recebidos');
        return EmotionalData.fromJson(jsonData);
      } else {
        print('❌ Erro ao buscar dados emocionais: ${response.statusCode}');
        print('📄 Detalhes: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception EmotionalService: $e');
      return null;
    }
  }
}
