import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/medication_service.dart';
import '../services/agendamento_service.dart';
import '../services/idoso_service.dart';
import '../models/agendamento.dart' hide Idoso;
import '../models/catalogo_medicamento.dart';
import '../models/idoso.dart';

class NovoAgendamentoScreen extends StatefulWidget {
  final String? idosoId;
  final String? idosoNome;
  final String? token;

  const NovoAgendamentoScreen({
    super.key,
    this.idosoId,
    this.idosoNome,
    this.token,
  });

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

// ... (in _NovoAgendamentoScreenState class)

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  String? _selectedPacienteId;
  String? _selectedPacienteNome;
  String? _selectedPacienteTelefone;
  String _protocolo = '1 - Medicamento';
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _instrucaoController = TextEditingController();
  final TextEditingController _maxRetriesController = TextEditingController(
    text: '3',
  );
  final TextEditingController _intervaloController = TextEditingController(
    text: '10',
  );

  // Medication intelligence
  List<CatalogoMedicamento> _catalogoSuggestions = [];
  CatalogoMedicamento? _selectedMedicamento;
  bool _isSearching = false;

  // Lista de idosos para seleção
  List<Idoso> _idososDisponiveis = [];
  bool _isLoadingIdosos = false;

  @override
  void initState() {
    super.initState();
    if (widget.idosoId != null && widget.idosoNome != null) {
      _selectedPacienteId = widget.idosoId;
      _selectedPacienteNome = widget.idosoNome;
      // Carregar telefone do idoso
      _loadIdosoTelefone();
    }
    _loadIdososDisponiveis();
  }

