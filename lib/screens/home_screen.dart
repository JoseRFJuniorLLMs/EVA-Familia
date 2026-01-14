import 'package:flutter/material.dart';
import 'agendamento_screen.dart';
import '../models/agendamento.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenuItem = 'Painel Principal';

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
      backgroundColor: const Color(0xFF424242), // Cinza escuro
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
              backgroundColor: const Color(0xFFFFB6C1), // Rosa claro
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
                    color: const Color(0xFF87CEEB), // Azul claro
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
                  title: 'Agendamento',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgendamentoScreen(),
                      ),
                    );
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
                    const Text(
                      'tiago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Demo · Familiar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  color: Colors.grey[600],
                  onPressed: () {
                    // TODO: Implementar ação (logout ou perfil)
                  },
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
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
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
        color: isSelected ? const Color(0xFF87CEEB) : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF87CEEB) : Colors.black87,
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
            color: const Color(0xFFE91E63),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
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
                      width: isWide ? (constraints.maxWidth / 3) - 12 : constraints.maxWidth,
                      child: _buildStatCard(
                        'Idosos Cadastrados',
                        '0',
                        const Color(0xFFE91E63),
                        Icons.people,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth / 3) - 12 : constraints.maxWidth,
                      child: _buildStatCard(
                        'Agendamentos Hoje',
                        '${_ultimosAgendamentos.length}',
                        const Color(0xFFE91E63),
                        Icons.calendar_today,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth / 3) - 12 : constraints.maxWidth,
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

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
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
          Icon(
            icon,
            size: 48,
            color: color.withValues(alpha: 0.3),
          ),
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
                Icon(Icons.people, color: const Color(0xFFE91E63), size: 28),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navegar para análise da psicóloga
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Ver Análise da Psicóloga'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cards de Estados Emocionais
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cardWidth = isWide ? (constraints.maxWidth / 4) - 12 : constraints.maxWidth;
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
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navegar para gerenciar saúde
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('GERENCIAR SAÚDE'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cards de Sinais Vitais
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cardWidth = isWide ? (constraints.maxWidth / 3) - 12 : constraints.maxWidth;
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



