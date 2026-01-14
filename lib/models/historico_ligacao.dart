class HistoricoLigacao {
  final String id;
  final String idosoId;
  final String? idosoNome;
  final DateTime dataHora;
  final int duracao; // em segundos
  final String status; // 'completada', 'perdida', 'cancelada'
  final String? transcricao;
  final String? sentimentoGeral; // 'positivo', 'neutro', 'negativo'
  final Map<String, dynamic>? analiseDetalhada;
  final List<String>? topicosDiscutidos;
  final String? resumo;

  HistoricoLigacao({
    required this.id,
    required this.idosoId,
    this.idosoNome,
    required this.dataHora,
    required this.duracao,
    required this.status,
    this.transcricao,
    this.sentimentoGeral,
    this.analiseDetalhada,
    this.topicosDiscutidos,
    this.resumo,
  });

  factory HistoricoLigacao.fromJson(Map<String, dynamic> json) {
    return HistoricoLigacao(
      id: json['id']?.toString() ?? '',
      idosoId: json['idoso_id']?.toString() ?? '',
      idosoNome: json['idoso_nome'],
      dataHora: json['data_hora'] != null
          ? DateTime.parse(json['data_hora'])
          : DateTime.now(),
      duracao: json['duracao'] ?? 0,
      status: json['status'] ?? 'completada',
      transcricao: json['transcricao'],
      sentimentoGeral: json['sentimento_geral'],
      analiseDetalhada: json['analise_detalhada'],
      topicosDiscutidos: json['topicos_discutidos'] != null
          ? List<String>.from(json['topicos_discutidos'])
          : null,
      resumo: json['resumo'],
    );
  }

  String get duracaoFormatada {
    final minutos = duracao ~/ 60;
    final segundos = duracao % 60;
    return '${minutos}m ${segundos}s';
  }

  String get statusFormatado {
    switch (status.toLowerCase()) {
      case 'completada':
        return 'Completada';
      case 'perdida':
        return 'Perdida';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }
}