  /// Carrega lista de idosos disponíveis para seleção
  Future<void> _loadIdososDisponiveis() async {
    setState(() => _isLoadingIdosos = true);

    try {
      final idosos = await IdosoService.getIdosos(token: widget.token);
      if (mounted) {
        setState(() {
          _idososDisponiveis = idosos;
          _isLoadingIdosos = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar idosos: $e');
      if (mounted) {
        setState(() => _isLoadingIdosos = false);
      }
    }
  }

  /// Carrega telefone do idoso selecionado
  Future<void> _loadIdosoTelefone() async {
    if (_selectedPacienteId == null) return;

    try {
      final idoso = await IdosoService.getIdoso(
        _selectedPacienteId!,
        token: widget.token,
      );

      if (mounted && idoso != null) {
        setState(() {
          _selectedPacienteTelefone = idoso.telefone;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar telefone do idoso: $e');
    }
  }

  /// Mostra dialog para selecionar paciente
  Future<void> _showPacienteSelectorDialog() async {
    if (_idososDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum idoso cadastrado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedIdoso = await showDialog<Idoso>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_search, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Selecionar Paciente'),
          ],
        ),
        content: SizedBox(
          width: 350,
          height: 400,
          child: _isLoadingIdosos
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _idososDisponiveis.length,
                  itemBuilder: (context, index) {
                    final idoso = _idososDisponiveis[index];
                    final isSelected = _selectedPacienteId == idoso.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : Colors.grey[300],
                          child: Text(
                            idoso.nome.isNotEmpty
                                ? idoso.nome[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          idoso.nome,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          idoso.telefone ?? 'Sem telefone cadastrado',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.7)
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => Navigator.pop(context, idoso),
                      ),
                    );
                  },
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

    if (selectedIdoso != null && mounted) {
      setState(() {
        _selectedPacienteId = selectedIdoso.id;
        _selectedPacienteNome = selectedIdoso.nome;
        _selectedPacienteTelefone = selectedIdoso.telefone;
      });
    }
  }

  /// Mostra seletor de hora
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _searchMedicamentos(String query) async {
    if (query.length < 3) {
      setState(() {
        _catalogoSuggestions = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await MedicationService.searchCatalogo(
      query,
      token: widget.token,
    );

    if (mounted) {
      setState(() {
        _catalogoSuggestions = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _selectMedicamento(CatalogoMedicamento medicamento) async {
    setState(() {
      _selectedMedicamento = medicamento;
      _instrucaoController.text = medicamento.nomeOficial;
      _catalogoSuggestions = [];
    });

    // Verificar interações
    if (_selectedPacienteId != null) {
      _checkInteracoes(medicamento.nomeOficial);
    }
  }

  Future<void> _checkInteracoes(String medicamento) async {
    if (_selectedPacienteId == null) return;

    final interacoes = await MedicationService.checkInteracoes(
      _selectedPacienteId!,
      medicamento,
      token: widget.token,
    );

    if (interacoes.isNotEmpty && mounted) {
      final criticas = interacoes.where((i) => i.isCritico).toList();
      if (criticas.isNotEmpty) {
        _showInteractionAlert(criticas);
      }
    }
  }

  void _showInteractionAlert(List<InteracaoRisco> interacoes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            const Text('Interação Detectada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...interacoes.map(
              (interacao) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NÍVEL: ${interacao.nivelPerigo}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${interacao.medicamentoA} + ${interacao.medicamentoB}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(interacao.descricao),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarAgendamento() async {
    final nomeMedicamento = _instrucaoController.text;

    // 1. Se for medicamento e tiver nome, valida segurança
    if (_protocolo == '1 - Medicamento' &&
        nomeMedicamento.isNotEmpty &&
        _selectedPacienteId != null) {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final safetyResult = await MedicationService.checkSafety(
        _selectedPacienteId!,
        nomeMedicamento,
        token: widget.token,
      );

      // Fechar loading
      if (mounted) Navigator.pop(context);

      if (!safetyResult.seguro && mounted) {
        // ALERTA DE PERIGO!
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Risco Detectado!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safetyResult.alerta ?? 'Interação medicamentosa detectada.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Deseja prosseguir mesmo assim?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context); // Fecha alerta
                  _finalizarCriacao(); // Prossegue por conta e risco
                },
                child: const Text(
                  'Ignorar e Salvar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        return; // Pára aqui, só continua se usuário clicar em "Ignorar"
      }
    }

    _finalizarCriacao();
  }

  Future<void> _finalizarCriacao() async {
    if (_selectedPacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um paciente primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_instrucaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha a instrução/medicamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Criar objeto Agendamento com horário selecionado
    final novoAgendamento = Agendamento(
      id: '',
      nome: _selectedPacienteNome ?? 'Idoso',
      telefone: _selectedPacienteTelefone ?? '',
      dataHora: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      tipo: _protocolo.split(' - ').last.toUpperCase(),
      descricao: _instrucaoController.text,
      status: 'AGENDADO',
      tentativas: 0,
      idosoId: _selectedPacienteId,
    );

    // Enviar para backend
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final sucesso = await AgendamentoService.createAgendamento(
      novoAgendamento,
      token: widget.token,
    );

    if (mounted) Navigator.pop(context); // Fechar loading

    if (sucesso && mounted) {
      Navigator.pop(context, true); // Retorna true para atualizar lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamento criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao criar agendamento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _instrucaoController.dispose();
    _maxRetriesController.dispose();
    _intervaloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVA Scheduler',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'PAINEL DE CONTROLE | OPERADOR',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendário
            _buildCalendar(),

            const SizedBox(height: 24),

            // Detalhes do Paciente
            _buildDetalhesPaciente(),

            const SizedBox(height: 24),

            // Protocolo de Atendimento
            _buildProtocoloAtendimento(),

            const SizedBox(height: 24),

            // Gestão da Tarefa
            _buildGestaoTarefa(),

            const SizedBox(height: 24),

            // Atividade do Mês
            _buildAtividadeMes(),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _confirmarAgendamento,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Agendamento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header do Calendário
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthName(_currentMonth.month),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_currentMonth.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          // Grid do calendário
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
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

  Widget _buildDetalhesPaciente() {
    final hasPaciente = _selectedPacienteNome != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Detalhes do Paciente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasPaciente ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasPaciente ? Colors.green[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Text(
                  hasPaciente ? 'PACIENTE SELECIONADO' : 'AGUARDANDO SELEÇÃO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasPaciente ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showPacienteSelectorDialog,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(hasPaciente ? 20 : 40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasPaciente ? AppColors.primary : Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: hasPaciente
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Colors.grey[50],
              ),
              child: hasPaciente
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _selectedPacienteNome![0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedPacienteNome!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_selectedPacienteTelefone != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedPacienteTelefone!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'Sem telefone cadastrado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(Icons.person_add, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Toque para selecionar paciente',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Seletor de horário
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtocoloAtendimento() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROTOCOLO DE ATENDIMENTO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<String>(
              value: _protocolo,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: '1 - Medicamento',
                  child: Text('1 - Medicamento'),
                ),
                DropdownMenuItem(
                  value: '2 - Consulta',
                  child: Text('2 - Consulta'),
                ),
                DropdownMenuItem(
                  value: '3 - Monitoramento',
                  child: Text('3 - Monitoramento'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _protocolo = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestaoTarefa() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'GESTÃO DA TAREFA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Campo de medicamento com autocomplete
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _instrucaoController,
                decoration: InputDecoration(
                  labelText: 'INSTRUÇÃO / MEDICAMENTO',
                  hintText: 'Ex: Losartana 50mg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                onChanged: _searchMedicamentos,
              ),
              // Sugestões do catálogo
              if (_catalogoSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _catalogoSuggestions.length,
                    itemBuilder: (context, index) {
                      final med = _catalogoSuggestions[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.medication,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          med.nomeOficial,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(med.classeTerapeutica),
                        trailing: med.riscos.any((r) => r.ativo)
                            ? const Icon(
                                Icons.warning_amber,
                                color: Colors.orange,
                              )
                            : null,
                        onTap: () => _selectMedicamento(med),
                      );
                    },
                  ),
                ),
              // Informações do medicamento selecionado
              if (_selectedMedicamento != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedMedicamento!.nomeOficial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Classe: ${_selectedMedicamento!.classeTerapeutica}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      if (_selectedMedicamento!.doseMaximaMg != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Dose Máxima: ${_selectedMedicamento!.doseMaximaMg}mg/dia',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                      if (_selectedMedicamento!.riscos.any((r) => r.ativo)) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '⚠️ RISCOS GERIÁTRICOS:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedMedicamento!.riscos
                              .where((r) => r.ativo)
                              .map(
                                (risco) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    risco.tipoFormatado,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _maxRetriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'MAX RETRIES',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _intervaloController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'INTERVALO (MIN)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtividadeMes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATIVIDADE DO MÊS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Sem atividades para este período',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
