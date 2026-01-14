import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/historico_ligacao.dart';
import '../services/historico_service.dart';
import '../constants/app_colors.dart';
import 'historico_detail_screen.dart';

class HistoricoScreen extends StatefulWidget {
  final String? token;

  const HistoricoScreen({super.key, this.token});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<HistoricoLigacao> _historico = [];
  List<HistoricoLigacao> _filteredHistorico = [];
  bool _isLoading = true;
  String _filterStatus = 'todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistorico();
  }

  Future<void> _loadHistorico() async {
    setState(() {
      _isLoading = true;
    });

    final historico = await HistoricoService.getHistorico(token: widget.token);

    if (mounted) {
      setState(() {
        _historico = historico;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = _historico;

    // Filtro por status
    if (_filterStatus != 'todos') {
      filtered = filtered.where((h) => h.status == _filterStatus).toList();
    }

    // Filtro por busca
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((h) => h.idosoNome?.toLowerCase().contains(query) ?? false)
          .toList();
    }

    // Ordenar por data (mais recente primeiro)
    filtered.sort((a, b) => b.dataHora.compareTo(a.dataHora));

    setState(() {
      _filteredHistorico = filtered;
    });
  }

  void _navigateToDetail(HistoricoLigacao ligacao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistoricoDetailScreen(ligacao: ligacao, token: widget.token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Histórico de Ligações',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome do idoso...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 12),
                // Filtro de status
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 'todos'),
                      _buildFilterChip('Completadas', 'completada'),
                      _buildFilterChip('Perdidas', 'perdida'),
                      _buildFilterChip('Canceladas', 'cancelada'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de histórico
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistorico.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_disabled,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma ligação encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadHistorico,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredHistorico.length,
                      itemBuilder: (context, index) {
                        final ligacao = _filteredHistorico[index];
                        return _buildHistoricoCard(ligacao);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
            _applyFilters();
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHistoricoCard(HistoricoLigacao ligacao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(ligacao),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone de status
                  _buildStatusIcon(ligacao.status),
                  const SizedBox(width: 12),
                  // Nome e data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ligacao.idosoNome ?? 'Idoso',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(ligacao.dataHora),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Duração
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ligacao.duracaoFormatada,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (ligacao.resumo != null) ...[
                const SizedBox(height: 12),
                Text(
                  ligacao.resumo!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusChip(
                    ligacao.statusFormatado,
                    _getStatusColor(ligacao.status),
                  ),
                  const SizedBox(width: 8),
                  if (ligacao.sentimentoGeral != null)
                    _buildSentimentChip(ligacao.sentimentoGeral!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status.toLowerCase()) {
      case 'completada':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'perdida':
        icon = Icons.phone_missed;
        color = Colors.red;
        break;
      case 'cancelada':
        icon = Icons.cancel;
        color = Colors.orange;
        break;
      default:
        icon = Icons.phone;
        color = Colors.grey;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSentimentChip(String sentimento) {
    IconData icon;
    Color color;

    switch (sentimento.toLowerCase()) {
      case 'positivo':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'negativo':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            sentimento,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
        return Colors.green;
      case 'perdida':
        return Colors.red;
      case 'cancelada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
