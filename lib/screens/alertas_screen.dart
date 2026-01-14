import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/alert_service.dart';
import 'video_call_screen.dart';

class AlertasScreen extends StatefulWidget {
  final String? token;
  const AlertasScreen({super.key, this.token});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  List<Alerta> _alertas = [];
  bool _isLoading = true;
  String _filter = 'pending'; // 'pending', 'resolved'

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alertas = await AlertService.getAlertas(token: widget.token);
    if (mounted) {
      setState(() {
        _alertas = alertas;
        _isLoading = false;
      });
    }
  }

  Future<void> _resolverAlerta(Alerta alerta) async {
    final notaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver Alerta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Adicione uma nota de resolução:'),
            const SizedBox(height: 16),
            TextField(
              controller: notaController,
              decoration: const InputDecoration(
                hintText: 'Ex: Medicamento administrado com atraso.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await AlertService.resolveAlerta(
                alerta.id,
                notaController.text,
                token: widget.token,
              );
              await _loadAlerts(); // Recarrega
            },
            child: const Text('Confirmar Resolução'),
          ),
        ],
      ),
    );
  }

  List<Alerta> get _filteredAlertas {
    if (_filter == 'pending') {
      return _alertas.where((a) => !a.resolvido).toList();
    }
    return _alertas.where((a) => a.resolvido).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Central de Alertas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // 1. Dashboard Stats (Simplificado)
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        'Pendentes',
                        '${_alertas.where((a) => !a.resolvido).length}',
                        Colors.red,
                        Icons.warning_amber,
                      ),
                      _buildStat(
                        'Críticos',
                        '${_alertas.where((a) => !a.resolvido && (a.severidade == 'critica' || a.severidade == 'alta')).length}',
                        Colors.orange,
                        Icons.local_fire_department,
                      ),
                      _buildStat(
                        'Resolvidos',
                        '${_alertas.where((a) => a.resolvido).length}',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Filtros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('Pendentes', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Resolvidos', 'resolved'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Lista
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAlertas.length,
                    itemBuilder: (context, index) {
                      final alerta = _filteredAlertas[index];
                      return _buildAlertCard(alerta);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() => _filter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAlertCard(Alerta alerta) {
    Color color;
    switch (alerta.severidade) {
      case 'critica':
        color = Colors.red;
        break;
      case 'alta':
        color = Colors.orange;
        break;
      case 'aviso':
        color = Colors.amber;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(Icons.notifications_active, color: color),
            ),
            title: Text(
              alerta.idosoNome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(alerta.data, style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alerta.severidade.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(alerta.mensagem, style: const TextStyle(fontSize: 16)),
          ),
          if (!alerta.resolvido)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('RESOLVER'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      onPressed: () => _resolverAlerta(alerta),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam),
                      label: const Text('LIGAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoCallScreen(
                              idosoId: '1', // TODO: Pegar ID real do alerta
                              idosoNome: alerta.idosoNome,
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
