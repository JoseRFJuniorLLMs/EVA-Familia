class Agendamento {
  final String id;
  final String nome;
  final String telefone;
  final DateTime dataHora;
  final String tipo;
  final String descricao;
  final String status; // NAO_ATENDIDO, ATENDIDO, PENDENTE, CONCLUIDO
  final int tentativas;
  final String? idosoId;

  Agendamento({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.dataHora,
    required this.tipo,
    required this.descricao,
    required this.status,
    required this.tentativas,
    this.idosoId,
  });
}

class Idoso {
  final String id;
  final String nome;
  final String documento;
  final String? fotoUrl;

  Idoso({
    required this.id,
    required this.nome,
    required this.documento,
    this.fotoUrl,
  });
}


