import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/historico_ligacao.dart';
import '../constants/app_colors.dart';

class HistoricoDetailScreen extends StatelessWidget {
  final HistoricoLigacao ligacao;
  final String? token;

  const HistoricoDetailScreen({super.key, required this.ligacao, this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detalhes da Ligação',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            if (ligacao.resumo != null) _buildResumoCard(),
            if (ligacao.resumo != null) const SizedBox(height: 16),
            if (ligacao.transcricao != null) _buildTranscricaoCard(),
            if (ligacao.transcricao != null) const SizedBox(height: 16),
            if (ligacao.sentimentoGeral != null) _buildSentimentoCard(),
            if (ligacao.sentimentoGeral != null) const SizedBox(height: 16),
            if (ligacao.topicosDiscutidos != null &&
                ligacao.topicosDiscutidos!.isNotEmpty)
              _buildTopicosCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
          Row(
            children: [
              _buildStatusIcon(ligacao.status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ligacao.idosoNome ?? 'Idoso',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(ligacao.dataHora),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Icons.access_time, 'Duração', ligacao.duracaoFormatada),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.info_outline, 'Status', ligacao.statusFormatado),
        ],
      ),
    );
  }

  Widget _buildResumoCard() {
    return _buildCard(
      'Resumo da Ligação',
      Icons.summarize,
      Text(
        ligacao.resumo!,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTranscricaoCard() {
    return _buildCard(
      'Transcrição',
      Icons.text_snippet,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          ligacao.transcricao!,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildSentimentoCard() {
    final sentimento = ligacao.sentimentoGeral!;
    final color = _getSentimentColor(sentimento);
    final icon = _getSentimentIcon(sentimento);

    return _buildCard(
      'Análise de Sentimento',
      Icons.psychology,
      Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sentimento Geral',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sentimento.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ligacao.analiseDetalhada != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildAnaliseDetalhada(ligacao.analiseDetalhada!),
          ],
        ],
      ),
    );
  }

  Widget _buildAnaliseDetalhada(Map<String, dynamic> analise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análise Detalhada',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...analise.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopicosCard() {
    return _buildCard(
      'Tópicos Discutidos',
      Icons.topic,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ligacao.topicosDiscutidos!.map((topico) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              topico,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Widget child) {
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
      radius: 24,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getSentimentColor(String sentimento) {
    switch (sentimento.toLowerCase()) {
      case 'positivo':
        return Colors.green;
      case 'negativo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSentimentIcon(String sentimento) {
    switch (sentimento.toLowerCase()) {
      case 'positivo':
        return Icons.sentiment_very_satisfied;
      case 'negativo':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
