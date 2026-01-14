import 'package:flutter/material.dart';
import '../models/idoso.dart';
import '../services/idoso_service.dart';
import '../constants/app_colors.dart';
import 'idoso_form_screen.dart';
import 'idoso_agendamentos_screen.dart';

class IdosoDetailScreen extends StatefulWidget {
  final Idoso idoso;
  final String? token;

  const IdosoDetailScreen({super.key, required this.idoso, this.token});

  @override
  State<IdosoDetailScreen> createState() => _IdosoDetailScreenState();
}

class _IdosoDetailScreenState extends State<IdosoDetailScreen> {
  List<Familiar> _familiares = [];
  bool _isLoadingFamiliares = true;

  @override
  void initState() {
    super.initState();
    _loadFamiliares();
  }

  Future<void> _loadFamiliares() async {
    setState(() {
      _isLoadingFamiliares = true;
    });

    final familiares = await IdosoService.getFamiliares(
      widget.idoso.id,
      token: widget.token,
    );

    if (mounted) {
      setState(() {
        _familiares = familiares;
        _isLoadingFamiliares = false;
      });
    }
  }

  Future<void> _deleteIdoso() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir ${widget.idoso.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await IdosoService.deleteIdoso(
        widget.idoso.id,
        token: widget.token,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Idoso excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir idoso'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editIdoso() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            IdosoFormScreen(token: widget.token, idoso: widget.idoso),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  void _viewAgendamentos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdosoAgendamentosScreen(
          idosoId: widget.idoso.id,
          idosoNome: widget.idoso.nome,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: widget.idoso.fotoUrl != null
                          ? NetworkImage(widget.idoso.fotoUrl!)
                          : null,
                      child: widget.idoso.fotoUrl == null
                          ? Text(
                              widget.idoso.nome[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.idoso.nome,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${widget.idoso.idade} anos',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: _editIdoso),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteIdoso,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildHealthSection(),
                  const SizedBox(height: 16),
                  _buildPreferencesSection(),
                  const SizedBox(height: 16),
                  _buildFamiliaresSection(),
                  const SizedBox(height: 16),
                  _buildActionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return _buildCard('Informações de Contato', [
      _buildInfoRow(Icons.phone, 'Telefone', widget.idoso.telefone),
      if (widget.idoso.cpf != null)
        _buildInfoRow(Icons.badge, 'CPF', widget.idoso.cpf!),
    ]);
  }

  Widget _buildHealthSection() {
    return _buildCard('Perfil de Saúde', [
      _buildInfoRow(
        Icons.psychology,
        'Nível Cognitivo',
        _formatLabel(widget.idoso.nivelCognitivo),
      ),
      _buildInfoRow(
        Icons.accessible,
        'Mobilidade',
        _formatLabel(widget.idoso.mobilidade),
      ),
      if (widget.idoso.limitacoesAuditivas)
        _buildInfoRow(
          Icons.hearing,
          'Limitações Auditivas',
          widget.idoso.usaAparelhoAuditivo ? 'Sim (usa aparelho)' : 'Sim',
        ),
      if (widget.idoso.limitacoesVisuais)
        _buildInfoRow(Icons.visibility, 'Limitações Visuais', 'Sim'),
    ]);
  }

  Widget _buildPreferencesSection() {
    return _buildCard('Preferências', [
      _buildInfoRow(
        Icons.record_voice_over,
        'Tom de Voz',
        _formatLabel(widget.idoso.tomVoz),
      ),
      _buildInfoRow(
        Icons.schedule,
        'Horário Preferido',
        _formatLabel(widget.idoso.preferenciaHorarioLigacao),
      ),
      _buildInfoRow(
        Icons.sentiment_satisfied,
        'Sentimento Atual',
        _formatLabel(widget.idoso.sentimento),
      ),
    ]);
  }

  Widget _buildFamiliaresSection() {
    return _buildCard(
      'Familiares',
      _isLoadingFamiliares
          ? [const Center(child: CircularProgressIndicator())]
          : _familiares.isEmpty
          ? [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum familiar cadastrado',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ]
          : _familiares.map((f) => _buildFamiliarTile(f)).toList(),
    );
  }

  Widget _buildFamiliarTile(Familiar familiar) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(familiar.nome),
      subtitle: Text(familiar.parentesco ?? 'Familiar'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (familiar.ehResponsavel)
            const Icon(Icons.star, color: Colors.amber, size: 20),
          if (familiar.ehContatoEmergencia)
            const Icon(Icons.emergency, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _viewAgendamentos,
            icon: const Icon(Icons.event, color: Colors.white),
            label: const Text(
              'Ver Agendamentos',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String value) {
    final map = {
      'normal': 'Normal',
      'leve': 'Leve',
      'moderado': 'Moderado',
      'severo': 'Severo',
      'independente': 'Independente',
      'auxiliado': 'Auxiliado',
      'cadeira_rodas': 'Cadeira de Rodas',
      'amigavel': 'Amigável',
      'formal': 'Formal',
      'carinhoso': 'Carinhoso',
      'manha': 'Manhã',
      'tarde': 'Tarde',
      'noite': 'Noite',
      'feliz': 'Feliz',
      'triste': 'Triste',
      'neutro': 'Neutro',
      'ansioso': 'Ansioso',
    };
    return map[value] ?? value;
  }
}
