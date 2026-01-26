import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import 'idoso_agendamentos_screen.dart';
import 'novo_agendamento_screen.dart';
import '../constants/app_colors.dart';

import '../services/agendamento_service.dart';
import '../services/idoso_service.dart';
import '../models/idoso.dart' as idoso_model;

class AgendamentoScreen extends StatefulWidget {
  final String? token;
  const AgendamentoScreen({super.key, this.token});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  String _selectedIdosoId = '';
  final String _statusFilter = 'TODOS STATUS';
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  List<Idoso> _idosos = [];
  List<Agendamento> _agendamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final agendamentos = await AgendamentoService.getAgendamentos(
      token: widget.token,
    );

    // Extract unique idosos from agendamentos
    final Map<String, Idoso> idososMap = {};
    for (var a in agendamentos) {
      if (a.idosoId != null && !idososMap.containsKey(a.idosoId)) {
        idososMap[a.idosoId!] = Idoso(
          id: a.idosoId!,
          nome: a.nome,
          documento: '', // Não temos documento no Agendamento, mas ok por agora
        );
      }
    }

    if (mounted) {
      setState(() {
        _agendamentos = agendamentos;
        _idosos = idososMap.values.toList();
        _isLoading = false;
      });
    }
  }

  /// Mostra dialog para selecionar idoso e criar novo agendamento
  Future<void> _showNovoAgendamentoDialog() async {
    // Carregar lista de idosos do backend
    final idososList = await IdosoService.getIdosos(token: widget.token);

    if (!mounted) return;

    if (idososList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum idoso cadastrado. Cadastre um idoso primeiro.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar dialog para selecionar idoso
    final selectedIdoso = await showDialog<idoso_model.Idoso>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Selecionar Paciente'),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            children: [
              // Campo de busca
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar idoso...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              // Lista de idosos
              Expanded(
                child: ListView.builder(
                  itemCount: idososList.length,
                  itemBuilder: (context, index) {
                    final idoso = idososList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          idoso.nome.isNotEmpty ? idoso.nome[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        idoso.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(idoso.telefone ?? 'Sem telefone'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, idoso),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selectedIdoso == null || !mounted) return;

    // Navegar para tela de novo agendamento com idoso selecionado
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovoAgendamentoScreen(
          idosoId: selectedIdoso.id,
          idosoNome: selectedIdoso.nome,
          token: widget.token,
        ),
      ),
    );

    // Recarregar dados se criou agendamento
    if (result == true) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Sidebar Esquerda - Nexus de Cuidado
                Container(
                  width: 400,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: const Text(
                          'Nexus de Cuidado',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Campo de Busca
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Buscar Idoso no Nexus...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Lista de Idosos
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: _idosos.length,
                          itemBuilder: (context, index) {
                            final idoso = _idosos[index];
                            final isSelected = _selectedIdosoId == idoso.id;
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        IdosoAgendamentosScreen(
                                          idosoId: idoso.id,
                                          idosoNome: idoso.nome,
                                          token: widget.token,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFFE3F2FD,
                                        ) // Pode ser AppColors.secondary.withOpacity(0.1) se preferir
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(color: AppColors.secondary)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        idoso.nome.split(' ').length > 1
                                            ? '${idoso.nome.split(' ')[0][0]}${idoso.nome.split(' ')[1][0]}'
                                            : idoso.nome[0],
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            idoso.nome,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            idoso.documento,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Área Principal - Calendário e Dashboard
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Header do Calendário
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _getMonthName(_currentMonth.month),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '2026',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary, // Rosa
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'JANELA: 0',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month - 1,
                                        );
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month + 1,
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Calendário
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCalendar(),
                                const SizedBox(height: 32),
                                _buildDashboard(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          // Grid do calendário
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final day = index - firstWeekday + 1;
              if (day < 1 || day > lastDay.day) {
                return const SizedBox();
              }
              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
              final isSelected =
                  date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final totalFluxo = _agendamentos.length;
    final pendentes = _agendamentos
        .where((a) => a.status == 'PENDENTE' || a.status == 'NAO_ATENDIDO')
        .length;
    final concluidos = _agendamentos
        .where((a) => a.status == 'CONCLUIDO')
        .length;
    final altaPrioridade = _agendamentos
        .where((a) => a.status == 'NAO_ATENDIDO')
        .length;

    return Container(
      margin: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de Resumo
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'FLUXO TOTAL',
                  '$totalFluxo',
                  AppColors.primary,
                  Icons.bolt,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'PENDENTES',
                  '$pendentes',
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'CONCLUÍDOS',
                  '$concluidos',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'ALTA PRIORIDADE',
                  '$altaPrioridade',
                  Colors.red,
                  Icons.priority_high,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Controles
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar Agendamentos: Nome ou Telefone...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Toggle Lista/Painel
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggleButton('Lista', Icons.list, true),
                    _buildViewToggleButton('Painel', Icons.dashboard, false),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Dropdown Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_statusFilter),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Botão Novo Nexus
              ElevatedButton.icon(
                onPressed: () => _showNovoAgendamentoDialog(),
                icon: const Icon(Icons.calendar_today),
                label: const Text('NOVO NEXUS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lista de Agendamentos
          ..._agendamentos.map(
            (agendamento) => _buildAgendamentoCard(agendamento),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(String label, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () {
        // View mode toggle removed - not currently used
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Indicador lateral
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 20),

          // Hora e Data
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${agendamento.dataHora.hour.toString().padLeft(2, '0')}:${agendamento.dataHora.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${agendamento.dataHora.day.toString().padLeft(2, '0')} DE ${_getMonthName(agendamento.dataHora.month).substring(0, 3).toUpperCase()}.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(width: 20),

          // Foto do perfil
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: Text(
                  agendamento.nome[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 20),

          // Detalhes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agendamento.nome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${agendamento.tipo} - ${agendamento.descricao}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  agendamento.telefone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Text(
                  agendamento.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TENTATIVAS: ${agendamento.tentativas}',
                  style: TextStyle(fontSize: 10, color: Colors.red[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }
}
