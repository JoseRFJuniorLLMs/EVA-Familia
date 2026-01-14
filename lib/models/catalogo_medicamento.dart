class CatalogoMedicamento {
  final int id;
  final String nomeOficial;
  final String classeTerapeutica;
  final String apresentacaoPadrao;
  final double? doseMaximaMg;
  final String? alertaRenal;
  final List<RiscoGeriatrico> riscos;

  CatalogoMedicamento({
    required this.id,
    required this.nomeOficial,
    required this.classeTerapeutica,
    required this.apresentacaoPadrao,
    this.doseMaximaMg,
    this.alertaRenal,
    this.riscos = const [],
  });

  factory CatalogoMedicamento.fromJson(Map<String, dynamic> json) {
    return CatalogoMedicamento(
      id: json['id'],
      nomeOficial: json['nome_oficial'] ?? '',
      classeTerapeutica: json['classe_terapeutica'] ?? '',
      apresentacaoPadrao: json['apresentacao_padrao'] ?? '',
      doseMaximaMg: json['dose_maxima_mg']?.toDouble(),
      alertaRenal: json['alerta_renal'],
      riscos:
          (json['riscos'] as List<dynamic>?)
              ?.map((r) => RiscoGeriatrico.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class RiscoGeriatrico {
  final String tipo; // 'queda', 'confusao_mental'
  final bool ativo;
  final String? descricao;

  RiscoGeriatrico({required this.tipo, required this.ativo, this.descricao});

  factory RiscoGeriatrico.fromJson(Map<String, dynamic> json) {
    return RiscoGeriatrico(
      tipo: json['tipo'] ?? '',
      ativo: json['ativo'] ?? false,
      descricao: json['descricao'],
    );
  }

  String get tipoFormatado {
    switch (tipo.toLowerCase()) {
      case 'queda':
        return 'Risco de Queda';
      case 'confusao_mental':
        return 'Confusão Mental';
      default:
        return tipo;
    }
  }
}

class InteracaoRisco {
  final String medicamentoA;
  final String medicamentoB;
  final String nivelPerigo; // 'FATAL', 'ALTO', 'MODERADO', 'BAIXO'
  final String descricao;

  InteracaoRisco({
    required this.medicamentoA,
    required this.medicamentoB,
    required this.nivelPerigo,
    required this.descricao,
  });

  factory InteracaoRisco.fromJson(Map<String, dynamic> json) {
    return InteracaoRisco(
      medicamentoA: json['medicamento_a'] ?? '',
      medicamentoB: json['medicamento_b'] ?? '',
      nivelPerigo: json['nivel_perigo'] ?? 'BAIXO',
      descricao: json['descricao'] ?? '',
    );
  }

  bool get isCritico => nivelPerigo == 'FATAL' || nivelPerigo == 'ALTO';
}
