class Idoso {
  final String id;
  final String nome;
  final DateTime dataNascimento;
  final String telefone;
  final String? cpf;
  final String? fotoUrl;
  final String? introAudioUrl;

  // Perfil de Saúde
  final String nivelCognitivo; // 'normal', 'leve', 'moderado', 'severo'
  final bool limitacoesAuditivas;
  final bool usaAparelhoAuditivo;
  final bool limitacoesVisuais;
  final String mobilidade; // 'independente', 'auxiliado', 'cadeira_rodas'

  // Personalização
  final String tomVoz; // 'amigavel', 'formal', 'carinhoso'
  final String preferenciaHorarioLigacao; // 'manha', 'tarde', 'noite'

  // Contatos
  final Map<String, dynamic>? familiarPrincipal;
  final Map<String, dynamic>? contatoEmergencia;

  // Estado
  final String sentimento; // 'feliz', 'triste', 'neutro', 'ansioso'
  final int agendamentosPendentes;
  final bool ativo;

  Idoso({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.telefone,
    this.cpf,
    this.fotoUrl,
    this.introAudioUrl,
    this.nivelCognitivo = 'normal',
    this.limitacoesAuditivas = false,
    this.usaAparelhoAuditivo = false,
    this.limitacoesVisuais = false,
    this.mobilidade = 'independente',
    this.tomVoz = 'amigavel',
    this.preferenciaHorarioLigacao = 'manha',
    this.familiarPrincipal,
    this.contatoEmergencia,
    this.sentimento = 'neutro',
    this.agendamentosPendentes = 0,
    this.ativo = true,
  });

  factory Idoso.fromJson(Map<String, dynamic> json) {
    return Idoso(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'])
          : DateTime.now(),
      telefone: json['telefone'] ?? '',
      cpf: json['cpf'],
      fotoUrl: json['foto_url'],
      introAudioUrl: json['intro_audio_url'],
      nivelCognitivo: json['nivel_cognitivo'] ?? 'normal',
      limitacoesAuditivas: json['limitacoes_auditivas'] ?? false,
      usaAparelhoAuditivo: json['usa_aparelho_auditivo'] ?? false,
      limitacoesVisuais: json['limitacoes_visuais'] ?? false,
      mobilidade: json['mobilidade'] ?? 'independente',
      tomVoz: json['tom_voz'] ?? 'amigavel',
      preferenciaHorarioLigacao: json['preferencia_horario_ligacao'] ?? 'manha',
      familiarPrincipal: json['familiar_principal'],
      contatoEmergencia: json['contato_emergencia'],
      sentimento: json['sentimento'] ?? 'neutro',
      agendamentosPendentes: json['agendamentos_pendentes'] ?? 0,
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data_nascimento': dataNascimento.toIso8601String().split('T')[0],
      'telefone': telefone,
      'cpf': cpf,
      'foto_url': fotoUrl,
      'intro_audio_url': introAudioUrl,
      'nivel_cognitivo': nivelCognitivo,
      'limitacoes_auditivas': limitacoesAuditivas,
      'usa_aparelho_auditivo': usaAparelhoAuditivo,
      'limitacoes_visuais': limitacoesVisuais,
      'mobilidade': mobilidade,
      'tom_voz': tomVoz,
      'preferencia_horario_ligacao': preferenciaHorarioLigacao,
      'familiar_principal': familiarPrincipal,
      'contato_emergencia': contatoEmergencia,
      'sentimento': sentimento,
      'agendamentos_pendentes': agendamentosPendentes,
      'ativo': ativo,
    };
  }

  int get idade {
    final now = DateTime.now();
    int age = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      age--;
    }
    return age;
  }
}

class Familiar {
  final String? id;
  final String idosoId;
  final String nome;
  final String? parentesco;
  final String? telefone;
  final String? email;
  final bool ehResponsavel;
  final bool ehContatoEmergencia;

  Familiar({
    this.id,
    required this.idosoId,
    required this.nome,
    this.parentesco,
    this.telefone,
    this.email,
    this.ehResponsavel = false,
    this.ehContatoEmergencia = false,
  });

  factory Familiar.fromJson(Map<String, dynamic> json) {
    return Familiar(
      id: json['id']?.toString(),
      idosoId: json['idoso_id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      parentesco: json['parentesco'],
      telefone: json['telefone'],
      email: json['email'],
      ehResponsavel: json['eh_responsavel'] ?? false,
      ehContatoEmergencia: json['eh_contato_emergencia'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'idoso_id': idosoId,
      'nome': nome,
      'parentesco': parentesco,
      'telefone': telefone,
      'email': email,
      'eh_responsavel': ehResponsavel,
      'eh_contato_emergencia': ehContatoEmergencia,
    };
  }
}
