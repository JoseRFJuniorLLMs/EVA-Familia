import 'package:flutter/material.dart';
import 'agendamento_screen.dart';
import '../models/agendamento.dart';
import '../constants/app_colors.dart';

import '../services/auth_service.dart';
import '../services/idoso_service.dart';
import 'idoso_agendamentos_screen.dart';
import 'idoso_list_screen.dart';
import 'historico_screen.dart';
import 'settings_screen.dart';
import 'saude_emocional_screen.dart';
import 'alertas_screen.dart';
import 'dashboard_saude_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenuItem = 'Painel Principal';
  String? _linkedIdosoNome;
  bool _isLoadingIdosoNome = false;

  @override
  void initState() {
    super.initState();
    _loadLinkedIdosoNome();
  }

  /// Carrega o nome do idoso vinculado ao usuário
  Future<void> _loadLinkedIdosoNome() async {
    if (widget.user.linkedIdosoId == null) return;

    setState(() {
      _isLoadingIdosoNome = true;
    });

    try {
      final idoso = await IdosoService.getIdoso(
        widget.user.linkedIdosoId!,
        token: widget.user.accessToken,
      );

      if (mounted && idoso != null) {
        setState(() {
          _linkedIdosoNome = idoso.nome;
          _isLoadingIdosoNome = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar nome do idoso: $e');
      if (mounted) {
        setState(() {
          _isLoadingIdosoNome = false;
        });
      }
    }
  }

  /// Faz logout do usuário
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  /// Mostra opções de perfil/logout
  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar e Nome
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                widget.user.name.isNotEmpty
                    ? widget.user.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.user.role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Opções
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Meu Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(token: widget.user.accessToken),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(token: widget.user.accessToken),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Agendamentos mockados para o Painel Principal
  final List<Agendamento> _ultimosAgendamentos = [
    Agendamento(
      id: '1',
      nome: 'Nietzsche',
      telefone: '(99) 93566-8814',
      dataHora: DateTime(2026, 1, 5, 2, 43),
      tipo: 'LEMBRETE_MEDICAMENTO',
      descricao: 'MONITORAMENTO GERAL',
      status: 'NAO_ATENDIDO',
      tentativas: 1,
    ),
    Agendamento(
      id: '2',
      nome: 'Maria Silva',
      telefone: '(99) 98765-4321',
      dataHora: DateTime(2026, 1, 4, 14, 30),
      tipo: 'CONSULTA',
      descricao: 'AGENDAMENTO MÉDICO',
      status: 'CONCLUIDO',
      tentativas: 0,
    ),
    Agendamento(
      id: '3',
      nome: 'João Santos',
      telefone: '(99) 91234-5678',
      dataHora: DateTime(2026, 1, 6, 10, 0),
      tipo: 'LEMBRETE_MEDICAMENTO',
      descricao: 'CONTROLE DE PRESSÃO',
      status: 'PENDENTE',
      tentativas: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF424242,
      ), // TODO: Considerar mudar para tema dark oficial
      appBar: AppBar(
        backgroundColor: const Color(0xFF424242),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(
                alpha: 0.3,
              ), // Rosa claro
              radius: 18,
              child: const Text(
                'JF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFFAFAFA), // Off-white
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Logo EVA com cores
                Row(
                  children: [
                    _buildColoredLetter('E', Colors.green),
                    _buildColoredLetter('V', Colors.orange),
                    _buildColoredLetter('A', Colors.blue),
                  ],
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary, // Azul claro
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu Principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MENU PRINCIPAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Itens do Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Painel Principal',
                  onTap: () => _selectMenuItem('Painel Principal'),
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: 'Idosos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IdosoListScreen(token: widget.user.accessToken),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.event,
                  title: 'Agendamento',
                  onTap: () {
                    // LOGICA DE FILTRO: Se tiver idoso vinculado, vai direto para o detalhe dele
                    if (widget.user.linkedIdosoId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IdosoAgendamentosScreen(
                            idosoId: widget.user.linkedIdosoId!,
                            idosoNome: _linkedIdosoNome ?? 'Paciente',
                            token: widget.user.accessToken,
                          ),
                        ),
                      );
                    } else {
                      // Se for admin ou cuidador geral, vê a lista completa
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AgendamentoScreen(token: widget.user.accessToken),
                        ),
                      );
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.medication,
                  title: 'Medicação',
                  isSelected: _selectedMenuItem == 'Medicação',
                  onTap: () => _selectMenuItem('Medicação'),
                ),
                _buildMenuItem(
                  icon: Icons.phone,
                  title: 'Chamadas da EVA',
                  onTap: () => _selectMenuItem('Chamadas da EVA'),
                ),
                _buildMenuItem(
                  icon: Icons.wb_sunny,
                  title: 'Estados do Dia',
                  onTap: () => _selectMenuItem('Estados do Dia'),
                ),
                _buildMenuItem(
                  icon: Icons.phone_callback,
                  title: 'Simular Chamada',
                  onTap: () => _selectMenuItem('Simular Chamada'),
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: 'Notificações',
                  onTap: () => _selectMenuItem('Notificações'),
                ),
                _buildMenuItem(
                  icon: Icons.health_and_safety,
                  title: 'Dashboard de Saúde',
                  onTap: () {
                    if (widget.user.linkedIdosoId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardSaudeScreen(
                            idosoId: widget.user.linkedIdosoId!,
                            idosoNome: _linkedIdosoNome ?? 'Paciente',
                            token: widget.user.accessToken,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nenhum idoso vinculado ao seu perfil'),
                        ),
                      );
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.psychology,
                  title: 'Psicologia Digital',
                  onTap: () {
                    if (widget.user.linkedIdosoId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaudeEmocionalScreen(
                            idosoId: widget.user.linkedIdosoId!,
                            token: widget.user.accessToken,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nenhum idoso vinculado ao seu perfil'),
                        ),
                      );
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_active, // Icone distinto
                  title: 'Gestão de Alertas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AlertasScreen(token: widget.user.accessToken),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.description,
                  title: 'Relatórios',
                  onTap: () => _selectMenuItem('Relatórios'),
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Definições',
                  onTap: () => _selectMenuItem('Definições'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Informações do Usuário
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Demo · Familiar',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  color: Colors.grey[600],
                  onPressed: _showProfileOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoredLetter(String letter, Color color) {
    return Text(
      letter,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.secondary : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.secondary : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFE3F2FD), // Azul claro
      onTap: () {
        Navigator.pop(context); // Fecha o drawer
        onTap();
      },
    );
  }

  Widget _buildBody() {
    if (_selectedMenuItem == 'Painel Principal') {
      return _buildPainelPrincipal();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForMenuItem(_selectedMenuItem),
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedMenuItem,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conteúdo da tela $_selectedMenuItem',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildPainelPrincipal() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Visão Geral',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // Cards de Estatísticas Principais
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth / 3) - 12
                          : constraints.maxWidth,
                      child: _buildStatCard(
                        'Idosos Cadastrados',
                        '0',
                        const Color(0xFFE91E63),
                        Icons.people,
                      ),
                    ),
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth / 3) - 12
                          : constraints.maxWidth,
                      child: _buildStatCard(
                        'Agendamentos Hoje',
                        '${_ultimosAgendamentos.length}',
                        const Color(0xFFE91E63),
                        Icons.calendar_today,
                      ),
                    ),
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth / 3) - 12
                          : constraints.maxWidth,
                      child: _buildStatCard(
                        'Alertas Ativos',
                        '10',
                        Colors.red,
                        Icons.warning,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Seção Saúde Emocional da Família
            _buildSaudeEmocional(),

            const SizedBox(height: 40),

            // Seção Últimos Sinais Vitais
            _buildSinaisVitais(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Icon(icon, size: 48, color: color.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildSaudeEmocional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saúde Emocional da Família',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Resumo do humor detectado pela EVA nas últimas 24h',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                if (widget.user.linkedIdosoId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaudeEmocionalScreen(
                        idosoId: widget.user.linkedIdosoId!,
                        token: widget.user.accessToken,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nenhum idoso vinculado ao seu perfil'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Ver Análise da Psicóloga'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cards de Estados Emocionais
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cardWidth = isWide
                ? (constraints.maxWidth / 4) - 12
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildEmocionalCard(
                  '😊',
                  '0',
                  'ESTÁVEIS E FELIZES',
                  Colors.green,
                  cardWidth,
                ),
                _buildEmocionalCard(
                  '😐',
                  '0',
                  'NEUTROS / NORMAL',
                  Colors.orange,
                  cardWidth,
                ),
                _buildEmocionalCard(
                  '😟',
                  '0',
                  'LEVE ANSIEDADE',
                  Colors.blue,
                  cardWidth,
                ),
                _buildEmocionalCard(
                  '😢',
                  '0',
                  'PRECISAM DE CARINHO',
                  Colors.red,
                  cardWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmocionalCard(
    String emoji,
    String value,
    String label,
    Color color,
    double width,
  ) {
    Color backgroundColor;
    if (color == Colors.green) {
      backgroundColor = Colors.green[50]!;
    } else if (color == Colors.orange) {
      backgroundColor = Colors.orange[50]!;
    } else if (color == Colors.blue) {
      backgroundColor = Colors.blue[50]!;
    } else {
      backgroundColor = Colors.pink[50]!;
    }

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
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
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinaisVitais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.green[600], size: 28),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Últimos Sinais Vitais',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Capturados na última conversa do idoso',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                if (widget.user.linkedIdosoId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardSaudeScreen(
                        idosoId: widget.user.linkedIdosoId!,
                        idosoNome: _linkedIdosoNome ?? 'Paciente',
                        token: widget.user.accessToken,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nenhum idoso vinculado ao seu perfil'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('GERENCIAR SAÚDE'),
              style: TextButton.styleFrom(foregroundColor: Colors.green[600]),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cards de Sinais Vitais
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cardWidth = isWide
                ? (constraints.maxWidth / 3) - 12
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildVitalCard(
                  Icons.favorite,
                  '12/8',
                  'PRESSÃO',
                  'Normal',
                  Colors.red,
                  Colors.pink[50]!,
                  cardWidth,
                ),
                _buildVitalCard(
                  Icons.water_drop,
                  '95 mg/dL',
                  'GLICOSE',
                  'Estável',
                  Colors.blue,
                  Colors.blue[50]!,
                  cardWidth,
                ),
                _buildVitalCard(
                  Icons.thermostat,
                  '36.6 °C',
                  'TEMPERATURA',
                  'Normal',
                  Colors.orange,
                  Colors.orange[50]!,
                  cardWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildVitalCard(
    IconData icon,
    String value,
    String label,
    String status,
    Color color,
    Color backgroundColor,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMenuItem(String menuItem) {
    switch (menuItem) {
      case 'Painel Principal':
        return Icons.dashboard;
      case 'Agendamento':
        return Icons.calendar_today;
      case 'Utentes':
        return Icons.people;
      case 'Medicação':
        return Icons.medication;
      case 'Chamadas da EVA':
        return Icons.phone;
      case 'Estados do Dia':
        return Icons.wb_sunny;
      case 'Simular Chamada':
        return Icons.phone_callback;
      case 'Notificações':
        return Icons.notifications;
      case 'Relatórios':
        return Icons.description;
      case 'Definições':
        return Icons.settings;
      default:
        return Icons.home;
    }
  }

  void _selectMenuItem(String menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
    });
  }
}
