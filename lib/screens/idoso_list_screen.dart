import 'package:flutter/material.dart';
import '../models/idoso.dart';
import '../services/idoso_service.dart';
import '../constants/app_colors.dart';
import 'idoso_detail_screen.dart';
import 'idoso_form_screen.dart';

class IdosoListScreen extends StatefulWidget {
  final String? token;

  const IdosoListScreen({super.key, this.token});

  @override
  State<IdosoListScreen> createState() => _IdosoListScreenState();
}

class _IdosoListScreenState extends State<IdosoListScreen> {
  List<Idoso> _idosos = [];
  List<Idoso> _filteredIdosos = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIdosos();
  }

  Future<void> _loadIdosos() async {
    setState(() {
      _isLoading = true;
    });

    final idosos = await IdosoService.getIdosos(token: widget.token);

    if (mounted) {
      setState(() {
        _idosos = idosos;
        _filteredIdosos = idosos;
        _isLoading = false;
      });
    }
  }

  void _filterIdosos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIdosos = _idosos;
      } else {
        _filteredIdosos = _idosos
            .where(
              (idoso) => idoso.nome.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _navigateToForm({Idoso? idoso}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            IdosoFormScreen(token: widget.token, idoso: idoso),
      ),
    );

    if (result == true) {
      _loadIdosos();
    }
  }

  void _navigateToDetail(Idoso idoso) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            IdosoDetailScreen(idoso: idoso, token: widget.token),
      ),
    ).then((_) => _loadIdosos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Meus Idosos',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Campo de busca
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterIdosos,
            ),
          ),

          // Lista de idosos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredIdosos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum idoso cadastrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque no + para adicionar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadIdosos,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredIdosos.length,
                      itemBuilder: (context, index) {
                        final idoso = _filteredIdosos[index];
                        return _buildIdosoCard(idoso);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildIdosoCard(Idoso idoso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(idoso),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Foto
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: idoso.fotoUrl != null
                    ? NetworkImage(idoso.fotoUrl!)
                    : null,
                child: idoso.fotoUrl == null
                    ? Text(
                        idoso.nome[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idoso.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${idoso.idade} anos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          idoso.telefone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(
                          idoso.sentimento,
                          _getSentimentIcon(idoso.sentimento),
                          _getSentimentColor(idoso.sentimento),
                        ),
                        const SizedBox(width: 8),
                        if (idoso.agendamentosPendentes > 0)
                          _buildStatusChip(
                            '${idoso.agendamentosPendentes} agendamentos',
                            Icons.event,
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ícone de navegação
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
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
            label,
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

  IconData _getSentimentIcon(String sentimento) {
    switch (sentimento.toLowerCase()) {
      case 'feliz':
        return Icons.sentiment_very_satisfied;
      case 'triste':
        return Icons.sentiment_dissatisfied;
      case 'ansioso':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color _getSentimentColor(String sentimento) {
    switch (sentimento.toLowerCase()) {
      case 'feliz':
        return Colors.green;
      case 'triste':
        return Colors.blue;
      case 'ansioso':
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
